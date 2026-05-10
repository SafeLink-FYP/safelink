import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:safelink/features/app_shell/controllers/navigation_controller.dart';
import 'package:safelink/features/app_shell/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:safelink/shared/app_shell/shell_pages.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(
      NavigationController(),
      permanent: true,
    );
    return Scaffold(
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(navController.selectedIndex.value),
            child: ShellPages.buildTab(navController.selectedIndex.value),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
