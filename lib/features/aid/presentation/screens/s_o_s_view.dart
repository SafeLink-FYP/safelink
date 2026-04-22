import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/constants/emergency_constants.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/dashboard/controllers/emergency_contact_controller.dart';
import 'package:safelink/features/aid/controllers/s_o_s_controller.dart';
import 'package:safelink/features/aid/models/s_o_s_request_model.dart';
import 'package:safelink/features/dashboard/presentation/widgets/emergency_contact.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';

class SOSView extends StatefulWidget {
  const SOSView({super.key});

  @override
  State<SOSView> createState() => _SOSViewState();
}

class _SOSViewState extends State<SOSView> {
  final SOSController sosController = Get.find<SOSController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final EmergencyContactController emergencyContactController =
      Get.find<EmergencyContactController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    children: SOSType.values.map((type) {
                      final isSelected =
                          sosController.selectedType.value == type;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: GestureDetector(
                            onTap: () =>
                                sosController.selectedType.value = type,
                            child: Container(
                              padding: EdgeInsets.all(15.r),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? _getTypeGradient(type)
                                    : null,
                                color: isSelected ? null : theme.cardColor,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : theme.dividerColor,
                                  width: 1.w,
                                ),
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    _getTypeIcon(type),
                                    height: 25.h,
                                    width: 25.w,
                                    colorFilter: ColorFilter.mode(
                                      isSelected
                                          ? AppTheme.white
                                          : theme.primaryIconTheme.color!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    type.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected ? AppTheme.white : null,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 25.w),
                child: Column(
                  children: [
                    Obx(() {
                      final hasActive =
                          sosController.activeRequest.value != null;

                      return GestureDetector(
                        onTap: hasActive
                            ? () => DialogHelpers.showSOSDialog(
                                context: context,
                                onPressed: () {
                                  Get.back();
                                  sosController.cancelSOS();
                                },
                              )
                            : () => sosController.sendSOS(),
                        child: AnimatedScale(
                          scale: hasActive ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Container(
                            padding: EdgeInsets.all(50.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: hasActive
                                  ? AppTheme.orangeGradient
                                  : AppTheme.redGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 25),
                                  blurRadius: 50.r,
                                  spreadRadius: -12.r,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.warningIcon,
                                  width: 80.w,
                                  height: 80.h,
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  hasActive ? 'SOS Active' : 'Press for SOS',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(color: AppTheme.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 15.h),
                    Text(
                      'Press to send emergency alert to nearby\nauthorities and relief teams',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Emergency Contacts',
                          style: theme.textTheme.headlineLarge,
                        ),
                        InkWell(
                          onTap: () => Get.toNamed('/emergencyContactsView'),
                          child: Text(
                            'Manage',
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Obx(() {
                      final userContacts = emergencyContactController.contacts;
                      final contactsToShow = [
                        ...userContacts.take(3),
                        ...predefinedEmergencyContacts,
                      ];
                      return Column(
                        children: contactsToShow
                            .map(
                              (c) => Padding(
                                padding: EdgeInsets.only(bottom: 15.h),
                                child: EmergencyContact(
                                  label: c.name,
                                  description: c.phone,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeIcon(SOSType type) {
    switch (type) {
      case SOSType.medical:
        return AppAssets.heartIcon;
      case SOSType.flood:
        return AppAssets.dropletsIcon;
      case SOSType.earthquake:
        return AppAssets.waveIcon;
    }
  }

  LinearGradient _getTypeGradient(SOSType type) {
    switch (type) {
      case SOSType.medical:
        return AppTheme.redGradient;
      case SOSType.flood:
        return AppTheme.primaryGradient;
      case SOSType.earthquake:
        return AppTheme.orangeGradient;
    }
  }
}
