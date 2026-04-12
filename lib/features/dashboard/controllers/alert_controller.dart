import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/dashboard/models/alert_model.dart';
import 'package:safelink/features/dashboard/services/alert_service.dart';

class AlertController extends GetxController {
  final AlertService _alertService = Get.find<AlertService>();

  final isLoading = false.obs;
  final alerts = <AlertModel>[].obs;
  final selectedAlert = Rxn<AlertModel>();

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      alerts.value = await _alertService.getActiveAlerts();
    } catch (e) {
      Get.log('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllAlerts() async {
    isLoading.value = true;
    try {
      alerts.value = await _alertService.getAllAlerts();
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to load alerts',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAlertsForLocation(double latitude, double longitude) async {
    isLoading.value = true;
    try {
      alerts.value = await _alertService.getAlertsForLocation(
        latitude,
        longitude,
      );
    } catch (e) {
      Get.log('Error loading location alerts: $e — falling back to active');
      try {
        alerts.value = await _alertService.getActiveAlerts();
      } catch (_) {}
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewAlert(String id) async {
    try {
      selectedAlert.value = await _alertService.getAlertById(id);
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to load alert details',
      );
    }
  }

  Future<void> refreshAlerts() async {
    await loadAlerts();
  }

  String getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return 'assets/icons/Droplets-Icon.svg';
      case 'earthquake':
        return 'assets/icons/Wave-Icon.svg';
      case 'medical':
        return 'assets/icons/Warning-Icon.svg';
      default:
        return 'assets/icons/Warning-Icon.svg';
    }
  }
}
