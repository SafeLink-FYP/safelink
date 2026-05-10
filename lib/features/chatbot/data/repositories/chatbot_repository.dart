import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/chatbot_local_store_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_offline_response_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_remote_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_stream_service.dart';
import 'package:safelink/features/chatbot/services/feedback_outbox_service.dart';
import 'package:safelink/features/outbox/services/connectivity_service.dart';

/// Phase 4 reconnect cadence. While `_isOffline=true` we silently probe the
/// backend on this interval; first 200 flips us back online (locked F4
/// finish).
const Duration _reconnectPollInterval = Duration(seconds: 30);

class ChatbotRepository {
  final ChatbotRemoteService _remote;
  final ChatbotStreamService _stream;
  final ChatbotLocalStoreService _localStore;
  final ChatbotOfflineResponseService _offlineResponse;
  final FeedbackOutboxService? _feedbackOutbox;
  final ConnectivityService? _connectivity;

  String? _sessionId;
  OfflineData? _offlineData;
  bool _isOffline = false;
  late final Future<void> _readyFuture;
  Worker? _connectivityWorker;
  Timer? _reconnectTimer;
  // Notified whenever `_isOffline` flips. The controller listens to update
  // its own `Rx<bool>` without polling.
  final RxBool offlineState = false.obs;

  bool get isOffline => _isOffline;

  Future<void> get ready => _readyFuture;

  ChatbotRepository({
    ChatbotRemoteService? remote,
    ChatbotStreamService? streamService,
    ChatbotLocalStoreService? localStore,
    ChatbotOfflineResponseService? offlineResponse,
    FeedbackOutboxService? feedbackOutbox,
    ConnectivityService? connectivity,
  })  : _remote = remote ?? ChatbotRemoteService(),
        _stream = streamService ?? ChatbotStreamService(),
        _localStore = localStore ?? ChatbotLocalStoreService(),
        _offlineResponse = offlineResponse ?? ChatbotOfflineResponseService(),
        _feedbackOutbox = feedbackOutbox,
        _connectivity = connectivity {
    _readyFuture = _initialize();
    _bindConnectivityDrain();
  }

  Future<void> _initialize() async {
    _sessionId = await _localStore.getOrCreateSessionId();
    final offlineJson = await _localStore.readOfflineDataJson();
    if (offlineJson == null) return;
    try {
      _offlineData = OfflineData.fromJson(jsonDecode(offlineJson));
    } catch (e) {
      Get.log('Failed to parse cached offline chatbot data: $e');
    }
  }

  void _bindConnectivityDrain() {
    final connectivity = _connectivity;
    final outbox = _feedbackOutbox;
    if (connectivity == null) return;
    _connectivityWorker = ever<bool>(
      connectivity.isOnline,
      (online) {
        if (online) {
          if (outbox != null) {
            // Fire and forget — drain failures are logged inside the helper.
            _drainFeedback();
          }
          // Connectivity coming back is a strong signal to clear sticky
          // offline state, but only if a real reconnect attempt succeeds.
          _attemptSilentReconnect();
        }
      },
    );
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    offlineState.value = value;
    if (value) {
      _startReconnectPolling();
    } else {
      _stopReconnectPolling();
    }
  }

