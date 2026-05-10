import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/features/aid/controllers/s_o_s_controller.dart';
import 'package:safelink/features/aid/models/s_o_s_request_model.dart';
import 'package:safelink/features/authorization/services/auth_service.dart';
import 'package:safelink/features/profile/models/profile_model.dart';
import 'package:safelink/features/profile/services/profile_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController with WidgetsBindingObserver {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final isUploadingAvatar = false.obs;
  final profile = Rxn<ProfileModel>();
  final activeRequestCount = 0.obs;
  final alertsReceivedCount = 0.obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;
  Worker? _sosWorker;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    loadProfile();
    _listenToAuthChanges();
    // SOSController is registered as a permanent singleton in
    // InitialBindings; defer the wire-up until after the current init
    // pass so we don't depend on registration order between
    // ProfileController and SOSController.
    Future.microtask(_listenToSosChanges);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _sosWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Counters and profile may have changed while backgrounded
    // (e.g., gov dispatch resolves an SOS, alert notifications
    // arrive). Refresh on resume so the profile screen is honest
    // about server state without requiring a manual pull-to-refresh.
    if (state == AppLifecycleState.resumed) {
      refreshProfile();
    }
  }

  void _listenToAuthChanges() {
    final auth = Get.find<AuthService>();
    _authSub = auth.authStateChanges.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        _lastSeenUserId = null;
        profile.value = null;
        activeRequestCount.value = 0;
        alertsReceivedCount.value = 0;
        return;
      }
      // signedIn, tokenRefreshed, and initialSession all carry a session
      // payload when one exists. React to any session that brings a new
      // user id into view. This is what handles cold-start on a returning
      // user — Supabase fires initialSession (not signedIn) when a token
      // is restored from local storage, which the previous implementation
      // missed and which is why the counters were stuck at 0 on warm boot.
      final newUserId = data.session?.user.id;
      if (newUserId != null && newUserId != _lastSeenUserId) {
        _lastSeenUserId = newUserId;
        loadProfile();
      }
    });
  }

  void _listenToSosChanges() {
    if (!Get.isRegistered<SOSController>()) return;
    final sos = Get.find<SOSController>();
    _sosWorker = ever<SOSRequestModel?>(sos.activeRequest, (_) {
      // Active SOS state just changed (sent, drained from outbox,
      // dispatched, resolved, cancelled). Refresh the citizen summary
      // so Active Requests reflects DB truth without requiring a
      // screen revisit.
      loadCitizenSummary();
    });
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _profileService.getProfile();
      await loadCitizenSummary();
    } catch (e) {
      Get.log('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updated = await _profileService.updateProfile(updates);
      profile.value = updated;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.log('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  Future<void> loadCitizenSummary() async {
    try {
      final data = await _profileService.getCitizenSummary();
      if (data == null) return;
      activeRequestCount.value = (data['active_sos'] as num?)?.toInt() ?? 0;
      alertsReceivedCount.value =
          (data['alerts_received'] as num?)?.toInt() ?? 0;
    } catch (e) {
      Get.log('Error loading citizen summary: $e');
    }
  }

  Future<void> uploadAvatar(Uint8List fileBytes) async {
    isUploadingAvatar.value = true;
    try {
      final updated = await _profileService.uploadAvatar(fileBytes);
      profile.value =
          profile.value?.copyWith(avatarUrl: updated.avatarUrl) ?? updated;
    } catch (e) {
      Get.log('Error uploading avatar: $e');
      Get.snackbar('Error', 'Failed to upload profile picture');
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  String get fullName {
    if (profile.value == null) return 'User';
    return '${profile.value!.firstName} ${profile.value!.lastName}';
  }

  String get phone => profile.value?.phone ?? '';
  String get email => profile.value?.email ?? '';
  String? get avatarUrl => profile.value?.avatarUrl;

  Future<void> refreshProfile() async {
    await loadProfile();
  }
}
