import 'package:get/get.dart';
import 'package:safelink/features/settings/services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _service = Get.find<SettingsService>();

  final pushNotifications = true.obs;
  final alertSounds = true.obs;
  final vibration = true.obs;
  final locationServices = true.obs;
  final backgroundLocation = false.obs;
  final autoSOS = false.obs;
  final offlineMaps = true.obs;
  final dataSync = true.obs;
  final language = 'English'.obs;
  final alertRadius = '25 km'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadAllSettings();
    pushNotifications.value = settings['pushNotifications'] as bool;
    alertSounds.value = settings['alertSounds'] as bool;
    vibration.value = settings['vibration'] as bool;
    locationServices.value = settings['locationServices'] as bool;
    backgroundLocation.value = settings['backgroundLocation'] as bool;
    autoSOS.value = settings['autoSOS'] as bool;
    offlineMaps.value = settings['offlineMaps'] as bool;
    dataSync.value = settings['dataSync'] as bool;
    language.value = settings['language'] as String;
    alertRadius.value = settings['alertRadius'] as String;
  }

  Future<void> toggleBool(String key, RxBool value) async {
    value.toggle();
    await _service.setBool(key, value.value);
  }
}
