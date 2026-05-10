import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safelink/core/controllers/theme_controller.dart';
import 'package:safelink/core/routing/app_pages.dart';
import 'package:safelink/core/secrets/app_secrets.dart';
import 'package:safelink/core/services/cache_service.dart';
import 'package:safelink/core/di/initial_bindings.dart';
import 'package:safelink/core/themes/app_theme.dart';
import 'package:safelink/core/routing/app_routes.dart';
import 'package:safelink/features/chatbot/services/chat_history_service.dart';
import 'package:safelink/features/chatbot/services/feedback_outbox_service.dart';
import 'package:safelink/features/outbox/controllers/outbox_controller.dart';
import 'package:safelink/features/outbox/services/connectivity_service.dart';
import 'package:safelink/features/outbox/services/outbox_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await ScreenUtil.ensureScreenSize();
  await CacheService.instance.init();
  await ThemeController.instance.init();
  await Hive.initFlutter();
  await Hive.openBox<Map>(OutboxService.pendingBoxName);
  await Hive.openBox<Map>(OutboxService.failedBoxName);
  await Hive.openBox<Map>(FeedbackOutboxService.boxName);
  await Hive.openBox<Map>(ChatHistoryService.boxName);
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  // Register outbox infra before runApp so InitialBindings (and the
  // submission controllers it sets up) can Get.find them in onInit.
  Get.put(ConnectivityService(), permanent: true);
  Get.put(OutboxService(), permanent: true);
  Get.put(OutboxController(), permanent: true);
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
                defaultTransition: Transition.fadeIn,
                transitionDuration: const Duration(milliseconds: 300),
                initialBinding: InitialBindings(),
                initialRoute: AppRoutes.splashView,
                getPages: AppPages.pages,
              );
            });
          },
        );
      },
    );
  }
}
