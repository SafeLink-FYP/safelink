import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/alerts/presentation/widgets/active_alert.dart';

class AlertsListView extends StatelessWidget {
  const AlertsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AlertController>();
    controller.loadAllAlerts();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.redGradient,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, color: AppTheme.white),
                  ),
                  SizedBox(width: 15.w),
                  Text(
                    'All Alerts',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 60.sp,
                          color: AppTheme.green,
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          'No active alerts',
                          style: theme.textTheme.headlineLarge,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Your area is currently safe',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshAlerts,
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: controller.alerts.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final alert = controller.alerts[index];
                      return InkWell(
                        onTap: () =>
                            Get.toNamed('/alertDetailView', arguments: alert),
                        child: ActiveAlert(
                          label: alert.title,
                          location: alert.location ?? 'Unknown',
                          time: alert.timeAgo,
                          alertLevel: alert.severity.capitalizeFirst ?? 'Low',
                          icon: controller.getAlertIcon(alert.type),
                          iconColor: _getSeverityColor(alert.severity),
                          iconBackgroundColor: _getSeverityBgColor(
                            alert.severity,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
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
      case 'high':
        return AppTheme.lightRed;
      case 'medium':
        return AppTheme.lightOrange;
      default:
        return const Color(0xFFEFF6FF);
    }
  }
}
