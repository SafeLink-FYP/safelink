import 'package:get/get.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/profile/services/profile_services.dart';
import 'package:safelink/shared/models/emergency_contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
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

  Future<void> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    try {
      DialogHelpers.showLoadingDialog();
      final contact = await _profileService.addEmergencyContact({
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'is_primary': isPrimary,
      });
      contacts.add(contact);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Success',
        message: 'Emergency contact added.',
      );
      Get.back();
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to add contact.',
      );
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

