import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SignUpPageController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();

  final RxBool hasMinLength = false.obs;
  final RxBool hasUppercase = false.obs;
  final RxBool hasNumber = false.obs;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    if (currentPage.value == 0) {
      Get.back();
    } else {
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPasswordChanged(String value) {
    final p = value.trim();
    hasMinLength.value = p.length >= 8;
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(p);
    hasNumber.value = RegExp(r'[0-9]').hasMatch(p);
  }
}
