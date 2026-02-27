import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OnboardingNavigationController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value == 2) {
      Get.offAllNamed('signInView');
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    Get.offAllNamed('signInView');
  }
}
