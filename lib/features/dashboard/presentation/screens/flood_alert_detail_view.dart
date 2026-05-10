import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';
import 'package:safelink/features/dashboard/presentation/widgets/ml_alert_cards.dart';

class FloodAlertDetailView extends StatelessWidget {
  const FloodAlertDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final FloodAlertModel flood = Get.arguments as FloodAlertModel;
    final theme = Theme.of(context);
    final levelColor = floodRiskColor(flood.riskLevel);

    LinearGradient headerGradient;
    switch (flood.riskLevel.toUpperCase()) {
      case 'CRITICAL':
        headerGradient = AppTheme.redGradient;
        break;
      case 'HIGH':
      case 'MODERATE':
        headerGradient = AppTheme.orangeGradient;
        break;
      default:
        headerGradient = AppTheme.primaryGradient;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientHeader(
                gradient: headerGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back,
                          color: AppTheme.white),
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
                          child: Icon(Icons.water_drop,
                              color: AppTheme.white, size: 24.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flood Risk — ${flood.riskLevel}',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(color: AppTheme.white),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white
                                          .withValues(alpha: 0.20),
                                      borderRadius:
                                          BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      '${flood.riskPercent}% risk',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.white),
                                    ),
                                  ),
                                  if (flood.dataDate != null) ...[
                                    SizedBox(width: 8.w),
                                    Text(
                                      flood.dataDate!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.white),
                                    ),
                                  ],
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
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Risk score bar
                    _sectionCard(
                      theme: theme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Risk Score',
                                  style: theme.textTheme.headlineLarge),
                              Text(
                                '${flood.riskPercent}%',
                                style: theme.textTheme.headlineLarge
                                    ?.copyWith(
                                  color: levelColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child: LinearProgressIndicator(
                              value:
                                  (flood.riskScore / 100).clamp(0.0, 1.0),
                              backgroundColor: theme.dividerColor,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(levelColor),
                              minHeight: 10.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Rainfall
                    _sectionCard(
                      theme: theme,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.water_drop,
                                color: AppTheme.primaryColor, size: 18.sp),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rainfall (last 7 days)',
                                  style: theme.textTheme.bodySmall),
                              SizedBox(height: 2.h),
                              Text(
                                '${flood.rainfallMm.toStringAsFixed(1)} mm',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (flood.affectedAreas.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text('Affected Areas',
                          style: theme.textTheme.headlineLarge),
                      SizedBox(height: 10.h),
                      ...flood.affectedAreas.map(
                        (area) => Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                                color: theme.dividerColor, width: 1.w),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 18.sp, color: levelColor),
                              SizedBox(width: 10.w),
                              Text(area,
                                  style: theme.textTheme.headlineSmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    // Advisory
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: levelColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: levelColor, size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              flood.shouldAlert
                                  ? 'Active flood risk detected. Monitor'
                                      ' local authorities, avoid low-lying'
                                      ' areas, and keep emergency contacts'
                                      ' informed.'
                                  : 'Flood risk is currently low. Stay'
                                      ' informed and monitor local weather'
                                      ' updates.',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: levelColor),
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

  Widget _sectionCard(
      {required ThemeData theme, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor, width: 1.w),
      ),
      child: child,
    );
  }
}
