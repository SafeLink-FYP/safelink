import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade100,
            Colors.grey.shade900,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}