import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/custom_divider.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';

class ContactInformation extends StatefulWidget {
  const ContactInformation({super.key});

  @override
  State<ContactInformation> createState() => _ContactInformationState();
}

class _ContactInformationState extends State<ContactInformation> {
  final ProfileController profileController = Get.find<ProfileController>();

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
          Obx(
            () => _buildContactTile(
              label: 'Phone',
              description: profileController.phone,
              leadingIcon: AppAssets.phoneIcon,
              iconBackgroundGradient: AppTheme.primaryGradient,
              context: context,
            ),
          ),
          CustomDivider(),
          Obx(
            () => _buildContactTile(
              label: 'Email',
              description: profileController.email,
              leadingIcon: AppAssets.emailIcon,
              iconBackgroundGradient: AppTheme.purpleGradient,
              context: context,
            ),
          ),
          CustomDivider(),
          _buildContactTile(
            label: 'Location',
            description: 'Islamabad, Pakistan',
            leadingIcon: AppAssets.locationIcon,
            trailingWidget: InkWell(
              onTap: () {},
              child: Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryIconTheme.color,
                size: 20.sp,
              ),
            ),
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
    Widget? trailingWidget,
    required Gradient iconBackgroundGradient,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
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
        if (trailingWidget != null) trailingWidget,
      ],
    );
  }
}
