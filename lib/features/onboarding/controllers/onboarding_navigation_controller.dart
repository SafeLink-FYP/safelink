import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';

class OnboardingNavigationController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value == 2) {
      Get.offAllNamed(AppRoutes.signInView);
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    Get.offAllNamed(AppRoutes.signInView);
  }
}
