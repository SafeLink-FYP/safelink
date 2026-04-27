import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';

// ─── Earthquake card ──────────────────────────────────────────────────────────

class EarthquakeAlertCard extends StatefulWidget {
  final EarthquakeAlertModel alert;
  final bool expandable;

  const EarthquakeAlertCard({
    super.key,
    required this.alert,
    this.expandable = true,
  });

  @override
  State<EarthquakeAlertCard> createState() => _EarthquakeAlertCardState();
}

class _EarthquakeAlertCardState extends State<EarthquakeAlertCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alert = widget.alert;
    final severityColor = magColor(alert.mainshockMagnitude);
    final severityBg = magBgColor(alert.mainshockMagnitude);

    return GestureDetector(
      onTap: () => Get.toNamed('/earthquakeAlertDetailView', arguments: alert),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: severityBg,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.waveIcon,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.mainshockLocation.isNotEmpty
                                    ? alert.mainshockLocation
                                    : 'Unknown Location',
                                style: theme.textTheme.headlineMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: severityBg,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                alert.magnitudeLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: severityColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${alert.distanceToUserKm.toStringAsFixed(0)} km away  •  '
                          '${alert.predictedAftershocks.length} aftershock(s) predicted',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.expandable) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_expanded && widget.expandable) ...[
              Divider(height: 1.h, color: theme.dividerColor),
              AftershockList(
                  aftershocks: alert.predictedAftershocks, theme: theme),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Aftershock list ──────────────────────────────────────────────────────────

class AftershockList extends StatelessWidget {
  final List<AftershockModel> aftershocks;
  final ThemeData theme;

  const AftershockList({
    super.key,
    required this.aftershocks,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (aftershocks.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(15.r),
        child: Text(
          'No significant aftershocks predicted.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.w, 12.h, 15.w, 6.h),
          child: Text(
            'Predicted Aftershocks',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        ...aftershocks.map((as_) {
          final pct = as_.likelihoodPercent;
          final color = pct >= 70
              ? AppTheme.red
              : pct >= 40
                  ? AppTheme.orange
                  : AppTheme.primaryColor;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
            child: Row(
              children: [
                Container(
                  width: 22.w,
                  height: 22.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${as_.rank}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'M${as_.magnitude.toStringAsFixed(1)}  ·  '
                    'Depth ${as_.depthKm.toStringAsFixed(0)} km',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$pct% likely',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 6.h),
      ],
    );
  }
}

// ─── Flood risk card ──────────────────────────────────────────────────────────

class FloodRiskCard extends StatelessWidget {
  final FloodAlertModel flood;

  const FloodRiskCard({super.key, required this.flood});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = floodRiskColor(flood.riskLevel);
    final levelBg = floodRiskBgColor(flood.riskLevel);

    return GestureDetector(
      onTap: () => Get.toNamed('/floodAlertDetailView', arguments: flood),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coloured header
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                color: levelBg,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.dropletsIcon,
                      width: 22.w,
                      height: 22.h,
                      colorFilter:
                          ColorFilter.mode(levelColor, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flood Risk Assessment',
                          style: theme.textTheme.headlineLarge
                              ?.copyWith(color: levelColor),
                        ),
                        if (flood.dataDate != null)
                          Text(
                            flood.dataDate!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: levelColor.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: levelColor.withValues(alpha: 0.30)),
                    ),
                    child: Text(
                      flood.riskLevel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h, color: theme.dividerColor),
            // Risk score + details
            Padding(
              padding: EdgeInsets.all(15.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Risk Score', style: theme.textTheme.bodyMedium),
                      Text(
                        '${flood.riskPercent}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: levelColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: LinearProgressIndicator(
                      value: (flood.riskScore / 100).clamp(0.0, 1.0),
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                      minHeight: 8.h,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _infoRow(
                    theme: theme,
                    icon: Icons.water_drop,
                    label: 'Rainfall',
                    value: '${flood.rainfallMm.toStringAsFixed(1)} mm',
                  ),
                  if (flood.affectedAreas.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text('Affected Areas', style: theme.textTheme.bodyMedium),
                    SizedBox(height: 6.h),
                    ...flood.affectedAreas.map(
                      (area) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14.sp, color: levelColor),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(area,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (flood.shouldAlert) ...[
              Divider(height: 1.h, color: theme.dividerColor),
              Padding(
                padding: EdgeInsets.all(15.r),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: levelColor, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Active flood risk — monitor local authorities'
                        ' and avoid low-lying areas.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: levelColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: theme.hintColor),
        SizedBox(width: 8.w),
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(value, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

// ─── Shared color helpers ─────────────────────────────────────────────────────

Color magColor(double mag) {
  if (mag >= 7.0) return AppTheme.red;
  if (mag >= 5.5) return AppTheme.orange;
  if (mag >= 4.0) return const Color(0xFFE17100);
  return AppTheme.primaryColor;
}

Color magBgColor(double mag) {
  if (mag >= 7.0) return AppTheme.lightRed;
  if (mag >= 5.5) return AppTheme.lightOrange;
  if (mag >= 4.0) return AppTheme.lightOrange;
  return const Color(0xFFEFF6FF);
}

Color floodRiskColor(String level) {
  switch (level.toUpperCase()) {
    case 'CRITICAL':
      return AppTheme.red;
    case 'HIGH':
      return AppTheme.orange;
    case 'MODERATE':
      return const Color(0xFFE17100);
    default:
      return AppTheme.green;
  }
}

Color floodRiskBgColor(String level) {
  switch (level.toUpperCase()) {
    case 'CRITICAL':
      return AppTheme.lightRed;
    case 'HIGH':
    case 'MODERATE':
      return AppTheme.lightOrange;
    default:
      return const Color(0xFFECFDF5);
  }
}
