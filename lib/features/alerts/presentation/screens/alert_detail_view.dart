import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/alerts/models/alert_model.dart';

class AlertDetailView extends StatelessWidget {
  const AlertDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final AlertModel alert = Get.arguments as AlertModel;
    final alertController = Get.find<AlertController>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientHeader(
                gradient: _getSeverityGradient(alert.severity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Icon(Icons.arrow_back, color: AppTheme.white),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: SvgPicture.asset(
                            alertController.getAlertIcon(alert.type),
                            width: 25.w,
                            height: 25.h,
                            colorFilter: ColorFilter.mode(
                              AppTheme.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white.withValues(
                                        alpha: 0.20,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      alert.severity.capitalizeFirst ?? '',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: AppTheme.white),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    alert.timeAgo,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      theme: theme,
                      title: 'Type',
                      value: alert.type.capitalizeFirst ?? 'Unknown',
                      icon: Icons.category,
                    ),
                    SizedBox(height: 15.h),
                    if (alert.location != null)
                      _buildInfoSection(
                        theme: theme,
                        title: 'Location',
                        value: alert.location!,
                        icon: Icons.location_on,
                      ),
                    if (alert.location != null) SizedBox(height: 15.h),
                    if (alert.description.isNotEmpty) ...[
                      Text('Description', style: theme.textTheme.headlineLarge),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          alert.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 15.h),
                    ],
                    if (alert.issuedBy != null)
                      _buildInfoSection(
                        theme: theme,
                        title: 'Issued By',
                        value: alert.issuedBy!,
                        icon: Icons.person,
                      ),
                    SizedBox(height: 25.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: _getSeverityBgColor(alert.severity),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _getSeverityColor(
                            alert.severity,
                          ).withValues(alpha: 0.30),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getSeverityColor(alert.severity),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Stay informed and follow safety guidelines from local authorities.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _getSeverityColor(alert.severity),
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

  Widget _buildInfoSection({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Icon(icon, color: AppTheme.white, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall),
              SizedBox(height: 3.h),
              Text(value, style: theme.textTheme.headlineMedium),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getSeverityGradient(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.redGradient;
      case 'medium':
        return AppTheme.orangeGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'medium':
        return AppTheme.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getSeverityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.lightRed;
      case 'medium':
        return AppTheme.lightOrange;
      default:
        return const Color(0xFFEFF6FF);
    }
  }
}
