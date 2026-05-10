import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/cases/models/case_model.dart';
import 'package:safelink/features/cases/presentation/mappers/case_presentation_mapper.dart';

class CaseCard extends StatelessWidget {
  final CaseModel caseItem;

  const CaseCard({super.key, required this.caseItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.caseDetailView, arguments: caseItem),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: AppTheme.primaryGradient,
              ),
              child: Icon(
                caseItem.displayIcon,
                color: AppTheme.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        caseItem.type,
                        style: theme.textTheme.headlineMedium,
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: caseItem.displayStatusColor.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: caseItem.displayStatusColor.withValues(
                              alpha: 0.30,
                            ),
                          ),
                        ),
                        child: Text(
                          caseItem.displayStatus,
                          style: TextStyle(
                            color: caseItem.displayStatusColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    caseItem.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      if (caseItem.location != null) ...[
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          caseItem.location!,
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: caseItem.displayPriorityColor.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          caseItem.priority.capitalizeFirst ?? '',
                          style: TextStyle(
                            color: caseItem.displayPriorityColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '${caseItem.displayId} | ${caseItem.timeAgo}',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
