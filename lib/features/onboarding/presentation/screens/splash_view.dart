import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/core/services/cache_service.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 2500));
      await _resolveInitialRoute();
    });
  }

  Future<void> _resolveInitialRoute() async {
    final cache = CacheService.instance;
    final authController = Get.find<AuthController>();

    final hasSession = await authController.checkSession();
    if (hasSession) {
      Get.offAllNamed(AppRoutes.mainDashboardView);
      return;
    }

    if (cache.isOnboardingComplete) {
      Get.offAllNamed(AppRoutes.signInView);
    } else {
      Get.offAllNamed(AppRoutes.onboardingView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.r,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60.h,
            right: -40.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80.h,
            left: -50.w,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purple.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(15.r),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Image.asset(
                          AppAssets.safeLinkLogo,
                          width: 250.w,
                          height: 250.h,
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),
                    SizedBox(height: 15.h),
                    Text(
                      'SafeLink',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    SizedBox(height: 10.h),
                    Text(
                      'AI-Powered Disaster Relief App for Pakistan',
                      style: theme.textTheme.headlineLarge,
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                    SizedBox(height: 50.h),
                    CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                    SizedBox(height: 25.h),
                    Text(
                      'INITIALIZING...',
                      style: theme.textTheme.bodyMedium,
                    ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
                    Spacer(),
                    Text(
                      'Empowering Communities ∘ Saving Lives',
                      style: theme.textTheme.bodyMedium,
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
