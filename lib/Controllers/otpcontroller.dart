// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:qlickcare/Services/tokenservice.dart';

// class OtpController extends GetxController {
//   final isLoading = false.obs;
//   final isResending = false.obs;
//   final secondsRemaining = 30.obs;

//   Timer? _timer;

//   /// 🔹 Start countdown timer
//   void startTimer() {
//     _timer?.cancel();
//     secondsRemaining.value = 60;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (secondsRemaining.value > 0) {
//         secondsRemaining.value--;
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   /// 🔹 Verify OTP
//   Future<void> verifyOtp({
//     required String phoneNumber,
//     required String otp,
//   }) async {
//     if (otp.isEmpty || otp.length < 6) {
//       Get.snackbar(
//         "Invalid OTP",
//         "Please enter the 6-digit OTP",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     final baseUrl = dotenv.env['BASE_URL'] ?? '';
//     final apiUrl = Uri.parse('$baseUrl/api/caretaker/verify-otp/');

//     try {
//       isLoading.value = true;

//       // ✅ Use POST with JSON body instead of Multipart
//       final response = await http.post(
//         apiUrl,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("✅ OTP Verified: $data");

//         final accessToken = data['tokens']['access'];
//         final refreshToken = data['tokens']['refresh'];
//         await TokenService.saveTokens(accessToken, refreshToken);

//         Get.snackbar(
//           "Success",
//           "OTP verified successfully!",
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );

//         // ✅ Navigate to Home Page
//         Get.offAllNamed('/MainHome');
//       } else {
//         print("❌ Verification Failed: ${response.body}");
//         Get.snackbar(
//           "Error",
//           "Invalid OTP. Please try again.",
//           backgroundColor: Colors.redAccent,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Network Error",
//         "Something went wrong: $e",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// 🔹 Resend OTP
//   Future<void> resendOtp(String phoneNumber) async {
//     try {
//       isResending.value = true;

//       final baseUrl = dotenv.env['BASE_URL']?.trim();
//       if (baseUrl == null || baseUrl.isEmpty) {
//         throw Exception("API_BASE_URL not found in .env");
//       }

//       // ✅ No trailing slash duplication, safe concatenation
//       final apiUrl = Uri.parse(
//         '$baseUrl/api/caretaker/resend-otp/?phone_number=$phoneNumber',
//       );

//       // ✅ Working request (like Postman)
//       var request = http.MultipartRequest('POST', apiUrl);
//       request.fields.addAll({'phone_number': phoneNumber});

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         final result = await response.stream.bytesToString();
//         print("✅ OTP Resent: $result");
//         Get.snackbar(
//           "OTP Sent",
//           "A new OTP has been sent to your phone number.",
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         startTimer();
//       } else {
//         final error = await response.stream.bytesToString();
//         print("❌ Resend OTP Failed: $error");
//         Get.snackbar(
//           "Error",
//           "Failed to resend OTP. Try again later.",
//           backgroundColor: Colors.redAccent,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Network Error",
//         "Something went wrong: $e",
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//     } finally {
//       isResending.value = false;
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     startTimer(); // start countdown when page loads
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Services/notification_services.dart';
import 'package:qlickcare/Services/tokenservice.dart';
import 'package:qlickcare/Services/locationservice.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;
  final isResending = false.obs;
  final secondsRemaining = 30.obs;

  Timer? _timer;

  /// 🔹 Start countdown timer
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

  /// 🔹 Verify OTP
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

      // ✅ Use POST with JSON body instead of Multipart
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ OTP Verified: $data");

        final accessToken = data['tokens']['access'];
        final refreshToken = data['tokens']['refresh'];
        
        // Save tokens
        await TokenService.saveTokens(accessToken, refreshToken);
        print("✅ Tokens saved successfully");

        // 🔥 Initialize background services after successful login
        await _initializeBackgroundServices();

        Get.snackbar(
          "Success",
          "Login successful!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // ✅ Navigate to Home Page
        Get.offAllNamed('/MainHome');
      } else {
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
        "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Initialize background services after login
  Future<void> _initializeBackgroundServices() async {
    try {
      print("🚀 Initializing background services...");

      // 1. Initialize FCM and register token
      await _initializeNotifications();

      // 2. Start background location tracking
      await _initializeBackgroundLocation();

      print("✅ All background services initialized successfully");
    } catch (e) {
      print("❌ Error initializing background services: $e");
      // Don't block login flow if services fail
    }
  }

  /// Initialize FCM notifications
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

  /// Initialize background location tracking
  Future<void> _initializeBackgroundLocation() async {
    try {
      print("📍 Initializing background location...");

      // Start background location tracking
      bool started = await LocationService.startBackgroundLocation();

      if (started) {
        print("✅ Background location service started successfully");

        // Show success message
        Get.snackbar(
          "Location Tracking",
          "Background location tracking enabled",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      } else {
        print("⚠️ Background location permission denied");

        // Inform user
        Get.snackbar(
          "Location Permission",
          "Location tracking requires permission. Enable it in settings.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      print("❌ Error initializing background location: $e");
    }
  }

  /// 🔹 Resend OTP
  Future<void> resendOtp(String phoneNumber) async {
    try {
      isResending.value = true;

      final baseUrl = dotenv.env['BASE_URL']?.trim();
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("API_BASE_URL not found in .env");
      }

      // ✅ No trailing slash duplication, safe concatenation
      final apiUrl = Uri.parse(
        '$baseUrl/api/caretaker/resend-otp/?phone_number=$phoneNumber',
      );

      // ✅ Working request (like Postman)
      var request = http.MultipartRequest('POST', apiUrl);
      request.fields.addAll({'phone_number': phoneNumber});

      var response = await request.send();

      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        print("✅ OTP Resent: $result");
        Get.snackbar(
          "OTP Sent",
          "A new OTP has been sent to your phone number.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        startTimer();
      } else {
        final error = await response.stream.bytesToString();
        print("❌ Resend OTP Failed: $error");
        Get.snackbar(
          "Error",
          "Failed to resend OTP. Try again later.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Resend OTP Error: $e");
      Get.snackbar(
        "Network Error",
        "Something went wrong: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    startTimer(); // start countdown when page loads
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}