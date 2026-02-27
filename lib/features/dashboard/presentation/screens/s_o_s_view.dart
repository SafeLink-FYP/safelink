import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/presentation/widgets/emergency_contact.dart';
import 'package:safelink/core/widgets/gradient_header.dart';

class SOSView extends StatefulWidget {
  const SOSView({super.key});

  @override
  State<SOSView> createState() => _SOSViewState();
}

class _SOSViewState extends State<SOSView> {
  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientHeader(
                gradient: AppTheme.redGradient,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      AppAssets.warningIcon,
                      width: 50.w,
                      height: 50.h,
                      colorFilter: ColorFilter.mode(
                        AppTheme.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Emergency SOS',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Get immediate help in emergencies',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.redGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            offset: const Offset(0, 25),
                            blurRadius: 50.r,
                            spreadRadius: -12.r,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            AppAssets.warningIcon,
                            width: 80.w,
                            height: 80.h,
                            colorFilter: ColorFilter.mode(
                              AppTheme.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Press for SOS',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Press to send emergency alert to nearby\nauthorities and relief teams',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Emergency Contacts',
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    EmergencyContact(
                      label: 'Rescue 1122',
                      description: 'Emergency Hotline',
                    ),
                    SizedBox(height: 15.h),
                    EmergencyContact(
                      label: 'NDMA Helpline',
                      description: 'Disaster Management',
                    ),
                    SizedBox(height: 25.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Information',
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Container(
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.transparentColor.withValues(
                              alpha: 0.10,
                            ),
                            offset: const Offset(0, 1),
                            blurRadius: 3.r,
                            spreadRadius: 0.r,
                          ),
                          BoxShadow(
                            color: AppTheme.transparentColor.withValues(
                              alpha: 0.10,
                            ),
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
                              colorFilter: ColorFilter.mode(
                                AppTheme.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Raja Hamid',
                                style: theme.textTheme.headlineMedium,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '+92 335 9004914',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Spacer(),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                AppTheme.green,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              'Edit',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
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
