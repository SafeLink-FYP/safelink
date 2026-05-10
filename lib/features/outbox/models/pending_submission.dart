import 'package:flutter/foundation.dart';

/// Discriminator for the kind of submission stored in the outbox.
/// Keep these strings stable — they're persisted in Hive.
class SubmissionKind {
  static const String sos = 'sos';
  static const String disasterReport = 'disaster_report';
}

/// Wrapper around the `Map<String, dynamic>` payloads we persist in Hive.
/// We store as raw maps (no TypeAdapter) so adding new fields doesn't
/// require a code-gen pass; this class just gives us typed read access.
@immutable
class PendingSubmission {
  final String id;
  final String kind;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  const PendingSubmission({
    required this.id,
    required this.kind,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'attempts': attempts,
        if (lastError != null) 'last_error': lastError,
      };

  factory PendingSubmission.fromMap(Map<dynamic, dynamic> map) {
    return PendingSubmission(
      id: map['id'] as String,
      kind: map['kind'] as String,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: DateTime.parse(map['created_at'] as String),
      attempts: (map['attempts'] as int?) ?? 0,
      lastError: map['last_error'] as String?,
    );
  }

  PendingSubmission copyWith({
    int? attempts,
    String? lastError,
  }) =>
      PendingSubmission(
        id: id,
        kind: kind,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
      );
}
