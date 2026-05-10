import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' show ClientException;

import 'package:safelink/features/aid/models/s_o_s_request_model.dart';
import 'package:safelink/features/aid/services/disaster_report_service.dart';
import 'package:safelink/features/aid/services/s_o_s_service.dart';
import 'package:safelink/features/outbox/models/pending_submission.dart';
import 'package:safelink/features/outbox/services/connectivity_service.dart';
import 'package:safelink/features/outbox/services/outbox_service.dart';

/// Coordinates the outbox: exposes reactive counts to the UI and triggers
/// a drain whenever connectivity is restored. Submission is dispatched
/// internally by [PendingSubmission.kind] — adding a new submission
/// kind means extending [_submit] and the call site that enqueues.
class OutboxController extends GetxController {
  final OutboxService _outbox = Get.find<OutboxService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();

  final pendingCount = 0.obs;
  final failedCount = 0.obs;
  final isDraining = false.obs;

  Worker? _onlineWorker;

  @override
  void onInit() {
    super.onInit();
    _refreshCounts();
    _onlineWorker = ever<bool>(_connectivity.isOnline, (online) {
      if (online) drain();
    });
    if (_connectivity.isOnline.value) {
      // Fire once on boot so anything sitting in the queue from the last
      // session goes out as soon as the rest of the app finishes booting.
      Future.delayed(const Duration(seconds: 2), drain);
    }
  }

  @override
  void onClose() {
    _onlineWorker?.dispose();
    super.onClose();
  }

  Future<void> enqueue(PendingSubmission item) async {
    await _outbox.enqueue(item);
    _refreshCounts();
    if (_connectivity.isOnline.value) {
      // Try to drain immediately so an online enqueue isn't delayed
      // until the next connectivity flip.
      unawaited(drain());
    }
  }

  Future<void> drain() async {
    if (isDraining.value) return;
    if (!_connectivity.isOnline.value) return;
    isDraining.value = true;
    try {
      for (final item in _outbox.listPending()) {
        if (!_connectivity.isOnline.value) break;
        try {
          await _submit(item);
          await _outbox.remove(item.id);
        } on _TransientOutboxError catch (e) {
          await _outbox.recordAttempt(item, error: e.message);
        } catch (e) {
          // Permanent error (validation, RLS, etc.) — push straight to
          // the failed box so we don't keep retrying a doomed payload.
          await _outbox.markFailed(item.copyWith(lastError: e.toString()));
        }
        _refreshCounts();
      }
    } finally {
      isDraining.value = false;
    }
  }

  Future<void> retryFailed(String id) async {
    await _outbox.requeueFailed(id);
    _refreshCounts();
    if (_connectivity.isOnline.value) unawaited(drain());
  }

  Future<void> clearFailed() async {
    await _outbox.clearFailed();
    _refreshCounts();
  }

  List<PendingSubmission> get pending => _outbox.listPending();
  List<PendingSubmission> get failed => _outbox.listFailed();

  Future<void> _submit(PendingSubmission item) async {
    try {
      switch (item.kind) {
        case SubmissionKind.sos:
          final sos = Get.find<SOSService>();
          final p = item.payload;
          await sos.createSOSRequest(
            latitude: (p['latitude'] as num).toDouble(),
            longitude: (p['longitude'] as num).toDouble(),
            disasterType: SOSType.fromString(p['disaster_type'] as String),
            description: p['description'] as String?,
            urgency: (p['urgency'] as String?) ?? 'critical',
            peopleCount: (p['people_count'] as num?)?.toInt() ?? 1,
          );
          break;
        case SubmissionKind.disasterReport:
          final reports = Get.find<DisasterReportService>();
          final p = item.payload;
          await reports.createReport(
            title: p['title'] as String,
            description: p['description'] as String,
            disasterType: p['disaster_type'] as String,
            severity: (p['severity'] as String?) ?? 'high',
            latitude: (p['latitude'] as num).toDouble(),
            longitude: (p['longitude'] as num).toDouble(),
            address: p['address'] as String?,
            imageUrls: (p['image_urls'] as List?)?.cast<String>() ?? const [],
          );
          break;
        default:
          throw StateError('Unknown outbox kind: ${item.kind}');
      }
    } on SocketException catch (e) {
      throw _TransientOutboxError(e.message);
    } on TimeoutException catch (e) {
      throw _TransientOutboxError(e.message ?? 'request timed out');
    } on ClientException catch (e) {
      throw _TransientOutboxError(e.message);
    }
  }

  void _refreshCounts() {
    pendingCount.value = _outbox.pendingCount;
    failedCount.value = _outbox.failedCount;
  }
}

/// Marks a drain failure as transient so [drain] keeps the item in the
/// pending box (with an incremented attempt counter) instead of moving
/// it to the failed box.
class _TransientOutboxError implements Exception {
  final String message;
  _TransientOutboxError(this.message);
  @override
  String toString() => 'TransientOutboxError: $message';
}

/// True when a thrown error looks like loss of connectivity rather than
/// a server-side rejection. Used by feature controllers to decide
/// whether to enqueue a failed submission instead of bubbling the error.
bool isConnectivityError(Object error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is ClientException) return true;
  return false;
}
