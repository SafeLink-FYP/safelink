import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends GetxService {
  static const _prefix = 'settings_';

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$key') ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', value);
  }

  Future<String> getString(String key, {String defaultValue = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key') ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', value);
  }

  Future<Map<String, dynamic>> loadAllSettings() async {
    return {
      'pushNotifications': await getBool(
        'pushNotifications',
        defaultValue: true,
      ),
      'alertSounds': await getBool('alertSounds', defaultValue: true),
      'vibration': await getBool('vibration', defaultValue: true),
      'locationServices': await getBool('locationServices', defaultValue: true),
      'backgroundLocation': await getBool('backgroundLocation'),
      'autoSOS': await getBool('autoSOS'),
      'offlineMaps': await getBool('offlineMaps', defaultValue: true),
      'dataSync': await getBool('dataSync', defaultValue: true),
      'language': await getString('language', defaultValue: 'English'),
      'alertRadius': await getString('alertRadius', defaultValue: '25 km'),
    };
  }
}
