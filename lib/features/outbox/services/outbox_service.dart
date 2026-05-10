import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:safelink/features/outbox/models/pending_submission.dart';

/// Hive-backed queue for offline submissions.
///
/// Two boxes:
///   * `pending_submissions` — items waiting to be drained.
///   * `failed_submissions`  — items that exceeded [maxAttempts]; kept so
///     the user can retry or inspect from the UI.
///
/// Boxes must be opened by `main.dart` before this service is registered.
/// We don't open them here because Hive box opens are async and GetX
/// service registration is sync; doing it in main keeps the failure mode
/// explicit (the app won't start with a broken outbox).
class OutboxService extends GetxService {
  static const String pendingBoxName = 'pending_submissions';
  static const String failedBoxName = 'failed_submissions';
  static const int maxAttempts = 5;

  final Box<Map> _pending = Hive.box<Map>(pendingBoxName);
  final Box<Map> _failed = Hive.box<Map>(failedBoxName);

  int get pendingCount => _pending.length;
  int get failedCount => _failed.length;

  List<PendingSubmission> listPending() {
    return _pending.values
        .map((m) => PendingSubmission.fromMap(m))
        .toList(growable: false);
  }

  List<PendingSubmission> listFailed() {
    return _failed.values
        .map((m) => PendingSubmission.fromMap(m))
        .toList(growable: false);
  }

  Future<void> enqueue(PendingSubmission item) async {
    await _pending.put(item.id, item.toMap());
  }

  Future<void> remove(String id) async {
    await _pending.delete(id);
  }

  Future<void> markFailed(PendingSubmission item) async {
    await _pending.delete(item.id);
    await _failed.put(item.id, item.toMap());
  }

  Future<void> recordAttempt(PendingSubmission item, {String? error}) async {
    final next = item.copyWith(attempts: item.attempts + 1, lastError: error);
    if (next.attempts >= maxAttempts) {
      await markFailed(next);
    } else {
      await _pending.put(next.id, next.toMap());
    }
  }

  Future<void> clearFailed() async {
    await _failed.clear();
  }

  /// Re-queue an item from the failed box back to pending. Used by the
  /// "retry failed" affordance in the home indicator.
  Future<void> requeueFailed(String id) async {
    final raw = _failed.get(id);
    if (raw == null) return;
    final item = PendingSubmission.fromMap(raw);
    await _failed.delete(id);
    await _pending.put(
      item.id,
      item.copyWith(attempts: 0, lastError: null).toMap(),
    );
  }
}
