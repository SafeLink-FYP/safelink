import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/profile/services/profile_services.dart';
import 'package:safelink/shared/models/emergency_contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final contacts = <EmergencyContactModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    try {
      contacts.value = await _profileService.getEmergencyContacts();
    } catch (e) {
      Get.log('Error loading emergency contacts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns true on success, false on failure (or if a concurrent
  /// submit is in flight). Caller is responsible for popping the
  /// bottom sheet and showing the success snackbar — keeping that
  /// sequencing in the view ensures the snackbar (a route in GetX)
  /// doesn't push between the controller's loading-dialog dismiss
  /// and the view's intended pop. Failure snackbar stays inline
  /// because it doesn't need to interleave with a pop.
  Future<bool> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    if (isSubmitting.value) return false;
    try {
      isSubmitting.value = true;
      DialogHelpers.showLoadingDialog();
      final contact = await _profileService.addEmergencyContact({
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'is_primary': isPrimary,
      });
      contacts.add(contact);
      DialogHelpers.hideLoadingDialog();
      return true;
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to add contact.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _profileService.deleteEmergencyContact(id);
      contacts.removeWhere((c) => c.id == id);
      DialogHelpers.showSuccess(title: 'Deleted', message: 'Contact removed.');
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to delete contact.',
      );
    }
  }

  Future<void> refreshContacts() async {
    await loadContacts();
  }

  Future<void> makeCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not open dialer');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to launch dialer: $e');
    }
  }
}

