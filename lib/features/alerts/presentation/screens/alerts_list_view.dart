import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/alerts/models/alert_model.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/ml_alert_cards.dart';

/// All-alerts list view. Post-Active-Alerts-split this has THREE tabs:
///   - Official:    gov-issued alerts (via AlertController)
///   - Earthquakes: ML earthquake predictions (via MlAlertController)
///   - Floods:      ML flood predictions (via MlAlertController)
///
/// Initial tab can be selected by the caller via Get.arguments
/// `{'tab': 0|1|2}`. Defaults to Official (0). Dashboard's gov section
/// "View All" passes 0; dashboard's predicted section "View All" passes 1.
class AlertsListView extends StatefulWidget {
  const AlertsListView({super.key});

  @override
  State<AlertsListView> createState() => _AlertsListViewState();
}

class _AlertsListViewState extends State<AlertsListView> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      final t = args['tab'] as int;
      if (t >= 0 && t <= 2) _selectedTab = t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mlController = Get.find<MlAlertController>();
    final alertController = Get.find<AlertController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.redGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          // Refresh whichever tab is active.
                          switch (_selectedTab) {
                            case 0:
                              alertController.refreshAlerts();
                              break;
                            case 1:
                              mlController.loadEarthquakeAlerts();
                              break;
                            case 2:
                              mlController.loadFloodHeatmap();
                              break;
                          }
                        },
                        child: Icon(Icons.refresh, color: AppTheme.white,
                            size: 22.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _TabBar(
                    selectedIndex: _selectedTab,
                    onSelected: (i) => setState(() => _selectedTab = i),
                    tabs: const ['Official', 'Earthquakes', 'Floods'],
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _OfficialTab(controller: alertController, theme: theme),
                  _EarthquakesTab(controller: mlController, theme: theme),
                  _FloodsTab(controller: mlController, theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab bar ────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<String> tabs;

  const _TabBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tabs.asMap().entries.map((entry) {
        final selected = entry.key == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(entry.key),
          child: Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.white
                  : AppTheme.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.red : AppTheme.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Official tab (gov-issued alerts) ────────────────────────────────────────

class _OfficialTab extends StatelessWidget {
  final AlertController controller;
  final ThemeData theme;

  const _OfficialTab({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && !controller.hasLoadedOnce.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.alerts.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshAlerts,
          child: ListView(
            children: [
              SizedBox(height: 100.h),
              _emptyState(
                icon: Icons.check_circle_outline,
                color: AppTheme.green,
                title: 'No active alerts',
                subtitle: 'No government alerts active in your area',
                theme: theme,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshAlerts,
        child: ListView.separated(
          padding: EdgeInsets.all(20.r),
          itemCount: controller.alerts.length + 1,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        size: 14.sp, color: theme.hintColor),
                    SizedBox(width: 6.w),
                    Text(
                      '${controller.alerts.length} active gov alert(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            final alert = controller.alerts[index - 1];
            return _OfficialAlertCard(
              alert: alert,
              controller: controller,
              theme: theme,
            );
          },
        ),
      );
    });
  }
}

class _OfficialAlertCard extends StatelessWidget {
  final AlertModel alert;
  final AlertController controller;
  final ThemeData theme;

  const _OfficialAlertCard({
    required this.alert,
    required this.controller,
    required this.theme,
  });

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

  @override
  Widget build(BuildContext context) {
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
                        maxLines: 3,
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
}

// ─── Earthquakes tab ─────────────────────────────────────────────────────────

class _EarthquakesTab extends StatelessWidget {
  final MlAlertController controller;
  final ThemeData theme;

  const _EarthquakesTab({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingEarthquakes.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.earthquakeAlerts.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadEarthquakeAlerts,
          child: ListView(
            children: [
              SizedBox(height: 100.h),
              _emptyState(
                icon: Icons.check_circle_outline,
                color: AppTheme.green,
                title: 'No earthquake activity',
                subtitle: 'No significant earthquakes detected nearby',
                theme: theme,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadEarthquakeAlerts,
        child: ListView.separated(
          padding: EdgeInsets.all(20.r),
          itemCount: controller.earthquakeAlerts.length + 1,
          separatorBuilder: (_, i) =>
              i == 0 ? SizedBox(height: 12.h) : SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 14.sp, color: theme.hintColor),
                    SizedBox(width: 6.w),
                    Text(
                      'Past 24 hours — ${controller.earthquakeAlerts.length} event(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return EarthquakeAlertCard(
              alert: controller.earthquakeAlerts[index - 1],
            );
          },
        ),
      );
    });
  }
}

// ─── Floods tab ──────────────────────────────────────────────────────────────

class _FloodsTab extends StatelessWidget {
  final MlAlertController controller;
  final ThemeData theme;

  const _FloodsTab({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHeatmap.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final flood = controller.floodAlert.value;
      if (flood == null) {
        final hasData = controller.heatmapPoints.isNotEmpty;
        return RefreshIndicator(
          onRefresh: controller.loadFloodHeatmap,
          child: ListView(
            children: [
              SizedBox(height: 100.h),
              _emptyState(
                icon: hasData
                    ? Icons.check_circle_outline
                    : Icons.cloud_off,
                color: hasData ? AppTheme.green : theme.hintColor,
                title: hasData
                    ? 'No active flood risk'
                    : 'No flood data',
                subtitle: hasData
                    ? 'No elevated flood risk detected across Pakistan'
                    : 'Could not fetch flood risk from server',
                theme: theme,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadFloodHeatmap,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            FloodRiskCard(flood: flood),
          ],
        ),
      );
    });
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

Widget _emptyState({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required ThemeData theme,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60.sp, color: color),
        SizedBox(height: 15.h),
        Text(title, style: theme.textTheme.headlineLarge),
        SizedBox(height: 5.h),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    ),
  );
}
