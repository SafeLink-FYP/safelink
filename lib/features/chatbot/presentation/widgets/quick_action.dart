import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';

class QuickAction extends StatelessWidget {
  final String label;
  final String icon;
  final void Function()? onTap;

  const QuickAction({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.20),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: AppTheme.primaryGradient,
              ),
              child: SvgPicture.asset(
                icon,
                width: 15.w,
                height: 15.h,
                colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Text(label, style: theme.textTheme.headlineSmall)),
          ],
        ),
      ),
    );
  }
}
