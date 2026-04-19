import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink/core/themes/app_theme.dart';

class SegmentedFilterBar extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const SegmentedFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50.r),
      ),
      height: 50.h,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.white.withValues(alpha: 0.20)
                      : AppTheme.transparentColor,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
