import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Loads platform metadata (app version + build number) once at app
/// start so the Settings screen's About section can render the real
/// values from pubspec rather than a hand-edited string.
///
/// All other settings — push / sound / vibration / location / radius /
/// offline-maps / auto-sync / language — were UI lies that controlled
/// features the app does not implement. They were removed from the
/// controller, the view, and this service in PR-18 c4. Dark mode is
/// the only real toggle and is owned by ThemeController directly.
class SettingsService extends GetxService {
  PackageInfo? _packageInfo;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      Get.log('SettingsService: failed to load package info — $e');
    }
  }

  /// "SafeLink v1.0.0" or a placeholder if package_info hasn't loaded
  /// yet (and never will if the platform channel failed). The fallback
  /// is intentionally honest — we don't pretend a version we couldn't
  /// read.
  String get appVersion {
    final info = _packageInfo;
    if (info == null) return 'SafeLink — version unavailable';
    return 'SafeLink v${info.version}';
  }
}
