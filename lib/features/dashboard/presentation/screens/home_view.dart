import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/alert_controller.dart';
import 'package:safelink/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink/features/dashboard/presentation/widgets/active_alert.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/dashboard/presentation/widgets/home_quick_action.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NavigationController navigationController =
      Get.find<NavigationController>();
  final AlertController alertController = Get.find<AlertController>();

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SafeLink',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                            Text(
                              'Stay Safe, Stay Connected',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Get.toNamed('notificationsView'),
                          child: Container(
                            padding: EdgeInsets.all(15.r),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.60,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  offset: Offset(0, 20),
                                  blurRadius: 25.r,
                                  spreadRadius: -5.r,
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              AppAssets.notificationIcon,
                              width: 20.w,
                              height: 20.h,
                              colorFilter: ColorFilter.mode(
                                AppTheme.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Container(
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: Offset(0, 20),
                            blurRadius: 25.r,
                            spreadRadius: -5.r,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: Offset(0, 8),
                            blurRadius: 10.r,
                            spreadRadius: -6.r,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.r),
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0xFF1E40AF,
                                  ).withValues(alpha: 0.20),
                                  offset: Offset(0, 10),
                                  blurRadius: 15.r,
                                  spreadRadius: -3.r,
                                ),
                                BoxShadow(
                                  color: Color(
                                    0xFF1E40AF,
                                  ).withValues(alpha: 0.1),
                                  offset: Offset(0, 4),
                                  blurRadius: 6.r,
                                  spreadRadius: -4.r,
                                ),
                              ],
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.shieldHalved,
                              color: theme.iconTheme.color,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Area Status',
                                style: theme.textTheme.bodyLarge,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'Currently Safe',
                                style: theme.textTheme.displayMedium,
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.75,
                                ),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              'Low Risk',
                              style: theme.textTheme.displaySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: theme.textTheme.headlineLarge),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HomeQuickAction(
                          label: 'View Heatmap',
                          icon: AppAssets.mapIcon,
                          iconBackgroundGradient: AppTheme.primaryGradient,
                          onTap: () => navigationController.changePage(1),
                        ),
                        HomeQuickAction(
                          label: 'Emergency SOS',
                          icon: AppAssets.sosIcon,
                          iconBackgroundGradient: AppTheme.redGradient,
                          onTap: () => navigationController.changePage(2),
                        ),
                        HomeQuickAction(
                          label: 'Get Help',
                          icon: AppAssets.chatIcon,
                          iconBackgroundGradient: AppTheme.greenGradient,
                          onTap: () => navigationController.changePage(3),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Alerts',
                          style: theme.textTheme.headlineLarge,
                        ),
                        InkWell(
                          onTap: () => Get.toNamed('/alertsListView'),
                          child: Text(
                            'View All',
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Obx(() {
                      if (alertController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (alertController.alerts.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppTheme.green.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.green,
                                size: 24.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'No active alerts in your area',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: alertController.alerts
                            .take(3)
                            .map(
                              (alert) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: InkWell(
                                  onTap: () => Get.toNamed(
                                    '/alertDetailView',
                                    arguments: alert,
                                  ),
                                  child: ActiveAlert(
                                    label: alert.title,
                                    location: alert.location ?? 'Unknown',
                                    time: alert.timeAgo,
                                    alertLevel:
                                        alert.severity.capitalizeFirst ?? 'Low',
                                    icon: alertController.getAlertIcon(
                                      alert.type,
                                    ),
                                    iconColor: _getSeverityColor(
                                      alert.severity,
                                    ),
                                    iconBackgroundColor: _getSeverityBgColor(
                                      alert.severity,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),
                    SizedBox(height: 25.h),
                    Text('Safety Tips', style: theme.textTheme.headlineLarge),
                    SizedBox(height: 25.h),
                    Container(
                      padding: EdgeInsets.all(15.r),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.20),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: SvgPicture.asset(
                              AppAssets.waveIcon,
                              width: 20.w,
                              height: 20.h,
                              colorFilter: ColorFilter.mode(
                                AppTheme.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Be Prepared',
                                style: theme.textTheme.headlineLarge,
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'Keep an emergency kit ready with \nessentials like water, food, and first aid \nsupplies.',
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'medium':
        return AppTheme.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getSeverityBgColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.lightRed;
      case 'medium':
        return AppTheme.lightOrange;
      default:
        return const Color(0xFFEFF6FF);
    }
  }
}
