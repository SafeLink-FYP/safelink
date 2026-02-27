import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickingController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxBool isPicking = false.obs;

  Future<void> pickImage() async {
    try {
      isPicking.value = true;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPicking.value = false;
    }
  }

  Future<void> getLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return;

    if (response.file != null) {
      selectedImage.value = response.file;
    } else {
      Get.snackbar(
        'Error',
        response.exception?.message ?? 'Image recovery failed',
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    getLostData();
  }
}
