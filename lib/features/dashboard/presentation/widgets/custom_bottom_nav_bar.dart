import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/dashboard/controllers/navigation_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NavigationController navController = Get.put(NavigationController());
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: AppAssets.homeIcon,
                  label: 'Home',
                  index: 0,
                  isSelected: navController.selectedIndex.value == 0,
                  onTap: () => navController.changePage(0),
                  context: context,
                ),
                _buildNavItem(
                  icon: AppAssets.mapIcon,
                  label: 'Map',
                  index: 1,
                  isSelected: navController.selectedIndex.value == 1,
                  onTap: () => navController.changePage(1),
                  context: context,
                ),
                _buildNavItem(
                  icon: AppAssets.sosIcon,
                  label: 'SOS',
                  index: 2,
                  isSelected: navController.selectedIndex.value == 2,
                  onTap: () => navController.changePage(2),
                  context: context,
                ),
                _buildNavItem(
                  icon: AppAssets.chatIcon,
                  label: 'Chat',
                  index: 3,
                  isSelected: navController.selectedIndex.value == 3,
                  onTap: () => navController.changePage(3),
                  context: context,
                ),
                _buildNavItem(
                  icon: AppAssets.personIcon,
                  label: 'Profile',
                  index: 4,
                  isSelected: navController.selectedIndex.value == 4,
                  onTap: () => navController.changePage(4),
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 25.w,
              height: 25.h,
              colorFilter: ColorFilter.mode(
                isSelected ? theme.primaryColor : theme.hintColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: isSelected
                  ? theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                    )
                  : theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
