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
import 'package:qlickcare/firebase_options.dart';

import 'Utils/appcolors.dart';
import 'notification/service/notification_services.dart';

// ✅ GLOBAL notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
// ✅ BACKGROUND FCM HANDLER
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  print('🔴 ========================================');
  print('🔴 FCM BACKGROUND HANDLER TRIGGERED');
  print('🔴 ========================================');
  print('🔴 Message ID: ${message.messageId}');
  print('🔴 DATA: ${message.data}');
  print('🔴 NOTIFICATION: ${message.notification?.title}');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  
  print('🔴 ========================================');
}

// ✅ SHOW FULL-SCREEN NOTIFICATION


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);

  await NotificationService().initLocalNotifications();
  await NotificationService().initialize();

  LocationService.initialize();

  runApp(const MyApp());
}

Future<void> _initializeBackgroundLocation(BuildContext context) async {
  try {
    final token = await TokenService.getAccessToken();
    
    if (token != null) {
      print("🚀 Starting background location service...");
      
      bool started = await LocationService.startBackground(context);
      
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
        scaffoldMessengerKey: rootScaffoldMessengerKey,
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