import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/controllers/case_tracking_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/case_card.dart';
import 'package:safelink/features/dashboard/presentation/widgets/segmented_filter_bar.dart';

class CaseTrackingView extends StatefulWidget {
  const CaseTrackingView({super.key});

  @override
  State<CaseTrackingView> createState() => _CaseTrackingViewState();
}

class _CaseTrackingViewState extends State<CaseTrackingView> {
  final CaseTrackingController controller = Get.put(CaseTrackingController());
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.primaryGradient,
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppTheme.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Case Tracking',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.cases.length} total requests',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.white.withValues(alpha: 0.80),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.toNamed('/reportIncidentView'),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  TextField(
                    controller: searchController,
                    onChanged: (val) => controller.searchQuery.value = val,
                    style: TextStyle(color: Colors.grey[900], fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search by ID, type, location...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 18.sp,
                      ),
                      filled: true,
                      fillColor: AppTheme.white.withValues(alpha: 0.90),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Obx(
                    () => SegmentedFilterBar(
                      filters: CaseTrackingController.filters,
                      selectedFilter: controller.activeFilter.value,
                      onFilterSelected: (val) =>
                          controller.activeFilter.value = val,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
              child: Obx(() {
                final _ = controller.cases.length;
                return Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'Active',
                        count: controller.activeCount,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatChip(
                        label: 'Progress',
                        count: controller.inProgressCount,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatChip(
                        label: 'Pending',
                        count: controller.pendingCount,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _StatChip(
                        label: 'Done',
                        count: controller.completedCount,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(() {
                final filtered = controller.filteredCases;

                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filtered.isEmpty) {
                  return Center(child: Text('No cases found'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => CaseCard(caseItem: filtered[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
