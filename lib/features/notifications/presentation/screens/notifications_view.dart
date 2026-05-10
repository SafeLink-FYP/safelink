import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/notifications/controllers/notification_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GradientHeader(
              gradient: AppTheme.primaryGradient,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, color: AppTheme.white),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => controller.markAllAsRead(),
                    child: Text(
                      'Mark all read',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.white,
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
                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.notificationIcon,
                          width: 60.w,
                          height: 60.h,
                          colorFilter: ColorFilter.mode(
                            theme.hintColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          'No notifications yet',
                          style: theme.textTheme.headlineLarge,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'You\'ll see alerts and updates here',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshNotifications,
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            controller.deleteNotification(notification.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.w),
                          decoration: BoxDecoration(
                            color: AppTheme.red,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.delete, color: AppTheme.white),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (!notification.isRead) {
                              controller.markAsRead(notification.id);
                            }
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.all(15.r),
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? theme.cardColor
                                  : theme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: notification.isRead
                                    ? theme.dividerColor
                                    : theme.primaryColor.withValues(
                                        alpha: 0.20,
                                      ),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _getGradient(notification.type),
                                  ),
                                  child: Icon(
                                    _getIcon(notification.type),
                                    color: AppTheme.white,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                      if (notification.body.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          notification.body,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      SizedBox(height: 4.h),
                                      Text(
                                        notification.timeAgo,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8.w,
                                    height: 8.h,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient(String type) {
    switch (type) {
      case 'alert':
        return AppTheme.redGradient;
      case 'sos':
        return AppTheme.orangeGradient;
      case 'aid':
        return AppTheme.greenGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'sos':
        return Icons.sos;
      case 'aid':
        return Icons.volunteer_activism;
      default:
        return Icons.notifications;
    }
  }
}
