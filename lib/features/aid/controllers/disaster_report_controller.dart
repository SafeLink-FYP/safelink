import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/aid/models/disaster_report_model.dart';
import 'package:safelink/features/aid/services/disaster_report_service.dart';
import 'package:safelink/features/outbox/controllers/outbox_controller.dart';
import 'package:safelink/features/outbox/models/pending_submission.dart';

class DisasterReportController extends GetxController {
  final DisasterReportService _service = Get.find<DisasterReportService>();
  final OutboxController _outbox = Get.find<OutboxController>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final myReports = <DisasterReportModel>[].obs;

  final currentStep = 1.obs;
  final title = ''.obs;
  final selectedType = ''.obs;
  final selectedSeverity = 'high'.obs;
  final location = 'Islamabad, Pakistan'.obs;
  final description = ''.obs;
  final imageUrls = <String>[].obs;

  void resetForm() {
    currentStep.value = 1;
    title.value = '';
    selectedType.value = '';
    selectedSeverity.value = 'high';
    location.value = 'Islamabad, Pakistan';
    description.value = '';
    imageUrls.clear();
  }

  void nextStep() {
    if (currentStep.value < 3) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  Future<void> loadMyReports() async {
    isLoading.value = true;
    try {
      myReports.value = await _service.getMyReports();
    } catch (e) {
      Get.log('Error loading reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitReport() async {
    // Disaster reports are dispatched to response teams — they need the
    // user's actual location, never a stored profile coordinate or city
    // centre. Block submission if real-time GPS isn't available.
    final coords = await _ensureLocation();
    if (coords == null) return false;

    try {
      isSubmitting.value = true;
      DialogHelpers.showLoadingDialog();

      final effectiveTitle = title.value.trim().isNotEmpty
          ? title.value.trim()
          : '${_capitalize(selectedType.value)} incident';
      final effectiveDescription = description.value.trim().isNotEmpty
          ? description.value.trim()
          : 'Citizen-reported $effectiveTitle';

      await _service.createReport(
        title: effectiveTitle,
        description: effectiveDescription,
        disasterType: selectedType.value,
        severity: selectedSeverity.value,
        latitude: coords.lat,
        longitude: coords.lng,
        address: location.value,
        imageUrls: imageUrls.toList(),
      );
      DialogHelpers.hideLoadingDialog();
      resetForm();
      return true;
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      // Offline submission: keep the report locally and let the outbox
      // drain it once connectivity returns. Image URLs already point at
      // already-uploaded storage paths so no binary needs replaying.
      if (isConnectivityError(e)) {
        final effectiveTitle = title.value.trim().isNotEmpty
            ? title.value.trim()
            : '${_capitalize(selectedType.value)} incident';
        final effectiveDescription = description.value.trim().isNotEmpty
            ? description.value.trim()
            : 'Citizen-reported $effectiveTitle';
        await _outbox.enqueue(PendingSubmission(
          id: 'report-${DateTime.now().microsecondsSinceEpoch}',
          kind: SubmissionKind.disasterReport,
          payload: {
            'title': effectiveTitle,
            'description': effectiveDescription,
            'disaster_type': selectedType.value,
            'severity': selectedSeverity.value,
            'latitude': coords.lat,
            'longitude': coords.lng,
            'address': location.value,
            'image_urls': imageUrls.toList(),
          },
          createdAt: DateTime.now(),
        ));
        DialogHelpers.showSuccess(
          title: 'Report Queued',
          message:
              "You're offline. Your report will be sent automatically as "
              'soon as a connection is available.',
        );
        resetForm();
        return true;
      }
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to submit report. Please try again.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Returns the device's current GPS coordinates, or null if location
  /// services are off, permission is denied, or the fix times out. On
  /// failure surfaces a dialog with a deep-link to OS settings; the
  /// caller must abort its flow when null is returned. Never falls back
  /// to a hardcoded coordinate — response teams must not be sent to the
  /// wrong place.
  Future<({double lat, double lng})?> _ensureLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await DialogHelpers.showLocationRequired(
          message:
              'Location services are off. Turn them on so response teams '
              "can find the incident you're reporting.",
        );
        return null;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await DialogHelpers.showLocationRequired(
          message:
              'We need your location to mark where the incident is. '
              'Please grant location permission and try again.',
        );
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      Get.log('DisasterReportController: location acquisition failed — $e');
      DialogHelpers.showFailure(
        title: "Couldn't get location",
        message:
            "We couldn't determine your location. Try again from a spot "
            'with better GPS signal.',
      );
      return null;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return 'Incident';
    return s[0].toUpperCase() + s.substring(1);
  }
}
