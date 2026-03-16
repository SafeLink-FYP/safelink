import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink/features/dashboard/presentation/screens/map_view.dart';
import 'package:safelink/features/dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'home_view.dart';
import 's_o_s_view.dart';
import '../../../profile/presentation/screens/profile_view.dart';

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
        () => IndexedStack(
          index: navController.selectedIndex.value,
          children: const [
            HomeView(),
            MapView(),
            SOSView(),
            ChatView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
