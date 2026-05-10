import 'package:flutter/material.dart';
import 'package:safelink/features/app_shell/presentation/screens/dashboard_view.dart';
import 'package:safelink/features/map/presentation/screens/map_view.dart';
import 'package:safelink/features/aid/presentation/screens/s_o_s_view.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/profile/presentation/screens/profile_view.dart';

class ShellPages {
  static Widget buildTab(int index) {
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
}

