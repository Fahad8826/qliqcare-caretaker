
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
  // void _setupListeners() {
  //   FirebaseMessaging.onMessage.listen((message) {
  //     _showLocalNotification(message);
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     print("🚀 Opened from notification: ${message.data}");
  //   });
  // }


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

}


  /// ----------------------------------------------------------
  /// LOCAL NOTIFICATIONS
  /// ----------------------------------------------------------
  Future<void> initLocalNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

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
