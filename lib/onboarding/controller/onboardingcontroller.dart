import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;
  Timer? autoSlideTimer;

  final int totalPages = 3;

  @override
  void onInit() {
    super.onInit();
    startAutoSlide();
  }

  void startAutoSlide() {
    autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (currentPage.value < totalPages - 1) {
        nextPage();
      } else {
        timer.cancel(); // stop auto-slide on last page
      }
    });
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    autoSlideTimer?.cancel();
    super.onClose();
  }
}
