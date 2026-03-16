import 'package:get/get.dart';
import 'package:safelink/features/authorization/controllers/auth_controller.dart';
import 'package:safelink/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink/features/dashboard/controllers/alert_controller.dart';
import 'package:safelink/features/dashboard/controllers/emergency_contact_controller.dart';
import 'package:safelink/features/dashboard/controllers/notification_controller.dart';
import 'package:safelink/features/dashboard/controllers/s_o_s_controller.dart';
import 'package:safelink/features/dashboard/services/aid_request_service.dart';
import 'package:safelink/features/dashboard/services/alert_service.dart';
import 'package:safelink/features/dashboard/services/notification_service.dart';
import 'package:safelink/features/dashboard/services/s_o_s_service.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';
import 'package:safelink/features/profile/services/profile_services.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    /// SERVICES
    Get.put<ProfileService>(ProfileService(), permanent: true);
    Get.put<SOSService>(SOSService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AlertService>(AlertService(), permanent: true);
    Get.put<AidRequestService>(AidRequestService(), permanent: true);

    /// CONTROLLERS
    Get.put<AuthController>(AuthController(), permanent: true);
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
  }
}
