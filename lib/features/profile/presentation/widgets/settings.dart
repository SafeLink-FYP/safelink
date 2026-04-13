import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          InkWell(
            onTap: () => Get.toNamed('/settingsView'),
            borderRadius: BorderRadius.circular(10.r),
            child: _buildSettingTile(
              label: 'More Settings',
              leadingIcon: AppAssets.settingsIcon,
              trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
              context: context,
            ),
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
    final theme = Theme.of(context);
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
}
