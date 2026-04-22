import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink/features/dashboard/presentation/screens/dashboard_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/map_view.dart';
import 'package:safelink/features/aid/presentation/screens/s_o_s_view.dart';
import 'package:safelink/features/dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:safelink/features/profile/presentation/screens/profile_view.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const MapView();
      case 2:
        return const SOSView();
      case 3:
        return const ChatView();
      case 4:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }

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
            child: _buildPage(navController.selectedIndex.value),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
