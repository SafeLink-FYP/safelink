import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/ml_alert_cards.dart';

/// Renders the ML-prediction section of the citizen dashboard. Companion
/// to [GovAlertsHomeSection] which renders authoritative government
/// alerts above this. The 'PREDICTION' badge overlay on each card
/// visually distinguishes probabilistic ML output from gov broadcasts.
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
      final loading = mlController.isLoadingEarthquakes.value ||
          mlController.isLoadingHeatmap.value;

      if (loading) {
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

      final earthquakes = mlController.earthquakeAlerts;
      final flood = mlController.floodAlert.value;

      if (earthquakes.isEmpty && flood == null) {
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
                  'No active predictions for your area',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.green),
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
            child: _wrapWithPredictionBadge(
              EarthquakeAlertCard(alert: earthquakes[i]),
            ),
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
            child: _wrapWithPredictionBadge(FloodRiskCard(flood: flood)),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: (items.length * 80).ms)
              .slideY(begin: 0.10, end: 0),
        );
      }

      return Column(children: items);
    });
  }

  /// Overlays a small 'PREDICTION' chip in the top-right of each ML
  /// alert card. Non-invasive: ml_alert_cards.dart is shared with
  /// AlertsListView's Earthquakes / Floods tabs (which don't need the
  /// badge because the tab label already conveys "ML"), so the badge
  /// is added at the consumer level here, not in the card widgets.
  Widget _wrapWithPredictionBadge(Widget card) {
    return Stack(
      children: [
        card,
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.amber.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: AppTheme.amber.withValues(alpha: 0.40),
                width: 1.w,
              ),
            ),
            child: Text(
              'PREDICTION',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.amber,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
