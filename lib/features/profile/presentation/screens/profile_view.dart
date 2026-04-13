import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';
import 'package:safelink/features/profile/presentation/widgets/contact_information_card.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/presentation/widgets/profile_pin.dart';
import 'package:safelink/features/dashboard/presentation/widgets/recent_case.dart';
import 'package:safelink/core/widgets/profile_avatar.dart';
import 'package:safelink/features/profile/presentation/widgets/settings_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final ImagePickingController _imagePickingController =
      Get.find<ImagePickingController>();
  final AidRequestController _aidRequestController =
      Get.find<AidRequestController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Column(
                  children: [
                    Obx(() {
                      final localImage =
                          _imagePickingController.selectedImage.value;
                      final avatarUrl = _profileController.avatarUrl;
                      return ProfileAvatar(
                        image: localImage != null
                            ? File(localImage.path)
                            : null,
                        imageUrl: localImage == null ? avatarUrl : null,
                      );
                    }),
                    Obx(
                      () => Text(
                        _profileController.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Obx(
                      () => Text(
                        _profileController.phone,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    InkWell(
                      onTap: () => Get.toNamed('editProfileView'),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppTheme.white.withValues(alpha: 0.30),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => ProfilePin(
                            label: 'Active Requests',
                            count: _profileController.activeRequestCount.value,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Obx(
                          () => ProfilePin(
                            label: 'Alerts Received',
                            count: _profileController.alertsReceivedCount.value,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Obx(
                          () => ProfilePin(
                            label: 'Days \nSafe',
                            count: _profileController.daysSafe.value,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      'Contact Information',
                      style: theme.textTheme.headlineLarge,
                    ),
                    SizedBox(height: 25.h),
                    ContactInformationCard(),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Cases',
                          style: theme.textTheme.headlineLarge,
                        ),
                        InkWell(
                          onTap: () => Get.toNamed('/caseTrackingView'),
                          child: Text(
                            'View All',
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Obx(() {
                      final requests = _aidRequestController.myRequests;
                      if (requests.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1.w,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No recent cases',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: requests.take(3).map((r) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: RecentCase(
                              label: r.type,
                              status: r.status,
                              time:
                                  'REQ-${r.id.substring(0, 4).toUpperCase()} • ${r.timeAgo}',
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(height: 25.h),
                    Text('Settings', style: theme.textTheme.headlineLarge),
                    SizedBox(height: 25.h),
                    SettingsCard(),
                    SizedBox(height: 25.h),
                    InkWell(
                      onTap: () => _authController.signOut(),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppTheme.transparentColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppTheme.red, width: 1.w),
                        ),
                        child: Text(
                          'Log Out',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppTheme.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
