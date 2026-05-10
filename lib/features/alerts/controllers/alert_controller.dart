import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:safelink/core/services/supabase_service.dart';
import 'package:safelink/core/utilities/dialog_helpers.dart';
import 'package:safelink/features/alerts/models/alert_model.dart';
import 'package:safelink/features/alerts/services/alert_service.dart';
import 'package:safelink/features/dashboard/controllers/ml_alert_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, PostgresChangeEvent, RealtimeChannel;

/// Citizen-side controller for government-issued alerts (the `alerts` table).
///
/// Distinct from `MlAlertController`, which surfaces ML-generated earthquake
/// + flood predictions from the FastAPI backend. The two coexist: gov alerts
/// are authoritative; ML predictions are probabilistic. Both render on the
/// dashboard in distinct sections.
///
/// Pre-Phase-3-Active-Alerts-split this controller bridged ML data into
/// AlertModel form via _constructAlertsFromMlData. Gov alerts written to
/// the `alerts` table by gov officials were never surfaced anywhere in
/// citizen UI. This controller now actually loads gov alerts via
/// AlertService and subscribes to realtime INSERT/UPDATE events on the
/// alerts table. Mirrors gov SOSController canonical lifecycle pattern.
class AlertController extends GetxController with WidgetsBindingObserver {
  final AlertService _alertService = Get.find<AlertService>();
  // Read-only dependency: AlertController reuses MlAlertController's
  // already-resolved location for the get_active_alerts_for_location
  // RPC. Does NOT consume ML data; that's PredictedAlertsHomeSection's
  // job via MlAlertController directly.
  final MlAlertController _mlController = Get.find<MlAlertController>();

  final isLoading = false.obs;
  final hasLoadedOnce = false.obs;
  final alerts = <AlertModel>[].obs;
  final selectedAlert = Rxn<AlertModel>();

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    loadAlerts();
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    if (_lastSeenUserId != null) _subscribeRealtime(_lastSeenUserId!);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _unsubscribeRealtime();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On resume the alerts list may have been mutated externally
    // (gov broadcast a new alert while backgrounded, or de-activated
    // an existing one). Reload so the dashboard reflects DB truth.
    if (state == AppLifecycleState.resumed) {
      loadAlerts();
    }
  }

  void _onAuthChange(AuthState state) {
    final newUserId = state.session?.user.id;
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        _lastSeenUserId = null;
        alerts.clear();
        selectedAlert.value = null;
        _unsubscribeRealtime();
        break;
      default:
        // signedIn / tokenRefreshed / initialSession all carry a session
        // when one exists. Dedupe via _lastSeenUserId so same-user token
        // refreshes don't churn.
        if (newUserId != null && newUserId != _lastSeenUserId) {
          _lastSeenUserId = newUserId;
          alerts.clear();
          _unsubscribeRealtime();
          loadAlerts();
          _subscribeRealtime(newUserId);
        }
        break;
    }
  }

  /// Loads alerts from the server. Uses the location-filtered RPC when
  /// MlAlertController has resolved the citizen's real position; falls
  /// back to fetching ALL active alerts (country-wide treatment) when
  /// the Pakistan-centre fallback is in use.
  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      List<AlertModel> result;
      if (_mlController.hasUserLocation.value) {
        result = await _alertService.getAlertsForLocation(
          _mlController.lat,
          _mlController.lng,
        );
      } else {
        result = await _alertService.getActiveAlerts();
      }
      alerts.value = result;
      hasLoadedOnce.value = true;
    } catch (e) {
      Get.log('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subscribes to INSERT + UPDATE on the `alerts` table. The realtime
  /// publication includes `alerts`; new gov broadcasts arrive within
  /// ~one round-trip. No client-side channel filter — the table's RLS
  /// is "all authenticated read" so all rows are deliverable; location
  /// relevance is enforced at load time via the RPC, but realtime
  /// receives the raw row + we let the citizen see any new active alert
  /// (the country-wide fan-out is a known trigger-side concern; see
  /// commit message follow-ups).
  void _subscribeRealtime(String userId) {
    _channel = SupabaseService.instance.client
        .channel('alerts:citizen:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'alerts',
          callback: (payload) {
            try {
              final row = AlertModel.fromJson(
                Map<String, dynamic>.from(payload.newRecord),
              );
              if (!row.isActive) return;
              if (alerts.any((a) => a.id == row.id)) return;
              alerts.insert(0, row);
            } catch (e) {
              Get.log('Realtime ALERT INSERT decode failed: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'alerts',
          callback: (payload) {
            try {
              final updated = AlertModel.fromJson(
                Map<String, dynamic>.from(payload.newRecord),
              );
              final idx = alerts.indexWhere((a) => a.id == updated.id);
              if (idx == -1) {
                // Row appeared via UPDATE without an INSERT we saw (e.g.
                // alert was deactivated then reactivated while we were
                // offline). Treat as a new addition iff active.
                if (updated.isActive) alerts.insert(0, updated);
                return;
              }
              if (!updated.isActive) {
                // Gov flipped is_active to false → remove from list.
                alerts.removeAt(idx);
                return;
              }
              alerts[idx] = updated;
              if (selectedAlert.value?.id == updated.id) {
                selectedAlert.value = updated;
              }
            } catch (e) {
              Get.log('Realtime ALERT UPDATE decode failed: $e');
            }
          },
        )
        .subscribe();
  }

  void _unsubscribeRealtime() {
    final ch = _channel;
    if (ch == null) return;
    SupabaseService.instance.client.removeChannel(ch);
    _channel = null;
  }

  Future<void> viewAlert(String id) async {
    try {
      selectedAlert.value = await _alertService.getAlertById(id);
    } catch (_) {
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to load alert details',
      );
    }
  }

  Future<void> refreshAlerts() => loadAlerts();

  String getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return 'assets/icons/Droplets-Icon.svg';
      case 'earthquake':
        return 'assets/icons/Wave-Icon.svg';
      case 'medical':
        return 'assets/icons/Warning-Icon.svg';
      default:
        return 'assets/icons/Warning-Icon.svg';
    }
  }
}
