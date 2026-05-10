import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/animated_press_effect.dart';
import 'package:safelink/features/app_shell/controllers/navigation_controller.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:safelink/features/notifications/controllers/notification_controller.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/app_shell/presentation/widgets/glass_container.dart';
import 'package:safelink/features/app_shell/presentation/widgets/home_quick_action.dart';
import 'package:safelink/features/app_shell/presentation/widgets/outbox_indicator.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/shared/home/gov_alerts_home_section.dart';
import 'package:safelink/shared/home/predicted_alerts_home_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NavigationController navigationController =
      Get.find<NavigationController>();
  final MlAlertController mlController = Get.find<MlAlertController>();
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
                        AnimatedPressEffect(
                          onTap: () => Get.toNamed(AppRoutes.notificationsView),
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.notificationIcon,
                                  width: 20.w,
                                  height: 20.h,
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              Obx(() {
                                final count = Get.find<NotificationController>()
                                    .unreadCount
                                    .value;
                                if (count == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  top: 2.h,
                                  right: 2.w,
                                  child: Container(
                                    width: 10.w,
                                    height: 10.h,
                                    decoration: BoxDecoration(
                                      color: AppTheme.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.20,
                                        ),
                                        width: 1.w,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const OutboxIndicator(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.primaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Quick Actions',
                          style: theme.textTheme.headlineLarge,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
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
                              iconBackgroundGradient: AppTheme.primaryGradient,
                              onTap: () => navigationController.changePage(3),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideY(begin: 0.15, end: 0),
                    SizedBox(height: 10.h),
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HomeQuickAction(
                              label: 'Report',
                              icon: AppAssets.sosIcon,
                              iconBackgroundGradient: AppTheme.primaryGradient,
                              onTap: () => Get.toNamed('/reportIncidentView'),
                            ),
                            HomeQuickAction(
                              label: 'My Cases',
                              icon: AppAssets.chatIcon,
                              iconBackgroundGradient: AppTheme.purpleGradient,
                              onTap: () => Get.toNamed('/caseTrackingView'),
                            ),
                            HomeQuickAction(
                              label: 'Contacts',
                              icon: AppAssets.sosIcon,
                              iconBackgroundGradient: AppTheme.greenGradient,
                              onTap: () =>
                                  Get.toNamed('/emergencyContactsView'),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 550.ms)
                        .slideY(begin: 0.15, end: 0),
                    SizedBox(height: 25.h),
                    // ── Active Alerts (gov-issued, authoritative) ──────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Active Alerts',
                              style: theme.textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        AnimatedPressEffect(
                          onTap: () => Get.toNamed(
                            AppRoutes.alertsListView,
                            arguments: {'tab': 0},
                          ),
                          child: Text(
                            'View All',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                    SizedBox(height: 15.h),
                    GovAlertsHomeSection(
                      controller: alertController,
                    ).animate().fadeIn(duration: 400.ms, delay: 650.ms),
                    SizedBox(height: 25.h),
                    // ── Predicted Alerts (ML-generated, probabilistic) ─
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.show_chart_rounded,
                              color: AppTheme.amber,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Predicted Alerts',
                              style: theme.textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        AnimatedPressEffect(
                          onTap: () => Get.toNamed(
                            AppRoutes.alertsListView,
                            arguments: {'tab': 1},
                          ),
                          child: Text(
                            'View All',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                    SizedBox(height: 15.h),
                    PredictedAlertsHomeSection(
                      mlController: mlController,
                    ).animate().fadeIn(duration: 400.ms, delay: 750.ms),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Safety Tips',
                              style: theme.textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        AnimatedPressEffect(
                          onTap: () => Get.toNamed('/safetyTipsView'),
                          child: Text(
                            'View All',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 850.ms),
                    SizedBox(height: 25.h),
                    AnimatedPressEffect(
                          onTap: () => Get.toNamed('/preparednessView'),
                          child: GlassContainer(
                            gradient: true,
                            glow: true,
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    gradient: AppTheme.primaryGradient,
                                    boxShadow: AppTheme.deepBlueGlow,
                                  ),
                                  child: SvgPicture.asset(
                                    AppAssets.waveIcon,
                                    width: 20.w,
                                    height: 20.h,
                                    colorFilter: const ColorFilter.mode(
                                      AppTheme.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Be Prepared',
                                        style: theme.textTheme.headlineLarge,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Keep an emergency kit ready with essentials like water, food, and first aid supplies.',
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.hintColor,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 900.ms)
                        .slideY(begin: 0.10, end: 0),
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
