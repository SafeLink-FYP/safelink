import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/models/ml_alert_models.dart';

class EarthquakeAlertDetailView extends StatelessWidget {
  const EarthquakeAlertDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final EarthquakeAlertModel alert =
        Get.arguments as EarthquakeAlertModel;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: alert.shouldAlert
                  ? AppTheme.redGradient
                  : AppTheme.orangeGradient,
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
                          AppAssets.waveIcon,
                          width: 25.w,
                          height: 25.h,
                          colorFilter: const ColorFilter.mode(
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
                              alert.mainshockLocation.isNotEmpty
                                  ? alert.mainshockLocation
                                  : 'Earthquake Alert',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppTheme.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                _badge(alert.magnitudeLabel, theme),
                                SizedBox(width: 8.w),
                                _badge(alert.severity, theme),
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Mainshock Details', theme),
                    SizedBox(height: 12.h),
                    _infoCard(
                      theme: theme,
                      items: [
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: alert.mainshockLocation.isNotEmpty
                              ? alert.mainshockLocation
                              : 'Unknown',
                        ),
                        _InfoRow(
                          icon: Icons.bolt,
                          label: 'Magnitude',
                          value: alert.magnitudeLabel,
                        ),
                        _InfoRow(
                          icon: Icons.layers,
                          label: 'Depth',
                          value:
                              '${alert.mainshockDepthKm.toStringAsFixed(1)} km',
                        ),
                        _InfoRow(
                          icon: Icons.near_me,
                          label: 'Distance from you',
                          value:
                              '${alert.distanceToUserKm.toStringAsFixed(1)} km',
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _sectionTitle(
                      'Predicted Aftershocks (${alert.predictedAftershocks.length})',
                      theme,
                    ),
                    SizedBox(height: 12.h),
                    if (alert.predictedAftershocks.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppTheme.green.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: AppTheme.green),
                            SizedBox(width: 8.w),
                            Text(
                              'No significant aftershocks predicted.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._buildAftershockTable(
                          alert.predictedAftershocks, theme),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppTheme.orange.withValues(alpha: 0.30),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.orange),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Aftershocks can occur hours to days after the mainshock. '
                              'Stay alert and avoid damaged structures.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAftershockTable(
    List<AftershockModel> aftershocks,
    ThemeData theme,
  ) {
    return [
      Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
        ),
        child: Column(
          children: [
            _tableHeader(theme),
            ...aftershocks.asMap().entries.map((entry) {
              final i = entry.key;
              final as_ = entry.value;
              return _tableRow(as_, i.isOdd, theme);
            }),
          ],
        ),
      ),
    ];
  }

  Widget _tableHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
      ),
      child: Row(
        children: [
          _headerCell('#', theme, flex: 1),
          _headerCell('Magnitude', theme, flex: 3),
          _headerCell('Depth', theme, flex: 3),
          _headerCell('Likelihood', theme, flex: 3),
        ],
      ),
    );
  }

  Widget _tableRow(AftershockModel as_, bool shaded, ThemeData theme) {
    final likelihood = as_.likelihoodPercent;
    final color = likelihood >= 70
        ? AppTheme.red
        : likelihood >= 40
            ? AppTheme.orange
            : AppTheme.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      color: shaded ? theme.dividerColor.withValues(alpha: 0.40) : null,
      child: Row(
        children: [
          _cell('${as_.rank}', theme, flex: 1),
          _cell('M${as_.magnitude.toStringAsFixed(1)}', theme, flex: 3,
              bold: true),
          _cell('${as_.depthKm.toStringAsFixed(0)} km', theme, flex: 3),
          Expanded(
            flex: 3,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '$likelihood%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, ThemeData theme, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _cell(String text, ThemeData theme,
      {int flex = 1, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _infoCard({
    required ThemeData theme,
    required List<_InfoRow> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor, width: 1.w),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final row = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 15.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: Icon(row.icon,
                          color: AppTheme.white, size: 16.sp),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.label,
                            style: theme.textTheme.bodySmall),
                        SizedBox(height: 2.h),
                        Text(row.value,
                            style: theme.textTheme.headlineMedium),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1.h,
                    thickness: 1.h,
                    color: theme.dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String text, ThemeData theme) {
    return Text(text, style: theme.textTheme.headlineLarge);
  }

  Widget _badge(String label, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.white),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}
