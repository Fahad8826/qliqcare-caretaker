import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/Utils/safe_snackbar.dart';
import 'package:qlickcare/authentication/view/otp.dart';

import 'package:url_launcher/url_launcher.dart';


class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  /// ✅ Safe snackbar wrapper
  void showSnackbar(String title, String message,
      {Color bg = Colors.redAccent,
      SnackPosition pos = SnackPosition.BOTTOM,
      int durationSec = 3}) {
    
      showSnackbarSafe(
        title,
        message,
        
      );
  
  }

  void login() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty ||
        phone.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      showSnackbar("Invalid Number", "Please enter a valid 10-digit phone number");
      return;
    }

    isLoading.value = true;

    try {
      final url = '$baseUrl/api/caretaker/send-otp/';
      print("📤 Sending OTP to: $phone");

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll({'phone_number': phone});

      http.StreamedResponse response = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Request timed out");
        },
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        final result = await response.stream.bytesToString();
        print("✅ OTP Sent Successfully: $result");

        showSnackbar("OTP Sent", "Your OTP is: $result", bg: Colors.black87, durationSec: 5);

        // Navigate to OTP screen safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(() => OtpPage(phoneNumber: phone));
        });

        return;
      }

      final errorBody = await response.stream.bytesToString();
      print("❌ Server Error (${response.statusCode}): $errorBody");

      showSnackbar("Server Error", "Failed to send OTP. Please try again later.");
    } on SocketException {
      isLoading.value = false;
      showSnackbar("No Internet", "Check your internet connection and try again.");
    } on TimeoutException {
      isLoading.value = false;
      showSnackbar("Timeout", "Server is taking too long to respond. Try again.");
    } on FormatException {
      isLoading.value = false;
      showSnackbar("Format Error", "Unexpected response from server.");
    } catch (e) {
      isLoading.value = false;
      showSnackbar("Error", "Something went wrong: $e");
    }
  }

  // ===================== REGISTER PAGE OPEN =====================
  Future<void> openRegisterPage() async {
    final url = "$baseUrl/api/caretaker/register-page/";

    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showSnackbar("Error", "Could not open the registration page.");
      }
    } catch (e) {
      showSnackbar("Error", "Failed to open the register page: $e");
    }
  }
}
