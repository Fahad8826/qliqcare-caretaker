import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qlickcare/authentication/view/otp.dart';

import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final baseUrl = dotenv.env['BASE_URL'] ?? '';

  void login() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty ||
        phone.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      Get.snackbar(
        "Invalid Number",
        "Please enter a valid 10-digit phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
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

        Get.snackbar(
          "OTP Sent",
          "Your OTP is: $result",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Navigate to OTP screen
        Get.to(() => OtpPage(phoneNumber: phone));
        return;
      }

      final errorBody = await response.stream.bytesToString();
      print("❌ Server Error (${response.statusCode}): $errorBody");

      Get.snackbar(
        "Server Error",
        "Failed to send OTP. Please try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    // --- Exception handling remains the same ---
    on SocketException catch (_) {
      isLoading.value = false;
      Get.snackbar(
        "No Internet",
        "Check your internet connection and try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } on TimeoutException catch (_) {
      isLoading.value = false;
      Get.snackbar(
        "Timeout",
        "Server is taking too long to respond. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } on FormatException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Format Error",
        "Unexpected response from server.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // // ===================== REGISTER PAGE OPEN =====================
  Future<void> openRegisterPage() async {
    final url = "$baseUrl/api/caretaker/register-page/";

    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          "Error",
          "Could not open the registration page.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open the register page: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  
}
