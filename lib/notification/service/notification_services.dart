// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// import 'package:qlickcare/authentication/service/tokenexpireservice.dart';
// import 'package:qlickcare/call/service/call_fcm_handler.dart';

// import '../../main.dart';

// class NotificationService {
//   static final NotificationService _instance =
//       NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final String baseUrl = dotenv.env['BASE_URL'] ?? '';

//   /* ==========================================================
//    * INIT
//    * ========================================================== */
//   Future<void> initialize() async {
//     await _requestPermission();
//     await _getAndRegisterToken();
//     _listenTokenRefresh();
//     _setupListeners();
//   }

//   /* ==========================================================
//    * PERMISSIONS
//    * ========================================================== */
//   Future<void> _requestPermission() async {
//     final settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     print("🔐 FCM Permission: ${settings.authorizationStatus}");
//   }

//   /* ==========================================================
//    * TOKEN
//    * ========================================================== */
//  Future<void> _getAndRegisterToken() async {
//   try {
//     if (Platform.isIOS) {
//       // 🔥 WAIT for APNS token
//       final apnsToken = await _fcm.getAPNSToken();
//       if (apnsToken == null) {
//         print('⏳ APNS token not ready yet, retrying...');
//         return; // DO NOT crash
//       }
//       print('🍎 APNS Token: $apnsToken');
//     }

//     final fcmToken = await _fcm.getToken();
//     print("📱 FCM Token: $fcmToken");

//     if (fcmToken != null) {
//       await registerTokenToBackend(fcmToken);
//     }
//   } catch (e) {
//     print('❌ FCM token error: $e');
//   }
// }

//   void _listenTokenRefresh() {
//     _fcm.onTokenRefresh.listen((newToken) async {
//       print("♻️ Token refreshed: $newToken");
//       await registerTokenToBackend(newToken);
//     });
//   }

//   /* ==========================================================
//    * BACKEND REGISTRATION
//    * ========================================================== */
//   Future<void> registerTokenToBackend(String fcmToken) async {
//     try {
//       await ApiService.request((accessToken) async {
//         final url = Uri.parse('$baseUrl/api/caretaker/register-token/');
//         return http.post(
//           url,
//           headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $accessToken",
//           },
//           body: jsonEncode({
//             "token": fcmToken,
//             "device_type": Platform.isAndroid ? "android" : "ios",
//           }),
//         );
//       });

//       print("✅ FCM token registered");
//     } catch (e) {
//       print("❌ Token registration failed: $e");
//     }
//   }

//   /* ==========================================================
//    * LISTENERS
//    * ========================================================== */
//   void _setupListeners() {
//     FirebaseMessaging.onMessage.listen((message) {
//       print('🟢 FCM FOREGROUND RECEIVED');
//       print('🟢 DATA => ${message.data}');
//       print('🟢 NOTIFICATION => ${message.notification?.title}');

//       _showLocalNotification(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print('🚀 Notification tapped');
//       // if (message.data['type'] == 'incoming_call') {
//       //   handleIncomingCallFCM(message.data);
//       // }
//     });
//   }

//   /* ==========================================================
//    * LOCAL NOTIFICATIONS INIT (ANDROID + iOS)
//    * ========================================================== */
//   Future<void> initLocalNotifications() async {
//     const androidInit =
//         AndroidInitializationSettings('@mipmap/ic_notification');

//     const iosInit = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidInit,
//       iOS: iosInit,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         print('🔔 Notification tapped: ${response.payload}');
//       },
//     );

//     if (Platform.isAndroid) {
//       const highImportanceChannel = AndroidNotificationChannel(
//         'high_importance_channel',
//         'High Importance Notifications',
//         importance: Importance.high,
//       );

//       const callChannel = AndroidNotificationChannel(
//         'call_channel',
//         'Incoming Calls',
//         description: 'Notifications for incoming calls',
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//       );

//       final androidPlugin = flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       await androidPlugin?.createNotificationChannel(highImportanceChannel);
//       await androidPlugin?.createNotificationChannel(callChannel);
//     }
//   }

//   /* ==========================================================
//    * SHOW LOCAL NOTIFICATION
//    * ========================================================== */
//   void _showLocalNotification(RemoteMessage message) {
//     if (message.notification == null) return;

//     final androidDetails = AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       message.notification!.title,
//       message.notification!.body,
//       details,
//       payload: jsonEncode(message.data),
//     );
//   }

