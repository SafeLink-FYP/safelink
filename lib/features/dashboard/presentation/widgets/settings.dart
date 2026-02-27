import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/presentation/widgets/theme_toggle.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

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
          _buildSettingTile(
            label: 'Notifications',
            leadingIcon: AppAssets.notificationIcon,
            trailing: Icon(Icons.arrow_forward_ios, size: 15.sp),
            context: context,
          ),
          _buildDivider(context: context),
          _buildSettingTile(
            label: 'Location Services',
            leadingIcon: AppAssets.locationIcon,
            trailing: Icon(Icons.arrow_forward_ios, size: 15.sp),
            context: context,
          ),
          _buildDivider(context: context),
          _buildSettingTile(
            label: 'Emergency Contacts',
            leadingIcon: AppAssets.waveIcon,
            trailing: Icon(Icons.arrow_forward_ios, size: 15.sp),
            context: context,
          ),
          _buildDivider(context: context),
          _buildSettingTile(
            label: 'App Settings',
            leadingIcon: AppAssets.settingsIcon,
            trailing: Icon(Icons.arrow_forward_ios, size: 15.sp),
            context: context,
          ),
          _buildDivider(context: context),
          _buildSettingTile(
            label: 'Theme',
            leadingIcon: AppAssets.settingsIcon,
            trailing: ThemeToggle(),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String label,
    required String leadingIcon,
    required Widget trailing,
    required BuildContext context,
  }) {
    final theme = Get.theme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 15.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: SvgPicture.asset(
            leadingIcon,
            width: 20.w,
            height: 20.h,
            colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: 10.w),
        Text(label, style: theme.textTheme.headlineMedium),
        Spacer(),
        trailing,
      ],
    );
  }

  Widget _buildDivider({required BuildContext context}) {
    return Container(
      height: 1.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
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
