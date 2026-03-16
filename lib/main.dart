import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink/core/controllers/theme_controller.dart';
import 'package:safelink/core/secrets/app_secrets.dart';
import 'package:safelink/core/services/cache_service.dart';
import 'package:safelink/core/services/initial_bindings.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/utilities/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await ScreenUtil.ensureScreenSize();
  await CacheService.instance.init();
  await ThemeController.instance.init();
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,
      builder: (context, child) {
        return GetBuilder<ThemeController>(
          init: ThemeController.instance,
          builder: (controller) {
            return Obx(() {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: controller.themeMode,
                initialBinding: InitialBindings(),
                initialRoute: AppRoutes.splashView,
                getPages: AppRoutes.routes,
              );
            });
          },
        );
      },
    );
  }
}
