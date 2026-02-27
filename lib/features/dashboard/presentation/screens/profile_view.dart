import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/contact_information.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/presentation/widgets/profile_pin.dart';
import 'package:safelink/features/dashboard/presentation/widgets/recent_case.dart';
import 'package:safelink/features/dashboard/presentation/widgets/settings.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(30.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.white.withValues(alpha: 0.20),
                        border: Border.all(
                          color: AppTheme.white.withValues(alpha: 0.30),
                          width: 5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            offset: const Offset(0, 25),
                            blurRadius: 50.r,
                            spreadRadius: -12.r,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        AppAssets.personIcon,
                        width: 50.w,
                        height: 50.h,
                        colorFilter: ColorFilter.mode(
                          AppTheme.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Raja Hamid',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '+92 335 9004914',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
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
                        'Verified User',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.white,
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
                        ProfilePin(label: 'Active Requests', count: 2),
                        SizedBox(width: 10.w),
                        ProfilePin(label: 'Alerts Received', count: 5),
                        SizedBox(width: 10.w),
                        ProfilePin(label: 'Days \nSafe', count: 12),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      'Contact Information',
                      style: theme.textTheme.headlineLarge,
                    ),
                    SizedBox(height: 25.h),
                    ContactInformation(),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Cases',
                          style: theme.textTheme.headlineLarge,
                        ),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.displayMedium,
                            children: [
                              TextSpan(
                                text: 'View All',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Get.toNamed(''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    RecentCase(
                      label: 'Medical Aid',
                      status: 'Completed',
                      time: 'REQ-1234 • Oct 10,\n2025',
                    ),
                    SizedBox(height: 10.h),
                    RecentCase(
                      label: 'Food Supply',
                      status: 'In Progress',
                      time: 'REQ-1235 • Oct 11,\n2025',
                    ),
                    SizedBox(height: 25.h),
                    Text('Settings', style: theme.textTheme.headlineLarge),
                    SizedBox(height: 25.h),
                    Settings(),
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
