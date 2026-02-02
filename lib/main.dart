import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qlickcare/Routes/app_routes.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/call/service/call_fcm_handler.dart';

import 'Utils/appcolors.dart';
import 'notification/service/notification_services.dart';

// ✅ GLOBAL notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ BACKGROUND FCM HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  print('🔴 ========================================');
  print('🔴 FCM BACKGROUND HANDLER TRIGGERED');
  print('🔴 ========================================');
  print('🔴 Message ID: ${message.messageId}');
  print('🔴 DATA: ${message.data}');
  print('🔴 NOTIFICATION: ${message.notification?.title}');
  
  // ✅ Check if it's a call
    // if (message.data['type'] == 'incoming_call') {
    //   print('🔴 DETECTED INCOMING CALL');
    //   await _showFullScreenCallNotification(message.data);
    // } else {
    //   print('🔴 NOT A CALL - TYPE: ${message.data['type']}');
    // }
  
  
  print('🔴 ========================================');
}

// ✅ SHOW FULL-SCREEN NOTIFICATION
// Future<void> _showFullScreenCallNotification(Map<String, dynamic> data) async {
//   print('📱 Creating full-screen notification...');
  
//   final FlutterLocalNotificationsPlugin notifications = 
//       FlutterLocalNotificationsPlugin();
  
//   const AndroidInitializationSettings androidInit =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
  
//   await notifications.initialize(
//     const InitializationSettings(android: androidInit),
//     onDidReceiveNotificationResponse: (details) async {
//       print('🔔 Notification tapped: ${details.actionId}');
      
//       if (details.payload != null) {
//         final callData = jsonDecode(details.payload!);
        
//         if (details.actionId == 'answer') {
//           print('✅ User tapped ANSWER');
//           await handleIncomingCallFCM(callData);
//         } else if (details.actionId == 'decline') {
//           print('❌ User tapped DECLINE');
//           // TODO: Call decline API
//         } else {
//           print('📱 Notification body tapped');
//           await handleIncomingCallFCM(callData);
//         }
//       }
//     },
//   );
  
//   // ✅ Full-screen notification
//   final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'call_channel',
//     'Incoming Calls',
//     channelDescription: 'Notifications for incoming calls',
//     importance: Importance.max,
//     priority: Priority.max,
//     fullScreenIntent: true,
//     category: AndroidNotificationCategory.call,
//     ongoing: true,
//     autoCancel: false,
//     playSound: true,
//     enableVibration: true,
//     visibility: NotificationVisibility.public, // ✅ Show on lock screen
//     actions: <AndroidNotificationAction>[
//       const AndroidNotificationAction(
//         'answer',
//         'Answer',
//         showsUserInterface: true,
//       ),
//       const AndroidNotificationAction(
//         'decline',
//         'Decline',
//         cancelNotification: true,
//       ),
//     ],
//   );
  
//   final int notificationId = data['call_log_id'].hashCode;
  
//   await notifications.show(
//     notificationId,
//     '${data['call_type'] == 'video' ? '📹' : '📞'} Incoming Call',
//     '${data['caller_name']} is calling...',
//     NotificationDetails(android: androidDetails),
//     payload: jsonEncode(data),
//   );
  
//   print('✅ Full-screen notification shown with ID: $notificationId');
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // ✅ Register background handler FIRST
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Local notification init
  await NotificationService().initLocalNotifications();

  LocationService.initialize();

  // ✅ Initialize FCM
  await NotificationService().initialize();
  
  // ✅ Initialize background location tracking
  await _initializeBackgroundLocation();

  runApp(const MyApp());
}

Future<void> _initializeBackgroundLocation() async {
  try {
    final token = await TokenService.getAccessToken();
    
    if (token != null) {
      print("🚀 Starting background location service...");
      
      bool started = await LocationService.startBackgroundLocation();
      
      if (started) {
        print("✅ Background location service started successfully");
      } else {
        print("⚠️ Background location service failed to start");
      }
    } else {
      print("ℹ️ User not logged in, skipping location service");
    }
  } catch (e) {
    print("❌ Error initializing background location: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QlickCare',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),
      ),
      initialRoute: '/splash',
      getPages: AppRoutes.pages,
    );
  }
}