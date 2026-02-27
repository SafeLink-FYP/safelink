import 'package:get/get.dart';
import 'package:safelink/features/authorization/presentation/screens/reset_password_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_in_view.dart';
import 'package:safelink/features/authorization/presentation/screens/sign_up_view.dart';
import 'package:safelink/features/chatbot/presentation/screens/chat_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/home_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/main_dashboard_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/map_view.dart';
import 'package:safelink/features/dashboard/presentation/screens/profile_view.dart';
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
  static const sosView = '/sosView';
  static const profileView = '/profileView';
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
    GetPage(name: sosView, page: () => const SOSView()),
    GetPage(name: profileView, page: () => const ProfileView()),
    GetPage(name: chatView, page: () => const ChatView()),
    GetPage(name: mapView, page: () => const MapView()),
    GetPage(name: mainDashboardView, page: () => const MainDashboardView()),
  ];
}
