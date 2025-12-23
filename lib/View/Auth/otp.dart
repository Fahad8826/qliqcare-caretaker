import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Controllers/otpcontroller.dart';
import 'package:qlickcare/Utils/appcolors.dart';
import 'package:qlickcare/Utils/common_button.dart';
import 'package:qlickcare/Utils/loading.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final OtpController controller = Get.put(OtpController());

  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    otpControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
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
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    "Change Number?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 6, 6, 6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                /// OTP Text Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          } else if (index == 5 && value.isNotEmpty) {
                            FocusScope.of(context).unfocus();
                            final otp = otpControllers
                                .map((e) => e.text)
                                .join();
                            controller.verifyOtp(
                              phoneNumber: widget.phoneNumber,
                              otp: otp,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                Obx(
                  () => CommonButton(
                    text: "Continue",
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      final otp = otpControllers.map((e) => e.text).join();
                      controller.verifyOtp(
                        phoneNumber: widget.phoneNumber,
                        otp: otp,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// Resend OTP Timer or Button
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
                                },
                          child: controller.isResending.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: Loading()
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

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black45, width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
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
