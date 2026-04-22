import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/aid/models/s_o_s_request_model.dart';
import 'package:safelink/features/aid/services/s_o_s_service.dart';
import 'package:safelink/features/profile/controllers/profile_controller.dart';

class SOSController extends GetxController {
  final SOSService _sosService = Get.find<SOSService>();

  final isLoading = false.obs;
  final isSending = false.obs;
  final activeRequest = Rxn<SOSRequestModel>();
  final myRequests = <SOSRequestModel>[].obs;

  final selectedType = SOSType.medical.obs;
  final description = ''.obs;
  final urgency = 'critical'.obs;
  final peopleCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
    checkActiveRequest();
  }

  Future<void> checkActiveRequest() async {
    try {
      activeRequest.value = await _sosService.getActiveSOSRequest();
    } catch (e) {
      Get.log('Error checking SOS: $e');
    }
  }

  Future<void> sendSOS() async {
    if (isSending.value) return;
    isSending.value = true;

    try {
      DialogHelpers.showLoadingDialog();

      final profileController = Get.find<ProfileController>();
      final profile = profileController.profile.value;

      final request = await _sosService.createSOSRequest(
        latitude: profile?.latitude ?? 33.6844,
        longitude: profile?.longitude ?? 73.0479,
        disasterType: selectedType.value,
        description: description.value.isEmpty ? null : description.value,
        urgency: urgency.value,
        peopleCount: peopleCount.value,
      );

      activeRequest.value = request;
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'SOS Sent',
        message: 'Emergency alert has been sent to nearby authorities.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'SOS Failed',
        message: 'Could not send SOS. Please try calling emergency services.',
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> cancelSOS() async {
    if (activeRequest.value == null) return;
    try {
      await _sosService.cancelSOSRequest(activeRequest.value!.id);
      activeRequest.value = null;
      DialogHelpers.showSuccess(
        title: 'Cancelled',
        message: 'SOS request has been cancelled.',
      );
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to cancel SOS request.',
      );
    }
  }

  Future<void> loadMyRequests() async {
    isLoading.value = true;
    try {
      myRequests.value = await _sosService.getMySOSRequests();
    } catch (e) {
      Get.log('Error loading SOS requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    selectedType.value = SOSType.medical;
    description.value = '';
    urgency.value = 'critical';
    peopleCount.value = 1;
  }
}
