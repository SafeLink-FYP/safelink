import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';

class RecentCase extends StatelessWidget {
  final String label;
  final String status;
  final String time;
  final IconData iconData;
  final Color statusColor;
  final VoidCallback? onTap;

  const RecentCase({
    super.key,
    required this.label,
    required this.status,
    required this.time,
    this.iconData = Icons.shield,
    this.statusColor = const Color(0xFF00B894),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(10.r);
    return Material(
      color: theme.cardColor,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            borderRadius: radius,
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
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Icon(
                  iconData,
                  color: AppTheme.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: theme.textTheme.headlineMedium),
                      SizedBox(width: 25.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5.h,
                          horizontal: 10.w,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.75),
                            width: 1.w,
                          ),
                        ),
                        child: Text(status, style: theme.textTheme.headlineSmall),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(time, style: theme.textTheme.bodySmall),
                ],
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryIconTheme.color,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
