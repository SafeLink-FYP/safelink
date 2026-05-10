import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/alerts/models/alert_model.dart';

/// Renders the government-issued alerts section of the citizen dashboard.
/// Companion to [PredictedAlertsHomeSection]; gov alerts render ABOVE
/// predictions to convey authority.
///
/// Consumes the citizen-side `AlertController` (rewritten in
/// Active-Alerts-split to load from `alerts` table via AlertService +
/// subscribe to realtime updates). Each card carries a 'GOVERNMENT'
/// badge with a shield icon so citizens distinguish official broadcasts
/// from ML predictions in the section below.
class GovAlertsHomeSection extends StatelessWidget {
  final AlertController controller;

  const GovAlertsHomeSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.isLoading.value && !controller.hasLoadedOnce.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        );
      }

      final visible = controller.alerts.take(3).toList();

      if (visible.isEmpty) {
        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15.r),
            border:
                Border.all(color: AppTheme.green.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppTheme.green, size: 25.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'No active alerts for your area',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.green),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: List.generate(visible.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildGovAlertCard(context, theme, visible[i]),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: (i * 80).ms)
              .slideY(begin: 0.10, end: 0);
        }),
      );
    });
  }

  Widget _buildGovAlertCard(
    BuildContext context,
    ThemeData theme,
    AlertModel alert,
  ) {
    final severityColor = _severityColor(alert.severity);
    final severityBg = severityColor.withValues(alpha: 0.12);
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.alertDetailView, arguments: alert),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: severityColor.withValues(alpha: 0.30),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: severityBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: SvgPicture.asset(
                    controller.getAlertIcon(alert.type),
                    width: 20.w,
                    height: 20.h,
                    colorFilter:
                        ColorFilter.mode(severityColor, BlendMode.srcIn),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reserve room on the right for the badge overlay
                      // so long titles don't collide with the chip.
                      Padding(
                        padding: EdgeInsets.only(right: 70.w),
                        child: Text(
                          alert.title,
                          style: theme.textTheme.headlineMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        alert.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: severityBg,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              alert.severity.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: severityColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            alert.timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 'GOVERNMENT' badge top-right, mirrors the 'PREDICTION'
          // badge on ML cards but uses a shield icon + primary color
          // tint to convey authority rather than probability.
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.40),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 10.sp,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'GOVERNMENT',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'high':
        return AppTheme.orange;
      case 'medium':
        return AppTheme.amber;
      case 'low':
        return AppTheme.green;
      default:
        return AppTheme.orange;
    }
  }
}
