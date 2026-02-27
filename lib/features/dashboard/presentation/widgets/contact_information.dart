import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';

class ContactInformation extends StatelessWidget {
  const ContactInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Container(
      padding: EdgeInsets.all(20.r),
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
          _buildContactTile(
            label: 'Phone',
            description: '+92 300 1234567',
            leadingIcon: AppAssets.phoneIcon,
            iconBackgroundGradient: AppTheme.primaryGradient,
            context: context,
          ),
          _buildDivider(context: context),
          _buildContactTile(
            label: 'Email',
            description: 'raja.hamid@example.com',
            leadingIcon: AppAssets.emailIcon,
            iconBackgroundGradient: AppTheme.purpleGradient,
            context: context,
          ),
          _buildDivider(context: context),
          _buildContactTile(
            label: 'Location',
            description: 'Islamabad, Pakistan',
            leadingIcon: AppAssets.locationIcon,
            iconBackgroundGradient: AppTheme.greenGradient,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required String label,
    required String description,
    required String leadingIcon,
    required Gradient iconBackgroundGradient,
    required BuildContext context,
  }) {
    final theme = Get.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 15.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: iconBackgroundGradient,
          ),
          child: SvgPicture.asset(
            leadingIcon,
            width: 20.w,
            height: 20.h,
            colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            SizedBox(height: 5.h),
            Text(description, style: theme.textTheme.headlineMedium),
          ],
        ),
        Spacer(),
        Icon(Icons.arrow_forward_ios, size: 15.sp),
      ],
    );
  }

  Widget _buildDivider({required BuildContext context}) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade400,
            Colors.grey.shade200,
            Colors.grey.shade400,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
