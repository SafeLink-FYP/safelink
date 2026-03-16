import 'package:get/get.dart';
import 'package:safelink/features/authorization/presentation/screens/reset_password_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_in_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_up_view.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/aid_request_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/aid_requests_list_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/alert_detail_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/alerts_list_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/emergency_contacts_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/home_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/main_dashboard_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/map_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/notifications_view.dart';
import 'package:safelink/features/profile/presentation/screens/edit_profile_view.dart';
import 'package:safelink/features/profile/presentation/screens/profile_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/s_o_s_view.dart';
import 'package:safelink/features/onboarding/presentation/screens/onboarding_view.dart';
import 'package:safelink/features/onboarding/presentation/screens/splash_view.dart';

class AppRoutes {
  static const splashView = '/splashView';
  static const onboardingView = '/onboardingView';
  static const signInView = '/signInView';
  static const signUpView = '/signUpView';
  static const resetPasswordView = '/resetPasswordView';
  static const homeView = '/homeView';
  static const notificationsView = '/notificationsView';
  static const alertsListView = '/alertsListView';
  static const alertDetailView = '/alertDetailView';
  static const sosView = '/sosView';
  static const emergencyContactsView = '/emergencyContactsView';
  static const profileView = '/profileView';
  static const editProfileView = '/editProfileView';
  static const aidRequestView = '/aidRequestView';
  static const aidRequestsListView = '/aidRequestsListView';
  static const chatView = '/chatView';
  static const mapView = '/mapView';
  static const mainDashboardView = '/mainDashboardView';

  static final routes = [
    GetPage(name: splashView, page: () => const SplashView()),
    GetPage(name: onboardingView, page: () => const OnboardingView()),
    GetPage(name: signInView, page: () => const SignInView()),
    GetPage(name: signUpView, page: () => const SignUpView()),
    GetPage(name: resetPasswordView, page: () => const ResetPasswordView()),
    GetPage(name: homeView, page: () => const HomeView()),
    GetPage(name: notificationsView, page: () => const NotificationsView()),
    GetPage(name: alertsListView, page: () => const AlertsListView()),
    GetPage(name: alertDetailView, page: () => const AlertDetailView()),
    GetPage(name: sosView, page: () => const SOSView()),
    GetPage(
      name: emergencyContactsView,
      page: () => const EmergencyContactsView(),
    ),
    GetPage(name: profileView, page: () => const ProfileView()),
    GetPage(name: editProfileView, page: () => const EditProfileView()),
    GetPage(name: aidRequestView, page: () => const AidRequestView()),
    GetPage(name: aidRequestsListView, page: () => const AidRequestsListView()),
    GetPage(name: chatView, page: () => const ChatView()),
    GetPage(name: mapView, page: () => const MapView()),
    GetPage(name: mainDashboardView, page: () => const MainDashboardView()),
  ];
}
