import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/ml_alert_cards.dart';

class AlertsListView extends StatefulWidget {
  const AlertsListView({super.key});

  @override
  State<AlertsListView> createState() => _AlertsListViewState();
}

class _AlertsListViewState extends State<AlertsListView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final mlController = Get.find<MlAlertController>();
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
                        onTap: () => mlController.refresh(),
                        child: Icon(Icons.refresh, color: AppTheme.white,
                            size: 22.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _TabBar(
                    selectedIndex: _selectedTab,
                    onSelected: (i) => setState(() => _selectedTab = i),
                    tabs: const ['Earthquakes', 'Floods'],
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
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
          itemCount: controller.earthquakeAlerts.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return EarthquakeAlertCard(
              alert: controller.earthquakeAlerts[index],
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
