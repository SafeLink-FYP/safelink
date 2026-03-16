import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/emergency_contact_controller.dart';

class EmergencyContact extends StatelessWidget {
  final String label;
  final String description;

  const EmergencyContact({
    super.key,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final EmergencyContactController emergencyContactController =
        Get.find<EmergencyContactController>();
    final theme = Theme.of(context);
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
        children: [
          Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: SvgPicture.asset(
              AppAssets.phoneIcon,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.headlineMedium),
              SizedBox(height: 5.h),
              Text(description, style: theme.textTheme.bodySmall),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () => emergencyContactController.makeCall(description),
            borderRadius: BorderRadius.circular(25.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.green,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Text(
                'Call',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
