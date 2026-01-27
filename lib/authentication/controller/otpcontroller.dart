

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:qlickcare/notification/service/notification_services.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/Services/locationservice.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;
  final isResending = false.obs;
  final secondsRemaining = 30.obs;

  Timer? _timer;

  // =========================================================
  // 🔥 TIMER
  // =========================================================
  void startTimer() {
    _timer?.cancel();

    secondsRemaining.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // =========================================================
  // 🔥 VERIFY OTP
  // =========================================================
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter the 6-digit OTP",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final apiUrl = Uri.parse('$baseUrl/api/caretaker/verify-otp/');

    try {
      isLoading.value = true;

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      // =====================================================
      // ✅ SUCCESS
      // =====================================================
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("✅ OTP Verified: $data");

        final accessToken = data['tokens']['access'];
        final refreshToken = data['tokens']['refresh'];

        await TokenService.saveTokens(accessToken, refreshToken);
        print("✅ Tokens saved successfully");

        // 🔥 ASK PERMISSIONS FIRST (CRITICAL FIX)
        await _requestRequiredPermissions();

        
        // 🔥 Now start background services safely
        await _initializeBackgroundServices();

        // Get.snackbar(
        //   "Success",
        //   "Login successful!",
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );

        Get.offAllNamed('/MainHome');
      }

      // =====================================================
      // ❌ FAIL
      // =====================================================
      else {
        print("❌ Verification Failed: ${response.body}");

        Get.snackbar(
          "Error",
          "Invalid OTP. Please try again.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ OTP Verification Error: $e");

      Get.snackbar(
        "Network Error",
        "Something went wrong ",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // 🔥 REQUEST ALL PERMISSIONS (VERY IMPORTANT)
  // =========================================================
  Future<bool> _requestRequiredPermissions() async {
    print("🔐 Requesting permissions...");

    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.notification,
    ].request();

    bool granted = statuses.values.every((s) => s.isGranted);

    print("🔐 Permission result: $granted");

    return granted;
  }

  // =========================================================
  // 🔥 INITIALIZE SERVICES AFTER PERMISSION
  // =========================================================
  Future<void> _initializeBackgroundServices() async {
    try {
      print("🚀 Initializing background services...");

      await _initializeNotifications();
      await _initializeBackgroundLocation();

      print("✅ All background services initialized successfully");
    } catch (e) {
      print("❌ Error initializing background services: $e");
    }
  }

  // =========================================================
  // 🔔 NOTIFICATIONS
  // =========================================================
  Future<void> _initializeNotifications() async {
    try {
      print("🔔 Initializing notifications...");

      final notificationService = NotificationService();
      await notificationService.initialize();

      print("✅ Notifications initialized");
    } catch (e) {
      print("❌ Error initializing notifications: $e");
    }
  }

  // =========================================================
  // 📍 LOCATION (SAFE START)
  // =========================================================
  Future<void> _initializeBackgroundLocation() async {
    try {
      print("📍 Starting background location...");

      bool started = await LocationService.startBackgroundLocation();

      if (started) {
        print("✅ Background location started");
      } else {
        print("⚠️ Location permission denied");
      }
    } catch (e) {
      print("❌ Error initializing background location: $e");
    }
  }

  // =========================================================
  // 🔹 RESEND OTP
  // =========================================================
  Future<void> resendOtp(String phoneNumber) async {
    try {
      isResending.value = true;

      final baseUrl = dotenv.env['BASE_URL']?.trim();
      final apiUrl = Uri.parse(
        '$baseUrl/api/caretaker/resend-otp/?phone_number=$phoneNumber',
      );

      var request = http.MultipartRequest('POST', apiUrl);
      request.fields.addAll({'phone_number': phoneNumber});

      var response = await request.send();

      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();

        print("✅ OTP Resent: $result");

        Get.snackbar(
          "OTP Sent",
          "A new OTP has been sent",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        startTimer();
      } else {
        print("❌ Resend OTP Failed");

        Get.snackbar(
          "Error",
          "Failed to resend OTP",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      isResending.value = false;
    }
  }

  // =========================================================
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
