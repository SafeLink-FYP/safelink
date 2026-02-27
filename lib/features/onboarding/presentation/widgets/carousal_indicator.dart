import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CarousalIndicator extends StatelessWidget {
  final int currentPage;
  final int itemCount;

  const CarousalIndicator({
    super.key,
    required this.currentPage,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          height: 4.h,
          width: currentPage == index ? 40.w : 10.w,
          decoration: BoxDecoration(
            color: currentPage == index
                ? theme.primaryColor
                : theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(5.r),
          ),
        );
      }),
    );
  }
}
