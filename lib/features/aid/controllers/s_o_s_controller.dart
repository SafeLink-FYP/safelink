import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/aid/models/s_o_s_request_model.dart';
import 'package:safelink/features/aid/services/s_o_s_service.dart';
import 'package:safelink/features/outbox/controllers/outbox_controller.dart';
import 'package:safelink/features/outbox/models/pending_submission.dart';

class SOSController extends GetxController with WidgetsBindingObserver {
  final SOSService _sosService = Get.find<SOSService>();
  final OutboxController _outbox = Get.find<OutboxController>();

  final isLoading = false.obs;
  final isSending = false.obs;
  final activeRequest = Rxn<SOSRequestModel>();
  final myRequests = <SOSRequestModel>[].obs;

  final selectedType = SOSType.medical.obs;
  final description = ''.obs;
  final urgency = 'critical'.obs;
  final peopleCount = 1.obs;

  Worker? _drainWorker;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    checkActiveRequest();
    // After the offline outbox finishes a drain cycle, our local
    // active-request state can be stale: a queued SOS may have just
    // landed in Supabase via OutboxController._submit, bypassing the
    // in-session sendSOS() path that updates activeRequest. Re-hydrate
    // on the false-transition of isDraining so the SOS button reflects
    // the new pending row without requiring an app restart.
    _drainWorker = ever<bool>(_outbox.isDraining, (draining) {
      if (!draining) checkActiveRequest();
    });
  }

  @override
  void onClose() {
    _drainWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app is resumed from background, an SOS row may have
    // been inserted, updated, or cancelled while we were paused
    // (e.g., gov-side dispatch action against an existing request).
    // Re-fetch so the button state is honest about server state.
    if (state == AppLifecycleState.resumed) {
      checkActiveRequest();
    }
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

    // Emergency dispatch needs real-time GPS — never silently fall back
    // to the user's stored profile location or a hardcoded city centre.
    final location = await _ensureLocation();
    if (location == null) return;

    isSending.value = true;
    try {
      DialogHelpers.showLoadingDialog();

      final request = await _sosService.createSOSRequest(
        latitude: location.lat,
        longitude: location.lng,
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
      // Lost connectivity mid-call — preserve the dispatch by queueing
      // it locally. Drain runs as soon as the device is back online.
      if (isConnectivityError(e)) {
        await _outbox.enqueue(PendingSubmission(
          id: 'sos-${DateTime.now().microsecondsSinceEpoch}',
          kind: SubmissionKind.sos,
          payload: {
            'latitude': location.lat,
            'longitude': location.lng,
            'disaster_type': selectedType.value.name,
            'description': description.value.isEmpty ? null : description.value,
            'urgency': urgency.value,
            'people_count': peopleCount.value,
          },
          createdAt: DateTime.now(),
        ));
        DialogHelpers.showSuccess(
          title: 'SOS Queued',
          message:
              "You're offline. Your SOS will be sent automatically as "
              'soon as a connection is available.',
        );
      } else {
        DialogHelpers.showFailure(
          title: 'SOS Failed',
          message: 'Could not send SOS. Please try calling emergency services.',
        );
      }
    } finally {
      isSending.value = false;
    }
  }

  /// Returns the device's current GPS coordinates, or null if location
  /// services are off, permission is denied, or the fix times out. On
  /// failure surfaces a dialog with a deep-link to OS settings; the
  /// caller must abort its flow when null is returned. Never falls back
  /// to a hardcoded coordinate — emergency dispatch must not lie about
  /// where the user is.
  Future<({double lat, double lng})?> _ensureLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await DialogHelpers.showLocationRequired(
          message:
              'Location services are off. Turn them on so help can be '
              'dispatched to your actual location.',
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
              'We need your location to dispatch help. Please grant '
              'location permission and try again.',
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
      Get.log('SOSController: location acquisition failed — $e');
      DialogHelpers.showFailure(
        title: "Couldn't get location",
        message:
            "We couldn't determine your location. Try again or call "
            'emergency services directly.',
      );
      return null;
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
