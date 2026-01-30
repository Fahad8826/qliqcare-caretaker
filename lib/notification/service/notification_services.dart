import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
import 'package:qlickcare/call/service/call_fcm_handler.dart';

import '../../main.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  /// ----------------------------------------------------------
  /// INIT
  /// ----------------------------------------------------------
  Future<void> initialize() async {
    await _requestPermission();
    await _getAndRegisterToken();
    _listenTokenRefresh();
    _setupListeners();
  }

  /// ----------------------------------------------------------
  /// PERMISSION
  /// ----------------------------------------------------------
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔐 Permission: ${settings.authorizationStatus}");
  }

  /// ----------------------------------------------------------
  /// TOKEN
  /// ----------------------------------------------------------
  Future<void> _getAndRegisterToken() async {
    final token = await _fcm.getToken();
    print("📱 FCM Token: $token");

    if (token != null) {
      await registerTokenToBackend(token);
    }
  }

  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      print("♻️ Token refreshed: $newToken");
      await registerTokenToBackend(newToken);
    });
  }

  /// ----------------------------------------------------------
  /// REGISTER TO BACKEND
  /// ----------------------------------------------------------
  Future<void> registerTokenToBackend(String fcmToken) async {
    try {
      await ApiService.request((accessToken) async {
        final url = Uri.parse('$baseUrl/api/caretaker/register-token/');
        return http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode({
            "token": fcmToken,
            "device_type": Platform.isAndroid ? "android" : "ios",
          }),
        );
      });

      print("✅ FCM Token registered to backend");
    } catch (e) {
      print("❌ Failed to register FCM token: $e");
      // Do NOT block the app flow if registration fails
    }
  }

  /// ----------------------------------------------------------
  /// LISTENERS
  /// ----------------------------------------------------------
  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      print('🟢 FCM(FG) RECEIVED');
      print('🟢 FCM(FG) DATA => ${message.data}');
      print('🟢 FCM(FG) NOTIFICATION => ${message.notification?.title}');

      if (message.data['type'] == 'incoming_call') {
        print('🟢 FCM(FG) TYPE = incoming_call');
        handleIncomingCallFCM(message.data);
        return;
      }

      print('🟢 FCM(FG) NORMAL NOTIFICATION');
      _showLocalNotification(message);
    });

    // ✅ NEW: Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🚀 Opened from notification: ${message.data}");
      
      if (message.data['type'] == 'incoming_call') {
        handleIncomingCallFCM(message.data);
      }
    });
  }

  /// ----------------------------------------------------------
  /// LOCAL NOTIFICATIONS
  /// ----------------------------------------------------------
  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // ✅ Add notification tap handler
    final initSettings = InitializationSettings(
      android: androidInit,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ EXISTING CHANNEL - Keep as is
    const highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    // ✅ NEW CHANNEL - For incoming calls
    const callChannel = AndroidNotificationChannel(
      'call_channel',
      'Incoming Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // ✅ Create BOTH channels
    await androidPlugin!.createNotificationChannel(highImportanceChannel);
    await androidPlugin!.createNotificationChannel(callChannel);
  }

  // ✅ NEW: Handle notification tap
  Future<void> _onNotificationTap(NotificationResponse details) async {
    print('🔔 Notification tapped: ${details.payload}');
    
    if (details.payload != null) {
      try {
        final data = jsonDecode(details.payload!);
        
        if (data['type'] == 'incoming_call') {
          // Handle based on action
          if (details.actionId == 'answer') {
            print('✅ User tapped ANSWER');
            await handleIncomingCallFCM(data);
          } else if (details.actionId == 'decline') {
            print('❌ User tapped DECLINE');
            // TODO: Call decline API
            // You can add a decline method in your call service
          } else {
            // Notification body tapped (not action button)
            print('📱 Notification body tapped');
            await handleIncomingCallFCM(data);
          }
        }
      } catch (e) {
        print('❌ Error handling notification tap: $e');
      }
    }
  }

  // ✅ KEEP EXISTING - Normal notifications
  void _showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// ----------------------------------------------------------
  /// LOGOUT CLEANUP
  /// ----------------------------------------------------------
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    print("🗑️ FCM token deleted");
  }
}