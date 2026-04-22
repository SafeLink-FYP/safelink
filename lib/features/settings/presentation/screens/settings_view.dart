import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/controllers/theme_controller.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/widgets/gradient_header.dart';
import 'package:safelink/features/settings/controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final themeController = ThemeController.instance;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GradientHeader(
                gradient: AppTheme.primaryGradient,
                child: Row(
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
                    Text(
                      'Settings',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  children: [
                    _SettingsSection(
                      icon: Icons.palette,
                      title: 'Appearance',
                      children: [
                        Obx(
                          () => _ToggleTile(
                            icon: themeController.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            label: 'Dark Mode',
                            subtitle:
                                themeController.themeMode == ThemeMode.dark
                                ? 'On'
                                : 'Off',
                            value: themeController.themeMode == ThemeMode.dark,
                            onChanged: (_) => themeController.toggleTheme(),
                            gradient: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _SettingsSection(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      children: [
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.notifications_active,
                            label: 'Push Notifications',
                            subtitle: 'Receive disaster alerts',
                            value: controller.pushNotifications.value,
                            onChanged: (_) => controller.toggleBool(
                              'pushNotifications',
                              controller.pushNotifications,
                            ),
                          ),
                        ),
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.volume_up,
                            label: 'Alert Sounds',
                            subtitle: 'Play sound for critical alerts',
                            value: controller.alertSounds.value,
                            onChanged: (_) => controller.toggleBool(
                              'alertSounds',
                              controller.alertSounds,
                            ),
                          ),
                        ),
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.vibration,
                            label: 'Vibration',
                            subtitle: 'Vibrate on emergency alerts',
                            value: controller.vibration.value,
                            onChanged: (_) => controller.toggleBool(
                              'vibration',
                              controller.vibration,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _SettingsSection(
                      icon: Icons.location_on,
                      title: 'Location & Safety',
                      children: [
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.location_on,
                            label: 'Location Services',
                            subtitle: 'Share location for alerts',
                            value: controller.locationServices.value,
                            onChanged: (_) => controller.toggleBool(
                              'locationServices',
                              controller.locationServices,
                            ),
                          ),
                        ),
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.shield,
                            label: 'Background Location',
                            subtitle: 'Track location even when app closed',
                            value: controller.backgroundLocation.value,
                            onChanged: (_) => controller.toggleBool(
                              'backgroundLocation',
                              controller.backgroundLocation,
                            ),
                          ),
                        ),
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.shield,
                            label: 'Auto SOS Detection',
                            subtitle: 'Detect emergencies automatically',
                            value: controller.autoSOS.value,
                            onChanged: (_) => controller.toggleBool(
                              'autoSOS',
                              controller.autoSOS,
                            ),
                          ),
                        ),
                        Divider(color: theme.dividerColor),
                        _InfoTile(
                          icon: Icons.public,
                          label: 'Alert Radius',
                          subtitle: 'Distance for nearby alerts',
                          trailing: Obx(
                            () => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                              ),
                              child: Text(
                                controller.alertRadius.value,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _SettingsSection(
                      icon: Icons.download,
                      title: 'Data & Storage',
                      children: [
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.download,
                            label: 'Offline Maps',
                            subtitle: 'Download maps for offline use',
                            value: controller.offlineMaps.value,
                            onChanged: (_) => controller.toggleBool(
                              'offlineMaps',
                              controller.offlineMaps,
                            ),
                          ),
                        ),
                        Obx(
                          () => _ToggleTile(
                            icon: Icons.sync,
                            label: 'Auto Sync',
                            subtitle: 'Sync data when connected',
                            value: controller.dataSync.value,
                            onChanged: (_) => controller.toggleBool(
                              'dataSync',
                              controller.dataSync,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _SettingsSection(
                      icon: Icons.public,
                      title: 'Language & Region',
                      children: [
                        _InfoTile(
                          icon: Icons.public,
                          label: 'Language',
                          subtitle: controller.language.value,
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _SettingsSection(
                      icon: Icons.info,
                      title: 'About',
                      children: [
                        _InfoTile(
                          icon: Icons.help_center,
                          label: 'Help Center',
                          subtitle: 'FAQs and support',
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        _InfoTile(
                          icon: Icons.description,
                          label: 'Terms of Service',
                          subtitle: 'Legal information',
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        _InfoTile(
                          icon: Icons.shield,
                          label: 'Privacy Policy',
                          subtitle: 'How we protect your data',
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        _InfoTile(
                          icon: Icons.info,
                          label: 'App Version',
                          subtitle: 'SafeLink v2.1.0',
                          trailing: null,
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

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool gradient;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: gradient ? AppTheme.primaryGradient : null,
              color: gradient
                  ? null
                  : theme.colorScheme.surfaceContainerHigh ==
                        AppTheme.darkBackgroundColor
                  ? Colors.grey[800]
                  : Colors.grey[100],
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: gradient ? AppTheme.white : Colors.grey[600],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.headlineMedium),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color:
                  theme.colorScheme.surfaceContainerHigh ==
                      AppTheme.darkBackgroundColor
                  ? Colors.grey[800]
                  : Colors.grey[100],
            ),
            child: Icon(icon, size: 16.sp, color: Colors.grey[600]),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.headlineMedium),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
