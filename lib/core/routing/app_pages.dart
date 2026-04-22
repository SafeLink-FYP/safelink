import 'package:get/get.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/features/aid/presentation/screens/report_incident_view.dart';
import 'package:safelink/features/authorization/presentation/screens/reset_password_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_in_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_up_view.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/aid/presentation/screens/aid_request_view.dart';
import 'package:safelink/features/aid/presentation/screens/aid_requests_list_view.dart';
import 'package:safelink/features/alerts/presentation/screens/alert_detail_view.dart';
import 'package:safelink/features/alerts/presentation/screens/alerts_list_view.dart';
import 'package:safelink/features/cases/presentation/screens/case_detail_view.dart';
import 'package:safelink/features/cases/presentation/screens/case_tracking_view.dart';
import 'package:safelink/features/app_shell/presentation/screens/dashboard_view.dart';
import 'package:safelink/features/app_shell/presentation/screens/main_dashboard_view.dart';
import 'package:safelink/features/notifications/presentation/screens/notifications_view.dart';
import 'package:safelink/features/profile/presentation/screens/edit_profile_view.dart';
import 'package:safelink/features/profile/presentation/screens/profile_view.dart';
import 'package:safelink/features/aid/presentation/screens/s_o_s_view.dart';
import 'package:safelink/features/onboarding/presentation/screens/onboarding_view.dart';
import 'package:safelink/features/onboarding/presentation/screens/splash_view.dart';
import 'package:safelink/features/settings/presentation/screens/settings_view.dart';
import 'package:safelink/features/preparedness/presentation/screens/preparedness_view.dart';
import 'package:safelink/features/preparedness/presentation/screens/safety_tips_view.dart';
import 'package:safelink/features/map/presentation/screens/map_view.dart';
import 'package:safelink/features/emergency_contacts/presentation/screens/emergency_contacts_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splashView, page: () => const SplashView()),
    GetPage(name: AppRoutes.onboardingView, page: () => const OnboardingView()),
    GetPage(name: AppRoutes.signInView, page: () => const SignInView()),
    GetPage(name: AppRoutes.signUpView, page: () => const SignUpView()),
    GetPage(
      name: AppRoutes.resetPasswordView,
      page: () => const ResetPasswordView(),
    ),
    GetPage(name: AppRoutes.dashboardView, page: () => const HomeView()),
    GetPage(
      name: AppRoutes.notificationsView,
      page: () => const NotificationsView(),
    ),
    GetPage(name: AppRoutes.alertsListView, page: () => const AlertsListView()),
    GetPage(
      name: AppRoutes.alertDetailView,
      page: () => const AlertDetailView(),
    ),
    GetPage(name: AppRoutes.sosView, page: () => const SOSView()),
    GetPage(
      name: AppRoutes.emergencyContactsView,
      page: () => const EmergencyContactsView(),
    ),
    GetPage(name: AppRoutes.profileView, page: () => const ProfileView()),
    GetPage(
      name: AppRoutes.editProfileView,
      page: () => const EditProfileView(),
    ),
    GetPage(name: AppRoutes.aidRequestView, page: () => const AidRequestView()),
    GetPage(
      name: AppRoutes.aidRequestsListView,
      page: () => const AidRequestsListView(),
    ),
    GetPage(name: AppRoutes.chatView, page: () => const ChatView()),
    GetPage(name: AppRoutes.mapView, page: () => const MapView()),
    GetPage(
      name: AppRoutes.mainDashboardView,
      page: () => const MainDashboardView(),
    ),
    GetPage(name: AppRoutes.safetyTipsView, page: () => const SafetyTipsView()),
    GetPage(
      name: AppRoutes.preparednessView,
      page: () => const PreparednessView(),
    ),
    GetPage(
      name: AppRoutes.reportIncidentView,
      page: () => const ReportIncidentView(),
    ),
    GetPage(name: AppRoutes.settingsView, page: () => const SettingsView()),
    GetPage(
      name: AppRoutes.caseTrackingView,
      page: () => const CaseTrackingView(),
    ),
    GetPage(name: AppRoutes.caseDetailView, page: () => const CaseDetailView()),
  ];
}
