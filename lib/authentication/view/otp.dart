
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:qlickcare/authentication/controller/otpcontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/common_button.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  final OtpController controller = Get.put(OtpController());
  final TextEditingController otpController = TextEditingController();
  String? appSignature;

  @override
  void initState() {
    super.initState();
    _initializeSmsListener();
  }

  /// ✅ Initialize SMS listener properly
  Future<void> _initializeSmsListener() async {
    try {
      // Get app signature
      appSignature = await SmsAutoFill().getAppSignature;
      debugPrint("🔑 APP HASH: $appSignature");

      // Start listening with a small delay to ensure everything is ready
      await Future.delayed(const Duration(milliseconds: 300));
      listenForCode();
      debugPrint("👂 SMS Listener started successfully");
    } catch (e) {
      debugPrint("❌ Error initializing SMS listener: $e");
    }
  }

  /// ✅ Called automatically when SMS arrives
  @override
  void codeUpdated() {
    debugPrint("🚨 codeUpdated() CALLED!");
    debugPrint("📩 Code value: $code");

    if (code == null || code!.isEmpty) {
      debugPrint("⚠️ Code is null or empty");
      return;
    }

    debugPrint("✅ OTP received: $code");

    // Update text field
    setState(() {
      otpController.text = code!;
    });

    // Auto-verify after a tiny delay
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.verifyOtp(phoneNumber: widget.phoneNumber, otp: code!);
    });
  }

  /// ✅ Restart listener (for resend OTP)
  Future<void> _restartListener() async {
    try {
      debugPrint("🔄 Restarting SMS listener...");
      cancel(); // Cancel old listener
      await Future.delayed(const Duration(milliseconds: 300));
      listenForCode(); // Start new listener
      debugPrint("✅ SMS Listener restarted");
    } catch (e) {
      debugPrint("❌ Error restarting listener: $e");
    }
  }

  @override
  void dispose() {
    debugPrint("🧹 Disposing OTP page...");
    cancel(); // Stop listener
    unregisterListener(); // Unregister completely
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.05,
            ),
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 90),
                const SizedBox(height: 20),

                const Text(
                  "Confirm it's you",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text(
                  "Enter the OTP sent to\n+91 XX-XXX-${widget.phoneNumber.substring(6)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 30),

                /// ✅ OTP INPUT (auto-filled safely)
                PinFieldAutoFill(
                  controller: otpController,
                  codeLength: 6,
                  decoration: UnderlineDecoration(
                    colorBuilder: FixedColorBuilder(AppColors.primary),
                    lineHeight: 2,
                    lineStrokeCap: StrokeCap.round,
                  ),
                  currentCode: otpController.text,
                  onCodeSubmitted: (otp) {
                    debugPrint("🎯 OTP Submitted: $otp");
                    if (otp.length == 6) {
                      controller.verifyOtp(
                        phoneNumber: widget.phoneNumber,
                        otp: otp,
                      );
                    }
                  },
                  onCodeChanged: (code) {
                    debugPrint("📝 Code changed: $code");
                    // Auto-submit when complete
                    if (code?.length == 6) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        controller.verifyOtp(
                          phoneNumber: widget.phoneNumber,
                          otp: code!,
                        );
                      });
                    }
                  },
                ),

                const SizedBox(height: 35),

                /// CONTINUE BUTTON
                Obx(
                  () => CommonButton(
                    text: "Continue",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      final otp = otpController.text.trim();
                      debugPrint("📤 Manual submit - OTP: $otp");

                      if (otp.length == 6) {
                        controller.verifyOtp(
                          phoneNumber: widget.phoneNumber,
                          otp: otp,
                        );
                      } else {
                        print("⚠️ Invalid OTP length: ${otp.length}");
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// RESEND OTP
                Obx(() {
                  return controller.secondsRemaining.value > 0
                      ? Text(
                          "Resend Code in ${controller.secondsRemaining.value} Sec",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        )
                      : TextButton(
                          onPressed: controller.isResending.value
                              ? null
                              : () async {
                                  debugPrint("🔄 Resending OTP...");

                                  // Resend OTP
                                  await controller.resendOtp(
                                    widget.phoneNumber,
                                  );

                                  // Restart SMS listener
                                  await _restartListener();
                                },
                          child: controller.isResending.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        );
                }),

                const SizedBox(height: 20),

                // ✅ DEBUG: Test SMS Read (Remove in production)
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  TextButton(
                    onPressed: () async {
                      debugPrint("🧪 Testing SMS read...");
                      try {
                        final code = await SmsAutoFill().code.first;
                        debugPrint("📱 Fetched code: $code");
                        if (code != null && code.isNotEmpty) {
                          setState(() {
                            otpController.text = code;
                          });
                        }
                      } catch (e) {
                        debugPrint("❌ Error fetching code: $e");
                      }
                    },
                    child: const Text(
                      "🧪 Test SMS Read (Debug)",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
