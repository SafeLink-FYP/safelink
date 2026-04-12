import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/controllers/preparedness_controller.dart';

class PreparednessView extends StatelessWidget {
  const PreparednessView({super.key});

  @override
  Widget build(BuildContext context) {
    final PreparednessController controller = Get.put(PreparednessController());
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                                'Preparedness Checklist',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.white,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${controller.checkedItems} of ${controller.totalItems} items ready',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.white.withValues(
                                      alpha: 0.80,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Obx(() {
                        final progress = controller.progressPercent;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Overall Readiness',
                                  style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  '$progress%',
                                  style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                minHeight: 10.h,
                                backgroundColor: AppTheme.white.withValues(
                                  alpha: 0.20,
                                ),
                                valueColor: AlwaysStoppedAnimation(
                                  progress >= 80
                                      ? const Color(0xFF34D399)
                                      : progress >= 50
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFF87171),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 16.sp,
                                  color: progress >= 80
                                      ? const Color(0xFF34D399)
                                      : AppTheme.white.withValues(alpha: 0.50),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  progress >= 80
                                      ? 'Great! You are well prepared!'
                                      : progress >= 50
                                      ? 'Getting there! Keep adding items.'
                                      : 'Start preparing your emergency kit.',
                                  style: TextStyle(
                                    color: AppTheme.white.withValues(
                                      alpha: 0.80,
                                    ),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Obx(
                  () => Column(
                    children: controller.categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 15.h),
                        child: Container(
                          padding: EdgeInsets.all(15.r),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      gradient: LinearGradient(
                                        colors: category.gradientColors,
                                      ),
                                    ),
                                    child: Icon(
                                      category.icon,
                                      color: AppTheme.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.title,
                                          style: theme.textTheme.headlineMedium,
                                        ),
                                        Text(
                                          '${category.checkedCount}/${category.totalCount} items',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (category.isComplete)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Complete',
                                        style: TextStyle(
                                          color: const Color(0xFF10B981),
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              ...category.items.map((item) {
                                return InkWell(
                                  onTap: () => controller.toggleItem(
                                    category.id,
                                    item.id,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Container(
                                    padding: EdgeInsets.all(10.r),
                                    margin: EdgeInsets.only(bottom: 4.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: item.isChecked
                                          ? AppTheme.primaryColor.withValues(
                                              alpha: 0.05,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          item.isChecked
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: item.isChecked
                                              ? AppTheme.primaryColor
                                              : Colors.grey[300],
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.label,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: item.isChecked
                                                      ? Colors.grey
                                                      : theme
                                                            .textTheme
                                                            .headlineMedium
                                                            ?.color,
                                                  decoration: item.isChecked
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                              Text(
                                                item.description,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
