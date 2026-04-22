import 'package:get/get.dart';
import 'package:safelink/features/alerts/controllers/alert_controller.dart';
import 'package:safelink/features/authorization/data/repositories/auth_repository.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink/features/authorization/services/auth_service.dart';
import 'package:safelink/features/aid/controllers/aid_request_controller.dart';
import 'package:safelink/features/aid/controllers/s_o_s_controller.dart';
import 'package:safelink/features/aid/services/aid_request_service.dart';
import 'package:safelink/features/cases/services/case_tracking_service.dart';
import 'package:safelink/features/aid/services/disaster_report_service.dart';
import 'package:safelink/features/aid/services/s_o_s_service.dart';
import 'package:safelink/features/alerts/services/alert_service.dart';
import 'package:safelink/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:safelink/features/chatbot/services/chatbot_service.dart';
import 'package:safelink/features/notifications/controllers/notification_controller.dart';
import 'package:safelink/features/notifications/services/notification_service.dart';
import 'package:safelink/features/settings/services/settings_service.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';
import 'package:safelink/features/profile/services/profile_services.dart';
import 'package:safelink/features/preparedness/data/repositories/preparedness_repository.dart';
import 'package:safelink/features/preparedness/services/preparedness_state_service.dart';
import 'package:safelink/features/preparedness/controllers/preparedness_controller.dart';
import 'package:safelink/shared/controllers/emergency_contact_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    /// SERVICES
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepository(Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<ProfileService>(ProfileService(), permanent: true);
    Get.put<SOSService>(SOSService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AlertService>(AlertService(), permanent: true);
    Get.put<AidRequestService>(AidRequestService(), permanent: true);
    Get.put<SettingsService>(SettingsService(), permanent: true);
    Get.put<CaseTrackingService>(CaseTrackingService(), permanent: true);
    Get.put<DisasterReportService>(DisasterReportService(), permanent: true);
    Get.put<ChatbotRepository>(ChatbotRepository(), permanent: true);
    Get.put<ChatbotService>(
      ChatbotService(repository: Get.find<ChatbotRepository>()),
      permanent: true,
    );
    Get.put<PreparednessStateService>(
      PreparednessStateService(),
      permanent: true,
    );
    Get.put<PreparednessRepository>(
      PreparednessRepository(Get.find<PreparednessStateService>()),
      permanent: true,
    );

    /// CONTROLLERS
    Get.put<AuthController>(
      AuthController(authRepository: Get.find<AuthRepository>()),
      permanent: true,
    );
    Get.put<ProfileController>(ProfileController(), permanent: true);
    Get.put<ImagePickingController>(ImagePickingController(), permanent: true);
    Get.put<SOSController>(SOSController(), permanent: true);
    Get.put<AlertController>(AlertController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.put<EmergencyContactController>(
      EmergencyContactController(),
      permanent: true,
    );
    Get.put<AidRequestController>(AidRequestController(), permanent: true);
    Get.put<PreparednessController>(
      PreparednessController(repository: Get.find<PreparednessRepository>()),
      permanent: true,
    );
  }
}
