import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qlickcare/View/Home/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qlickcare/View/Onboarding/onboardingscreens.dart';
import 'package:qlickcare/View/Auth/login.dart';

import 'package:qlickcare/Services/tokenservice.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserFlow();
  }

  Future<void> _checkUserFlow() async {
    await Future.delayed(const Duration(seconds: 0)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final accessToken = await TokenService.getAccessToken();
    final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    print("TOKEN IN SPLASH: $accessToken");

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        accessToken.notExpired()) {
      // ✅ Already logged in
      Get.offAll(() => MainHome());
    } else if (!hasSeenOnboarding) {
      // ✅ First time install → show onboarding
      await prefs.setBool('seen_onboarding', true);
      Get.offAll(() => const OnboardingScreen());
    } else {
      // ✅ Returning user but not logged in → show login
      Get.offAll(() => LoginView());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: screenWidth * 0.4,
          height: screenHeight * 0.2,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

extension TokenValidator on String {
  bool notExpired() {
    try {
      return !JwtDecoder.isExpired(this);
    } catch (e) {
      return false;
    }
  }
}
