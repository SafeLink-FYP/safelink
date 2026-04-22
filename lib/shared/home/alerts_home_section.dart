import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/alerts/presentation/widgets/active_alert.dart';
import 'package:safelink/core/widgets/animated_press_effect.dart';

class AlertsHomeSection extends StatelessWidget {
  final AlertController alertController;
  final Color Function(String severity) severityColor;
  final Color Function(String severity) severityBgColor;

  const AlertsHomeSection({
    super.key,
    required this.alertController,
    required this.severityColor,
    required this.severityBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (alertController.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        );
      }
      if (alertController.alerts.isEmpty) {
        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppTheme.green.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.green,
                size: 25.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'No active alerts in your area',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.green,
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        children: alertController.alerts.take(3).toList().map((alert) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: AnimatedPressEffect(
              onTap: () => Get.toNamed('/alertDetailView', arguments: alert),
              child: ActiveAlert(
                label: alert.title,
                location: alert.location ?? 'Unknown',
                time: alert.timeAgo,
                alertLevel: alert.severity.capitalizeFirst ?? 'Low',
                icon: alertController.getAlertIcon(alert.type),
                iconColor: severityColor(alert.severity),
                iconBackgroundColor: severityBgColor(alert.severity),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
