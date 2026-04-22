import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safelink/core/themes/app_theme.dart';

class HomeQuickAction extends StatelessWidget {
  final String label;
  final String icon;
  final Gradient iconBackgroundGradient;
  final void Function()? onTap;

  const HomeQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.iconBackgroundGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 125.h,
        width: 110.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.transparentColor.withValues(alpha: 0.10),
              offset: const Offset(0, 1),
              blurRadius: 3.r,
              spreadRadius: 0.r,
            ),
            BoxShadow(
              color: AppTheme.transparentColor.withValues(alpha: 0.10),
              offset: const Offset(0, 1),
              blurRadius: 2.r,
              spreadRadius: -1.r,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: iconBackgroundGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: Offset(0, 10),
                    blurRadius: 15.r,
                    spreadRadius: -3.r,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: Offset(0, 4),
                    blurRadius: 6.r,
                    spreadRadius: -4.r,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                icon,
                height: 20.h,
                width: 20.w,
                colorFilter: ColorFilter.mode(
                  AppTheme.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(height: 15.h),
            Text(label, style: theme.textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