  void _startReconnectPolling() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_reconnectPollInterval, (_) {
      if (!_isOffline) {
        _stopReconnectPolling();
        return;
      }
      _attemptSilentReconnect();
    });
  }

  void _stopReconnectPolling() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _attemptSilentReconnect() async {
    if (!_isOffline) return;
    try {
      final ok = await _remote.checkHealth();
      if (ok) {
        _setOffline(false);
        // Re-sync the offline bundle on reconnect (cheap when checksum
        // matches; fresh data when it doesn't).
        // Fire-and-forget — failures stay in the offline cache.
        // ignore: unawaited_futures
        syncOfflineData();
      }
    } catch (e) {
      // Stay offline; next tick will try again.
    }
  }

  Future<ChatMessage> sendMessage(
    String message, {
    String region = 'pakistan',
    String? city,
    String? language,
    Map<String, double>? location,
  }) async {
    if (!_isOffline) {
      try {
        final reply = await _remote.sendMessage(
          message: message,
          sessionId: _sessionId,
          region: region,
          city: city,
          language: language ?? 'en',
          location: location,
        );
        _setOffline(false);
        return reply;
      } catch (e) {
        Get.log('Online request failed, switching offline: $e');
        _setOffline(true);
      }
    }

    return _offlineResponse.buildResponse(
      message: message,
      region: region,
      offlineData: _offlineData,
      city: city,
    );
  }

  /// Phase 4 streaming dispatch. Falls back to non-streaming, then offline,
  /// per the locked decision chain.
  ///
  /// Yields a stream of partial-then-final ChatMessage snapshots:
  /// - Each delta event yields a copyWith(content=accumulated, isStreaming=true)
  /// - The done event yields the final message (isStreaming=false) plus
  ///   metadata.
  Stream<ChatMessage> streamMessage(
    String message, {
    String region = 'pakistan',
    String? city,
    String? language,
    Map<String, double>? location,
  }) async* {
    if (_isOffline) {
      yield _offlineResponse.buildResponse(
        message: message,
        region: region,
        offlineData: _offlineData,
        city: city,
      );
      return;
    }

    try {
      String accumulated = '';
      String? messageId;
      ChatMessage? finalMessage;
      await for (final ev in _stream.streamMessage(
        message: message,
        sessionId: _sessionId,
        region: region,
        city: city,
        language: language ?? 'en',
        location: location,
      )) {
        if (ev.error != null) {
          throw Exception(ev.error);
        }
        messageId ??= ev.messageId.isNotEmpty
            ? ev.messageId
            : DateTime.now().microsecondsSinceEpoch.toString();
        accumulated += ev.delta;

        if (ev.done) {
          finalMessage = ChatMessage(
            id: messageId,
            content: accumulated.isEmpty ? '...' : accumulated,
            type: MessageType.bot,
            timestamp: DateTime.now(),
            suggestedActions: ev.suggestedActions,
            helplines: ev.helplines,
            sources: ev.sources,
            usedLlm: ev.usedLlm,
            intentType: ev.providerUsed,
          );
          yield finalMessage;
          break;
        } else {
          yield ChatMessage(
            id: messageId,
            content: accumulated,
            type: MessageType.bot,
            timestamp: DateTime.now(),
            isStreaming: true,
          );
        }
      }
      _setOffline(false);
      if (finalMessage == null) {
        // Stream ended without a done marker — fall through to non-streaming.
        throw Exception('stream closed without done marker');
      }
      return;
    } catch (e) {
      Get.log('Streaming failed ($e); falling back to non-streaming');
    }

    // Fallback chain: non-streaming online → offline.
    try {
      final reply = await _remote.sendMessage(
        message: message,
        sessionId: _sessionId,
        region: region,
        city: city,
        language: language ?? 'en',
        location: location,
      );
      _setOffline(false);
      yield reply;
      return;
    } catch (e) {
      Get.log('Non-streaming fallback also failed: $e');
      _setOffline(true);
    }

    yield _offlineResponse.buildResponse(
      message: message,
      region: region,
      offlineData: _offlineData,
      city: city,
    );
  }

  Future<void> syncOfflineData() async {
    try {
      final data = await _remote.fetchOfflineDataJson();
      if (data == null) return;
      final json = jsonDecode(data) as Map<String, dynamic>;
      final newChecksum = json['checksum'] as String?;
      final cachedChecksum = await _localStore.readOfflineDataChecksum();

      if (newChecksum != null && cachedChecksum == newChecksum) {
        _setOffline(false);
        // Even on cache-hit we may want to refresh the in-memory copy on
        // first boot (cold start without a parsed _offlineData).
        _offlineData ??= OfflineData.fromJson(json);
        return;
      }

      _offlineData = OfflineData.fromJson(json);
      await _localStore.writeOfflineDataJson(data);
      if (newChecksum != null) {
        await _localStore.writeOfflineDataChecksum(newChecksum);
      }
      _setOffline(false);
    } catch (e) {
      Get.log('Failed to sync offline chatbot data: $e');
    }
  }

  Future<List<HelplineInfo>> getHelplines({String region = 'pakistan'}) async {
    try {
      final helplines = await _remote.fetchHelplines(region);
      if (helplines.isNotEmpty) return helplines;
    } catch (e) {
      Get.log('Failed to fetch chatbot helplines: $e');
    }
    return _offlineData?.helplines[region] ??
        _offlineResponse.fallbackHelplines(region: region);
  }

  Future<bool> submitFeedback({
    required String messageId,
    required bool helpful,
    String? comment,
  }) async {
    try {
      final ok = await _remote.submitFeedback(
        messageId: messageId,
        helpful: helpful,
        comment: comment,
      );
      if (ok) return true;
    } catch (e) {
      Get.log('Failed to submit chatbot feedback online: $e');
    }

    final outbox = _feedbackOutbox;
    if (outbox == null) return false;
    await outbox.enqueue(
      messageId: messageId,
      helpful: helpful,
      comment: comment,
    );
    return true;
  }

  Future<void> _drainFeedback() async {
    final outbox = _feedbackOutbox;
    if (outbox == null) return;
    final pending = outbox.listPending();
    for (final item in pending) {
      try {
        final ok = await _remote.submitFeedback(
          messageId: item.messageId,
          helpful: item.helpful,
          comment: item.comment,
        );
        if (ok) {
          await outbox.remove(item.id);
        } else {
          await outbox.recordAttempt(item, error: 'non-200 response');
        }
      } catch (e) {
        await outbox.recordAttempt(item, error: e.toString());
      }
    }
  }

  Future<void> clearSession() async {
    await _localStore.resetSessionId();
    _sessionId = await _localStore.getOrCreateSessionId();
  }

  /// Manual reconnect — used by the OfflineBanner tap and the header dot.
  /// Returns true on success.
  Future<bool> tryReconnect() async {
    try {
      final ok = await _remote.checkHealth();
      if (ok) {
        _setOffline(false);
        // Refresh the offline cache opportunistically.
        // ignore: unawaited_futures
        syncOfflineData();
      }
      return ok;
    } catch (e) {
      Get.log('Chatbot reconnect failed: $e');
      return false;
    }
  }

  void dispose() {
    _connectivityWorker?.dispose();
    _reconnectTimer?.cancel();
  }
}
