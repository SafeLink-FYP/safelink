import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/dashboard/models/disaster_report_model.dart';
import 'package:safelink/features/dashboard/services/disaster_report_service.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';

class DisasterReportController extends GetxController {
  final DisasterReportService _service = Get.find<DisasterReportService>();

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
    try {
      isSubmitting.value = true;
      DialogHelpers.showLoadingDialog();

      final profile = Get.find<ProfileController>().profile.value;
      final lat = profile?.latitude ?? 33.6844;
      final lng = profile?.longitude ?? 73.0479;

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
        latitude: lat,
        longitude: lng,
        address: location.value,
        imageUrls: imageUrls.toList(),
      );
      DialogHelpers.hideLoadingDialog();
      resetForm();
      return true;
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to submit report. Please try again.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return 'Incident';
    return s[0].toUpperCase() + s.substring(1);
  }
}
