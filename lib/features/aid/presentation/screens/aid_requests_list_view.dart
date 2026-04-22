import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/aid/controllers/aid_request_controller.dart';

class AidRequestsListView extends StatelessWidget {
  const AidRequestsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final controller = Get.find<AidRequestController>();
    controller.loadMyRequests();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.greenGradient,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, color: AppTheme.white),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      'My Aid Requests',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed('/aidRequestView'),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
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
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.myRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          size: 60.sp,
                          color: theme.hintColor,
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          'No aid requests',
                          style: theme.textTheme.headlineLarge,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Request help when you need it',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: controller.myRequests.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final request = controller.myRequests[index];
                    return Container(
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.greenGradient,
                            ),
                            child: Icon(
                              _getTypeIcon(request.type),
                              color: AppTheme.white,
                              size: 18.sp,
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
                                      request.type.capitalizeFirst ?? '',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildStatusChip(request.status, theme),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  request.description,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  request.timeAgo,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (request.status == 'pending')
                            IconButton(
                              onPressed: () =>
                                  controller.cancelRequest(request.id),
                              icon: Icon(
                                Icons.close,
                                color: AppTheme.red,
                                size: 18.sp,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'fulfilled':
        color = AppTheme.green;
        break;
      case 'in_progress':
      case 'approved':
        color = AppTheme.primaryColor;
        break;
      case 'rejected':
      case 'cancelled':
        color = AppTheme.red;
        break;
      default:
        color = AppTheme.orange;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.replaceAll('_', ' ').capitalizeFirst ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'food':
        return Icons.restaurant;
      case 'shelter':
        return Icons.home;
      case 'clothing':
        return Icons.checkroom;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.volunteer_activism;
    }
  }
}
