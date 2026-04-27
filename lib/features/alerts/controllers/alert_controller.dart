import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/alerts/models/alert_model.dart';
import 'package:safelink/features/alerts/services/alert_service.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';

class AlertController extends GetxController {
  final AlertService _alertService = Get.find<AlertService>();
  final MlAlertController _mlController = Get.find<MlAlertController>();

  final isLoading = false.obs;
  final alerts = <AlertModel>[].obs;
  final selectedAlert = Rxn<AlertModel>();

  @override
  void onInit() {
    super.onInit();
    // Rebuild the alert list whenever ML data arrives or updates.
    // MlAlertController loads asynchronously after location init, so we
    // cannot rely on a one-shot read in onInit — reactive workers are required.
    ever(_mlController.earthquakeAlerts, (_) => _syncFromMl());
    ever(_mlController.floodAlert, (_) => _syncFromMl());
    loadAlerts();
  }

  void _syncFromMl() {
    alerts.value = _constructAlertsFromMlData();
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      alerts.value = _constructAlertsFromMlData();
    } catch (e) {
      Get.log('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<AlertModel> _constructAlertsFromMlData() {
    final mlAlerts = <AlertModel>[];

    // Add earthquake alerts if available
    if (_mlController.earthquakeAlerts.isNotEmpty) {
      for (final eq in _mlController.earthquakeAlerts) {
        mlAlerts.add(AlertModel(
          id: eq.eventId,
          title: 'M${eq.mainshockMagnitude.toStringAsFixed(1)} Earthquake — ${eq.severity}',
          description: eq.message.isNotEmpty
              ? eq.message
              : 'Earthquake detected with ${eq.predictedAftershocks.length} predicted aftershocks',
          severity: _mapMagnitudeToSeverity(eq.mainshockMagnitude),
          disasterType: 'earthquake',
          location: eq.mainshockLocation,
          latitude: eq.mainshockLatitude,
          longitude: eq.mainshockLongitude,
          isActive: eq.shouldAlert,
          createdAt: eq.mainshockTimestamp,
        ));
      }
    }

    // Add flood alerts if available
    if (_mlController.floodAlert.value != null) {
      final flood = _mlController.floodAlert.value!;
      mlAlerts.add(AlertModel(
        id: 'flood_${flood.riskLevel}_${DateTime.now().millisecondsSinceEpoch}',
        title: '${flood.riskScore.toStringAsFixed(0)}% — ${flood.riskLevel} Flood Risk',
        description: flood.affectedAreas.isNotEmpty
            ? 'Affected areas: ${flood.affectedAreas.join(', ')}\nRainfall: ${flood.rainfallMm.toStringAsFixed(1)} mm'
            : 'Flood risk detected. Rainfall: ${flood.rainfallMm.toStringAsFixed(1)} mm',
        severity: _mapFloodRiskToSeverity(flood.riskScore),
        disasterType: 'flood',
        location:
            flood.affectedAreas.isNotEmpty ? flood.affectedAreas.first : null,
        isActive: flood.shouldAlert,
        createdAt: flood.dataDate ?? DateTime.now().toIso8601String(),
      ));
    }

    return mlAlerts;
  }

  String _mapMagnitudeToSeverity(double magnitude) {
    if (magnitude >= 7.0) return 'critical';
    if (magnitude >= 5.5) return 'high';
    if (magnitude >= 4.0) return 'medium';
    return 'low';
  }

  String _mapFloodRiskToSeverity(double riskScore) {
    if (riskScore >= 75) return 'critical';
    if (riskScore >= 50) return 'high';
    if (riskScore >= 25) return 'medium';
    return 'low';
  }

  Future<void> loadAlertsForLocation(double latitude, double longitude) async {
    isLoading.value = true;
    try {
      // Use ML data alerts instead of database
      final mlAlerts = _constructAlertsFromMlData();
      alerts.value = mlAlerts;
    } catch (e) {
      Get.log('Error loading location alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewAlert(String id) async {
    try {
      selectedAlert.value = await _alertService.getAlertById(id);
    } catch (_) {
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
