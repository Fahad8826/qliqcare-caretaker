import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:qlickcare/Utils/common_button.dart';
import 'package:qlickcare/Utils/common_textfeild.dart';
import 'package:qlickcare/authentication/controller/logincontroller.dart';


class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final size = MediaQuery.of(context).size;

    // ---------- 📌 Responsive Checks ----------
    final isTablet = size.width > 600;
    final padding = size.width * 0.08;
    final verticalSpace = isTablet ? 30.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 130 : 110),

                    // ---------- Logo ----------
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: isTablet ? 150 : 100,
                      ),
                    ),
                    SizedBox(height: verticalSpace),

                    // ---------- Title ----------
                    Text(
                      "Log in to your account",
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: verticalSpace + 10),

                    // ---------- Label ----------
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 18 : 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

               
                    CommonTextField(controller: controller.phoneController, hint: "Enter Your Phone Number", keyboardType: TextInputType.phone),
                    SizedBox(height: verticalSpace),
                    // ---------- Continue Button ----------
                    Obx(
                      () => CommonButton(
                        text: "Continue",
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          controller.login();
                        },
                      ),
                    ),

                    SizedBox(height: isTablet ? 60 : 40),

                    // ---------- Back Button ----------
                    GestureDetector(
                      onTap: () {
                        exit(0);
                      },
                      child: Container(
                        width: isTablet ? 70 : 55,
                        height: isTablet ? 70 : 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black45, width: 1.2),
                        ),
                        child: Icon(Icons.arrow_back, size: isTablet ? 28 : 24),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---------- Register ----------
                    TextButton(
                      onPressed: () {
                        final controller = Get.find<LoginController>();
                        controller.openRegisterPage();
                      },
                      child: Text(
                        "Register Now",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: isTablet ? 18 : 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
