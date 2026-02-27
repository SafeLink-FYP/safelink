import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/constants/app_assets.dart';

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
      Get.toNamed('onboardingView');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  AppAssets.safeLinkLogo,
                  width: 250.w,
                  height: 250.h,
                ),
                SizedBox(height: 15.h),
                Text(
                  'SafeLink',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'AI-Powered Disaster Relief App for Pakistan',
                  style: theme.textTheme.headlineLarge,
                ),
                SizedBox(height: 50.h),
                CircularProgressIndicator(),
                SizedBox(height: 25.h),
                Text('INITIALIZING...', style: theme.textTheme.bodyMedium),
                Spacer(),
                Text(
                  'Empowering Communities ∘ Saving Lives',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
