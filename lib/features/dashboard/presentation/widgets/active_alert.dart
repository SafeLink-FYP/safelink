import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';

class ActiveAlert extends StatelessWidget {
  final String label;
  final String location;
  final String time;
  final String alertLevel;
  final String icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const ActiveAlert({
    super.key,
    required this.label,
    required this.location,
    required this.time,
    required this.alertLevel,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Container(
      padding: EdgeInsets.all(15.r),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SvgPicture.asset(
              icon,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: theme.textTheme.headlineMedium),
                  SizedBox(width: 25.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.10),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      alertLevel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text('$location, $time', style: theme.textTheme.bodySmall),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () {},
            child: Icon(Icons.arrow_forward_ios, size: 15.sp),
          ),
        ],
      ),
    );
  }
}
