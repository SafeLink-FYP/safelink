import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientHeader extends StatelessWidget {
  final Gradient? gradient;
  final Widget child;
  const GradientHeader({super.key, this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.r),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: child,
    );
  }
}
