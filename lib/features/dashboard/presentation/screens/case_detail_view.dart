import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/models/case_model.dart';

class CaseDetailView extends StatelessWidget {
  const CaseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final CaseModel caseData = Get.arguments as CaseModel;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      caseData.statusColor,
                      caseData.statusColor.withValues(alpha: 0.70),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Spacer(),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.share,
                              color: AppTheme.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            caseData.icon,
                            color: AppTheme.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caseData.type,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppTheme.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                caseData.displayId,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.white.withValues(alpha: 0.90),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  _HeaderBadge(label: caseData.displayStatus),
                                  SizedBox(width: 8.w),
                                  _HeaderBadge(
                                    label:
                                        caseData.priority.capitalizeFirst ?? '',
                                  ),
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

              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  children: [
                    _SectionCard(
                      icon: Icons.warning_amber,
                      title: 'Details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caseData.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (caseData.details.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            Divider(color: theme.dividerColor),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 15.w,
                              runSpacing: 8.h,
                              children: caseData.details.entries.map((entry) {
                                return SizedBox(
                                  width: 150.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        entry.value,
                                        style: theme.textTheme.headlineSmall,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _SectionCard(
                      icon: Icons.person,
                      title: 'Assigned Team',
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppTheme.white,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caseData.assignedTo ?? 'Unassigned',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                if (caseData.location != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        caseData.location!,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: Icon(
                              Icons.phone,
                              color: AppTheme.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    if (caseData.timeline.isNotEmpty)
                      _SectionCard(
                        icon: Icons.schedule,
                        title: 'Timeline',
                        child: Column(
                          children: List.generate(caseData.timeline.length, (
                            index,
                          ) {
                            final step = caseData.timeline[index];
                            final isLast =
                                index == caseData.timeline.length - 1;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.h,
                                      decoration: BoxDecoration(
                                        color: step.status == 'completed'
                                            ? AppTheme.primaryColor.withValues(
                                                alpha: 0.15,
                                              )
                                            : step.status == 'active'
                                            ? const Color(
                                                0xFF6366F1,
                                              ).withValues(alpha: 0.15)
                                            : Colors.grey.withValues(
                                                alpha: 0.10,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        step.status == 'completed'
                                            ? Icons.check_circle
                                            : step.status == 'active'
                                            ? Icons.schedule
                                            : Icons.circle_outlined,
                                        size: 18.sp,
                                        color: step.status == 'completed'
                                            ? AppTheme.primaryColor
                                            : step.status == 'active'
                                            ? const Color(0xFF6366F1)
                                            : Colors.grey,
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2.w,
                                        height: 30.h,
                                        color: step.status == 'completed'
                                            ? AppTheme.primaryColor.withValues(
                                                alpha: 0.30,
                                              )
                                            : Colors.grey.withValues(
                                                alpha: 0.20,
                                              ),
                                      ),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isLast ? 0 : 12.h,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step.time,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          step.title,
                                          style: theme.textTheme.headlineMedium,
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          step.description,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.toNamed('/chatView'),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble,
                                    color: AppTheme.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Contact Support',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.30,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.phone,
                              color: AppTheme.primaryColor,
                              size: 18.sp,
                            ),
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
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;

  const _HeaderBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.white.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppTheme.primaryColor),
              SizedBox(width: 8.w),
              Text(title, style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
