import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qlickcare/Utils/safe_snackbar.dart';


import 'package:qlickcare/notification/service/notification_services.dart';
import 'package:qlickcare/authentication/service/tokenservice.dart';
import 'package:qlickcare/Services/locationservice.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;
  final isResending = false.obs;
  final secondsRemaining = 60.obs;

  Timer? _timer;

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
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
    required BuildContext context,
  }) async {
    if (otp.length != 6) {
      showSnackbarSafe("Invalid OTP", "Please enter valid OTP");
      return;
    }

    try {
      isLoading.value = true;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/api/caretaker/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode != 200) {
        showSnackbarSafe("Error", "Invalid OTP");
        return;
      }

      final data = jsonDecode(response.body);
      await TokenService.saveTokens(
        data['tokens']['access'],
        data['tokens']['refresh'],
      );

      await _requestPermissions();
      await _initializeServices(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/MainHome');
      });
    } catch (_) {
      showSnackbarSafe("Network Error", "Please try again");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  Future<void> resendOtp(String phoneNumber) async {
    try {
      isResending.value = true;

      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/api/caretaker/resend-otp/'),
        body: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 200) {
        showSnackbarSafe("OTP Sent", "A new OTP has been sent");
        startTimer();
      } else {
        showSnackbarSafe("Error", "Failed to resend OTP");
      }
    } finally {
      isResending.value = false;
    }
  }

  // =========================================================
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.locationAlways,
      Permission.notification,
    ].request();
  }

  Future<void> _initializeServices(BuildContext context) async {
    await NotificationService().initialize();
    await LocationService.startBackground(context);
  }

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}