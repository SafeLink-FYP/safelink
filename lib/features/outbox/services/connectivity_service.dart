import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Thin GetX service around `connectivity_plus`.
/// Exposes a single reactive [isOnline] flag that other controllers can
/// `ever()` on. We treat anything that isn't `none` as "online" — actual
/// reachability is verified at request time by the submission services.
class ConnectivityService extends GetxService {
  final isOnline = true.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      isOnline.value = _hasConnectivity(initial);
    } catch (e) {
      Get.log('ConnectivityService initial check failed: $e');
    }
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _hasConnectivity(results);
    });
  }

  bool _hasConnectivity(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
