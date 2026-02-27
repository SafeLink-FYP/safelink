import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';

class SOSButton extends StatelessWidget {
  final String name;
  final String number;
  final IconData icon;
  final void Function()? onTap;
  const SOSButton({
    super.key,
    required this.name,
    required this.number,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.red, size: 24.sp),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.call, color: AppTheme.red, size: 28.sp),
          ],
        ),
      ),
    );
  }
}
