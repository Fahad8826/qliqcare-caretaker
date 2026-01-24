import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qlickcare/Utils/common_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/onboardingcontroller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // ---------- PageView ----------
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            children: const [
              OnboardPage(
                title: "Find Your Perfect Care Partner",
                description:
                    "Personalize your care experience and connect with trusted nurses near you.",
                image: "assets/images/on1.png",
              ),
              OnboardPage(
                title: "Book Instantly",
                description:
                    "Schedule appointments effortlessly and get confirmation in seconds.",
                image: "assets/images/on2.png",
              ),
              OnboardPage(
                title: "Reliable Home Care",
                description:
                    "Professional nursing care delivered right to your doorstep.",
                image: "assets/images/on3.png",
              ),
            ],
          ),

          // ---------- Page Indicator ----------
          Positioned(
            bottom: size.height * 0.22,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: controller.pageController,
                count: controller.totalPages,
                effect: WormEffect(
                  dotHeight: isTablet ? 14 : 10,
                  dotWidth: isTablet ? 14 : 10,
                  spacing: isTablet ? 14 : 10,
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                ),
              ),
            ),
          ),

          // ---------- Bottom Gradient + Button + Arrows ----------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.18,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: size.height * 0.03,
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left arrow
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: isTablet ? 32 : 26,
                            ),
                            onPressed: controller.previousPage,
                          ),

                          // Center button (text changes only)
                          SizedBox(
                            width: isTablet ? 300 : 220,
                            child: CommonButton(
                              text:
                                  controller.currentPage.value ==
                                      controller.totalPages - 1
                                  ? "Get Started"
                                  : "Next",
                              isLoading: false,
                              onPressed: () {
                                if (controller.currentPage.value ==
                                    controller.totalPages - 1) {
                                  Get.offNamed("/login");
                                } else {
                                  controller.nextPage();
                                }
                              },
                            ),
                          ),

                          // Right arrow
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: isTablet ? 32 : 26,
                            ),
                            onPressed: controller.nextPage,
                          ),
                        ],
                      ),
                    ),

                    // ---------- Register Account Button ----------
                    TextButton(
                      onPressed: () async {
                        final Uri uri = Uri.parse(
                          'https://qliqcare.in/api/caretaker/register-page/',
                        );

                        final bool launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );

                        if (!launched) {
                          debugPrint('Failed to open URL');
                        }
                      },
                      child: const Text(
                        'Register Account',
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Stack(
      children: [
        Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: size.height * 0.5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          left: size.width * 0.08,
          right: size.width * 0.08,
          bottom: size.height * 0.28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 34 : 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              SizedBox(height: isTablet ? 20 : 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
