import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:safelink/features/profile/models/profile_model.dart';
import 'package:safelink/features/profile/services/profile_services.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final isUploadingAvatar = false.obs;
  final profile = Rxn<ProfileModel>();
  final activeRequestCount = 0.obs;
  final alertsReceivedCount = 0.obs;
  final daysSafe = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _profileService.getProfile();

      if (profile.value?.createdAt != null) {
        final createdAt = DateTime.tryParse(profile.value!.createdAt!);
        if (createdAt != null) {
          daysSafe.value = DateTime.now().difference(createdAt).inDays;
        }
      }
    } catch (e) {
      Get.log('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updated = await _profileService.updateProfile(updates);
      profile.value = profile.value?.copyWith(
        firstName: updated.firstName,
        lastName: updated.lastName,
        phone: updated.phone,
        dateOfBirth: updated.dateOfBirth,
        avatarUrl: updated.avatarUrl,
        city: updated.city,
        province: updated.province,
        latitude: updated.latitude,
        longitude: updated.longitude,
      ) ??
          updated;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.log('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  Future<void> uploadAvatar(Uint8List fileBytes) async {
    isUploadingAvatar.value = true;
    try {
      final updated = await _profileService.uploadAvatar(fileBytes);
      profile.value = profile.value?.copyWith(avatarUrl: updated.avatarUrl) ??
          updated;
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