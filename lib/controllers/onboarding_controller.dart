import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_project/screens/login/login.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;
  final GetStorage storage = GetStorage(); // Local storage

  /// Update current index when page scrolls
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to selected page
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update current index & jump to the next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      _completeOnboarding(); // Mark onboarding as completed
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Skip to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }

  /// Mark onboarding as completed
  void _completeOnboarding() {
    storage.write('hasSeenOnboarding', true); // Store flag
    Get.offAll(() => const LoginScreen()); // Navigate to login screen
  }

  /// Clear storage
  void clearStorage() {
    storage.erase();
    Get.snackbar('Storage Cleared', 'All stored data has been cleared.');
  }
}
