import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/dashboard/models/aid_request_model.dart';
import 'package:safelink/features/dashboard/services/aid_request_service.dart';

class AidRequestController extends GetxController {
  final AidRequestService _service = Get.find<AidRequestService>();

  final isLoading = false.obs;
  final myRequests = <AidRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyRequests();
  }

  Future<void> loadMyRequests() async {
    isLoading.value = true;
    try {
      myRequests.value = await _service.getMyAidRequests();
    } catch (e) {
      Get.log('Error loading aid requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRequest({
    required String type,
    String? description,
    required String urgency,
    int quantity = 1,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      DialogHelpers.showLoadingDialog();
      final request = await _service.createAidRequest(
        type: type,
        description: description,
        urgency: urgency,
        quantity: quantity,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      myRequests.insert(0, request);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Request Submitted',
        message: 'Your aid request has been submitted.',
      );
      Get.back();
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to submit request. Please try again.',
      );
    }
  }

  Future<void> cancelRequest(String id) async {
    try {
      await _service.cancelAidRequest(id);
      await loadMyRequests();
      DialogHelpers.showSuccess(
        title: 'Cancelled',
        message: 'Aid request has been cancelled.',
      );
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to cancel request.',
      );
    }
  }

  int get activeRequestCount =>
      myRequests.where((r) => r.status == 'pending' || r.status == 'in_progress').length;
}
