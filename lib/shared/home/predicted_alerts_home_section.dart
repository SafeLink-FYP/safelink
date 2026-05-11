import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/ml_alert_cards.dart';

/// Renders the ML-prediction section of the citizen dashboard. Companion
/// to [GovAlertsHomeSection] which renders authoritative government
/// alerts above this.
///
/// Pre-Active-Alerts-split this widget was `AlertsHomeSection` and was
/// the dashboard's only alerts surface — conflating ML predictions with
/// government broadcasts. The split renames this to "Predicted Alerts"
/// and keeps it functionally unchanged below the new gov section.
class PredictedAlertsHomeSection extends StatelessWidget {
  final MlAlertController mlController;

  const PredictedAlertsHomeSection({super.key, required this.mlController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final loading =
          mlController.isLoadingEarthquakes.value ||
          mlController.isLoadingHeatmap.value;

      if (loading) {
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

      final earthquakes = mlController.earthquakeAlerts;
      final flood = mlController.floodAlert.value;

      if (earthquakes.isEmpty && flood == null) {
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
              Expanded(
                child: Text(
                  'No active predictions for your area',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.green,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final items = <Widget>[];

      for (int i = 0; i < earthquakes.length && i < 2; i++) {
        items.add(
          Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: EarthquakeAlertCard(alert: earthquakes[i]),
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: (i * 80).ms)
              .slideY(begin: 0.10, end: 0),
        );
      }

      if (flood != null) {
        items.add(
          Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: FloodRiskCard(flood: flood),
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: (items.length * 80).ms)
              .slideY(begin: 0.10, end: 0),
        );
      }

      return Column(children: items);
    });
  }
}
