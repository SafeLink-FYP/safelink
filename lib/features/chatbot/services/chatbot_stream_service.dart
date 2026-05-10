import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:safelink/core/secrets/app_secrets.dart';

import '../models/chat_models.dart';

/// One streamed event from `POST /api/v1/chat/stream`.
///
/// `delta` is the incremental text chunk. `done=true` carries the final
/// metadata payload (sources / helplines / suggested_actions / messageId).
class ChatStreamEvent {
  final String messageId;
  final String delta;
  final bool done;
  final List<SourceCitation> sources;
  final List<HelplineInfo> helplines;
  final List<String> suggestedActions;
  final bool usedLlm;
  final String? providerUsed;
  final String? error;

  const ChatStreamEvent({
    required this.messageId,
    this.delta = '',
    this.done = false,
    this.sources = const [],
    this.helplines = const [],
    this.suggestedActions = const [],
    this.usedLlm = false,
    this.providerUsed,
    this.error,
  });

  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) {
    return ChatStreamEvent(
      messageId: (json['message_id'] as String?) ?? '',
      delta: (json['delta'] as String?) ?? '',
      done: json['done'] as bool? ?? false,
      sources: ((json['sources'] as List?) ?? const [])
          .map((s) => SourceCitation.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      helplines: ((json['helplines'] as List?) ?? const [])
          .map((h) => HelplineInfo.fromJson(Map<String, dynamic>.from(h as Map)))
          .toList(),
      suggestedActions: ((json['suggested_actions'] as List?) ?? const [])
          .cast<String>(),
      usedLlm: json['used_llm'] as bool? ?? false,
      providerUsed: json['provider_used'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// SSE client for the streaming chat endpoint.
///
/// Phase 4 v1 caveat: the backend ships SSE produced by the `sse-starlette`
/// `EventSourceResponse`, which writes `event: <name>\ndata: <json>\n\n`
/// blocks. We parse line-delimited deltas + a final `done` event.
///
/// Failure modes (locked Phase 4 fallback chain): SSE → non-streaming POST
/// → offline. The fallback is owned by the controller; this service just
/// surfaces a Stream.
class ChatbotStreamService {
  String get _baseUrl => '${AppSecrets.chatbotBaseUrl}/api/v1';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        if (AppSecrets.chatbotApiKey.isNotEmpty)
          'X-API-Key': AppSecrets.chatbotApiKey,
      };

  /// Open a streaming connection. Yields ChatStreamEvent objects until
  /// the server emits `done` or the stream errors. Caller is responsible
  /// for falling back on error.
  Stream<ChatStreamEvent> streamMessage({
    required String message,
    String? sessionId,
    String region = 'pakistan',
    String? city,
    String language = 'en',
    Map<String, double>? location,
    bool offlineContext = false,
    Duration timeout = const Duration(seconds: 30),
  }) async* {
    final body = jsonEncode(
      ChatRequest(
        message: message,
        sessionId: sessionId,
        region: region,
        city: city,
        language: language,
        location: location,
        offlineContext: offlineContext,
      ).toJson(),
    );

    final client = http.Client();
    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/stream'))
      ..headers.addAll(_headers)
      ..body = body;

    http.StreamedResponse response;
    try {
      response = await client.send(request).timeout(timeout);
    } catch (e) {
      client.close();
      throw _ChatStreamException('connect failed: $e');
    }

    if (response.statusCode != 200) {
      client.close();
      throw _ChatStreamException('HTTP ${response.statusCode}');
    }

    try {
      // SSE blocks are separated by blank lines. Each block has zero or
      // more `event:` / `data:` lines. We accumulate `data:` payloads and
      // emit one event per block.
      final buffer = StringBuffer();

      await for (final chunk
          in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.isEmpty) {
          // End of one SSE block — flush.
          final dataStr = buffer.toString();
          buffer.clear();
          if (dataStr.isEmpty) continue;
          try {
            final json = jsonDecode(dataStr) as Map<String, dynamic>;
            final ev = ChatStreamEvent.fromJson(json);
            yield ev;
            if (ev.done) return;
          } catch (_) {
            // Malformed block — skip without yielding.
          }
          continue;
        }
        if (chunk.startsWith('data:')) {
          buffer.write(chunk.substring('data:'.length).trim());
        }
        // event: / id: / retry: lines are read-but-ignored. The downstream
        // logic doesn't differentiate by event type; the JSON `done` flag
        // is the loop terminator.
      }
    } finally {
      client.close();
    }
  }
}

class _ChatStreamException implements Exception {
  final String message;
  _ChatStreamException(this.message);
  @override
  String toString() => 'ChatStreamException: $message';
}
