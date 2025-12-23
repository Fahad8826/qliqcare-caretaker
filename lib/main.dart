
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qlickcare/Services/locationservice.dart';
import 'package:qlickcare/Services/tokenservice.dart';

import 'Routes/app_routes.dart';
import 'Utils/appcolors.dart';
import 'Services/notification_services.dart';

/// ----------------------------------------------------------
/// 🔥 Background Handler (TOP LEVEL – REQUIRED)
/// ----------------------------------------------------------
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 Background message: ${message.messageId}");
}

/// ----------------------------------------------------------
/// 🔔 Local Notification Plugin (GLOBAL)
/// ----------------------------------------------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // 🔔 Background messages
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // 🔔 Local notification init
  await NotificationService().initLocalNotifications();

   LocationService.initialize();

  // 🔥 Initialize FCM (ONLY HERE)
  await NotificationService().initialize();
  // 🛰 Initialize background location tracking
  await _initializeBackgroundLocation();

  runApp(const MyApp());
}
Future<void> _initializeBackgroundLocation() async {
  try {
    // Check if user is logged in
    final token = await TokenService.getAccessToken();
    
    if (token != null) {
      print("🚀 Starting background location service...");
      
      // Start background location tracking
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


/// ----------------------------------------------------------
/// 🟦 App
/// ----------------------------------------------------------
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
