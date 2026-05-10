import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Hive-backed offline queue for chatbot feedback submissions.
///
/// Mirrors the public shape of [OutboxService] (the SOS / disaster-report
/// outbox), simplified to a single pending box: feedback items past
/// [maxAttempts] are silently dropped (logged) rather than persisted to a
/// failed box, since uploading user feedback is best-effort.
@immutable
class FeedbackSubmission {
  final String id;
  final String messageId;
  final bool helpful;
  final String? comment;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  const FeedbackSubmission({
    required this.id,
    required this.messageId,
    required this.helpful,
    this.comment,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'message_id': messageId,
        'helpful': helpful,
        if (comment != null) 'comment': comment,
        'created_at': createdAt.toIso8601String(),
        'attempts': attempts,
        if (lastError != null) 'last_error': lastError,
      };

  factory FeedbackSubmission.fromMap(Map<dynamic, dynamic> map) {
    return FeedbackSubmission(
      id: map['id'] as String,
      messageId: map['message_id'] as String,
      helpful: map['helpful'] as bool,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      attempts: (map['attempts'] as int?) ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  FeedbackSubmission copyWith({
    int? attempts,
    String? lastError,
  }) =>
      FeedbackSubmission(
        id: id,
        messageId: messageId,
        helpful: helpful,
        comment: comment,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
      );
}

class FeedbackOutboxService extends GetxService {
  // Phase 1 locked decision (O9): this name is persisted on user devices
  // forever; renaming will require a Hive migration. Box opened in main.dart.
  static const String boxName = 'chatbot_feedback_outbox';
  static const int maxAttempts = 5;

  static const _uuid = Uuid();

  final Box<Map> _pending = Hive.box<Map>(boxName);

  int get pendingCount => _pending.length;

  List<FeedbackSubmission> listPending() => _pending.values
      .map((m) => FeedbackSubmission.fromMap(m))
      .toList(growable: false);

  Future<FeedbackSubmission> enqueue({
    required String messageId,
    required bool helpful,
    String? comment,
  }) async {
    final item = FeedbackSubmission(
      id: _uuid.v4(),
      messageId: messageId,
      helpful: helpful,
      comment: comment,
      createdAt: DateTime.now(),
    );
    await _pending.put(item.id, item.toMap());
    return item;
  }

  Future<void> remove(String id) async {
    await _pending.delete(id);
  }

  /// Record a failed delivery attempt. Items past [maxAttempts] are dropped
  /// — feedback is best-effort, not durably critical.
  Future<void> recordAttempt(
    FeedbackSubmission item, {
    String? error,
  }) async {
    final next = item.copyWith(attempts: item.attempts + 1, lastError: error);
    if (next.attempts >= maxAttempts) {
      Get.log(
        'FeedbackOutbox: dropping item ${item.id} after $maxAttempts attempts '
        '(last error: $error)',
      );
      await _pending.delete(item.id);
    } else {
      await _pending.put(next.id, next.toMap());
    }
  }
}
