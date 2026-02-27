import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  final void Function()? onTap;
  const OfflineBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        color: AppTheme.orange.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 16.sp, color: AppTheme.orange),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Offline mode - Tap to reconnect',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.orange,
                ),
              ),
            ),
            Icon(Icons.refresh, size: 16.sp, color: AppTheme.orange),
          ],
        ),
      ),
    );
  }
}
