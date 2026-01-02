
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import 'tokenservice.dart';

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
    final authToken = await TokenService.getAccessToken();
    if (authToken == null) return;

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
  Future<void> registerTokenToBackend(String token) async {
    final authToken = await TokenService.getAccessToken();
    if (authToken == null) return;

    await http.post(
      Uri.parse('$baseUrl/api/caretaker/register-token/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: jsonEncode({
        "token": token,
        "device_type": Platform.isAndroid ? "android" : "ios",
      }),
    );
  }

  /// ----------------------------------------------------------
  /// LISTENERS
  /// ----------------------------------------------------------
  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🚀 Opened from notification: ${message.data}");
    });
  }

  /// ----------------------------------------------------------
  /// LOCAL NOTIFICATIONS
  /// ----------------------------------------------------------
  Future<void> initLocalNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
        InitializationSettings(android: androidInit);

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