//   /* ==========================================================
//    * LOGOUT CLEANUP
//    * ========================================================== */
//   Future<void> deleteToken() async {
//     await _fcm.deleteToken();
//     print("🗑️ FCM token deleted");
//   }
// }


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

  /* ==========================================================
   * INIT
   * ========================================================== */
  Future<void> initialize() async {
    await _requestPermission();
    await _getAndRegisterToken();
    _listenTokenRefresh();
    _setupListeners();
  }

  /* ==========================================================
   * PERMISSIONS
   * ========================================================== */
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔐 FCM Permission: ${settings.authorizationStatus}");
  }

  /* ==========================================================
   * TOKEN - UPDATED WITH RETRY LOGIC
   * ========================================================== */
  Future<void> _getAndRegisterToken() async {
    try {
      if (Platform.isIOS) {
        // 🍎 Wait for APNS token with retry logic
        String? apnsToken;
        int attempts = 0;
        const maxAttempts = 10;
        
        while (apnsToken == null && attempts < maxAttempts) {
          apnsToken = await _fcm.getAPNSToken();
          
          if (apnsToken == null) {
            attempts++;
            print('⏳ Waiting for APNS token... Attempt $attempts/$maxAttempts');
            await Future.delayed(Duration(seconds: 1));
          } else {
            print('🍎 APNS Token received: $apnsToken');
          }
        }
        
        if (apnsToken == null) {
          print('❌ APNS token not available after $maxAttempts attempts');
          print('⚠️ Make sure you are testing on a REAL iOS device (not simulator)');
          print('⚠️ Check Firebase Console for APNs Auth Key/Certificate');
          // Don't return - let FCM try anyway, token refresh will handle it later
        }
      }

      final fcmToken = await _fcm.getToken();
      print("📱 FCM Token: $fcmToken");

      if (fcmToken != null) {
        await registerTokenToBackend(fcmToken);
      } else {
        print('⚠️ FCM token is null, will retry when token refreshes');
      }
    } catch (e) {
      print('❌ FCM token error: $e');
    }
  }

  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      print("♻️ Token refreshed: $newToken");
      await registerTokenToBackend(newToken);
    });
  }

  /* ==========================================================
   * BACKEND REGISTRATION
   * ========================================================== */
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

      print("✅ FCM token registered to backend");
    } catch (e) {
      print("❌ Token registration failed: $e");
    }
  }

  /* ==========================================================
   * LISTENERS
   * ========================================================== */
  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      print('🟢 FCM FOREGROUND RECEIVED');
      print('🟢 DATA => ${message.data}');
      print('🟢 NOTIFICATION => ${message.notification?.title}');

      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('🚀 Notification tapped');
      // if (message.data['type'] == 'incoming_call') {
      //   handleIncomingCallFCM(message.data);
      // }
    });
  }

  /* ==========================================================
   * LOCAL NOTIFICATIONS INIT (ANDROID + iOS)
   * ========================================================== */
  // Future<void> initLocalNotifications() async {
  //   const androidInit =
  //       AndroidInitializationSettings('@mipmap/ic_notification');

  //   const iosInit = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );

  //   const initSettings = InitializationSettings(
  //     android: androidInit,
  //     iOS: iosInit,
  //   );

  //   await flutterLocalNotificationsPlugin.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (response) {
  //       print('🔔 Notification tapped: ${response.payload}');
  //     },
  //   );

  //   if (Platform.isAndroid) {
  //     const highImportanceChannel = AndroidNotificationChannel(
  //       'high_importance_channel',
  //       'High Importance Notifications',
  //       importance: Importance.high,
  //     );

  //     const callChannel = AndroidNotificationChannel(
  //       'call_channel',
  //       'Incoming Calls',
  //       description: 'Notifications for incoming calls',
  //       importance: Importance.max,
  //       playSound: true,
  //       enableVibration: true,
  //     );

  //     final androidPlugin = flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation
  //             AndroidFlutterLocalNotificationsPlugin>();

  //     await androidPlugin?.createNotificationChannel(highImportanceChannel);
  //     await androidPlugin?.createNotificationChannel(callChannel);
  //   }
  // }






  Future<void> initLocalNotifications() async {
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_notification');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('🔔 Notification tapped: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      const highImportanceChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      );

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

      await androidPlugin?.createNotificationChannel(highImportanceChannel);
      await androidPlugin?.createNotificationChannel(callChannel);
    }
  }
  /* ==========================================================
   * SHOW LOCAL NOTIFICATION
   * ========================================================== */
  void _showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  /* ==========================================================
   * LOGOUT CLEANUP
   * ========================================================== */
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    print("🗑️ FCM token deleted");
  }
}