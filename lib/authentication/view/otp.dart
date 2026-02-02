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

  @override
  void initState() {
    super.initState();
    listenForCode();
    
    SmsAutoFill().getAppSignature.then((signature) {
    debugPrint("🔑 APP HASH: $signature");
  }); 
  }

  /// ✅ Called automatically when SMS arrives
  @override
  void codeUpdated() {
    if (code == null) return;

    print("📩 OTP received: $code");

    otpController.text = code!;

    controller.verifyOtp(
      phoneNumber: widget.phoneNumber,
      otp: code!,
    );
  }

  @override
  void dispose() {
    cancel(); // ✅ Stop listener
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
                  ),
                  onCodeSubmitted: (otp) {
                    controller.verifyOtp(
                      phoneNumber: widget.phoneNumber,
                      otp: otp,
                    );
                  },
                ),

                const SizedBox(height: 35),

                /// CONTINUE BUTTON
                Obx(
                  () => CommonButton(
                    text: "Continue",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      final otp = otpController.text;
                      if (otp.length == 6) {
                        controller.verifyOtp(
                          phoneNumber: widget.phoneNumber,
                          otp: otp,
                        );
                      } else {
                        Get.snackbar(
                          "Invalid OTP",
                          "Please enter 6-digit OTP",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
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
                                  await controller.resendOtp(
                                    widget.phoneNumber,
                                  );
                                  listenForCode(); // restart listener
                                },
                          child: controller.isResending.value
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
