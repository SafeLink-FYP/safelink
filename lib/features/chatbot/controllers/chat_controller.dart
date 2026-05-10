import 'dart:async';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:safelink/features/profile/controllers/profile_controller.dart';
import '../models/chat_models.dart';
import '../services/chat_history_service.dart';
import '../services/chatbot_service.dart';

class ChatController extends GetxController {
  final ChatbotService _chatService;
  final ChatHistoryService? _history;

  ChatController({
    ChatbotService? chatService,
    ChatHistoryService? history,
  })  : _chatService = chatService ?? Get.find<ChatbotService>(),
        _history = history ?? Get.find<ChatHistoryService>();

  static const _uuid = Uuid();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  final RxString selectedRegion = 'pakistan'.obs;
  final RxList<String> suggestedQuestions = <String>[].obs;

  Worker? _offlineWorker;

  @override
  void onInit() {
    super.onInit();
    _initChat();
    _bindOfflineState();
  }

  @override
  void onClose() {
    _offlineWorker?.dispose();
    super.onClose();
  }

  Future<void> _initChat() async {
    // Audit F6 — wait for repository bootstrap before any send.
    await _chatService.ready;

    // Phase 4 — restore persisted history before the first frame so the UI
    // doesn't flash empty-state to the user.
    final history = _history;
    if (history != null && messages.isEmpty) {
      try {
        messages.addAll(history.load());
      } catch (e) {
        Get.log('ChatController: failed to load history: $e');
      }
    }

    // Best-effort offline-bundle refresh in the background.
    // ignore: unawaited_futures
    _chatService.syncOfflineData();
    isOffline.value = _chatService.isOffline;
  }

  void _bindOfflineState() {
    // Mirror repository state into the controller's Rx so widgets (the
    // OfflineBanner, status dot) update without manual polling.
    _offlineWorker = ever<bool>(_chatService.offlineState, (value) {
      isOffline.value = value;
    });
  }

  // ─── Profile-aware request building ────────────────────────────────────────
  String? _resolveCity() {
    // Locked Phase 4 decision: send city only — backend derives province via
    // CITY_TO_PROVINCE. We pull from ProfileController if it's been
    // registered (it is for citizen flow). Failures fall back to null.
    try {
      final profile = Get.find<ProfileController>();
      final city = profile.profile.value?.city;
      if (city != null && city.trim().isNotEmpty) {
        return city.trim();
      }
    } catch (_) {
      // ProfileController not registered (e.g., test). Skip.
    }
    return null;
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _chatService.ready;

    final userMessage = ChatMessage.user(trimmed);
    messages.add(userMessage);
    // ignore: unawaited_futures
    _history?.append(userMessage);

    final city = _resolveCity();

    // Streaming first; the repository falls back to non-streaming and
    // then offline internally.
    await _streamWithFallback(
      message: trimmed,
      city: city,
    );
  }

  Future<void> _streamWithFallback({
    required String message,
    String? city,
  }) async {
    isLoading.value = true;
    final placeholderId = _uuid.v4();
    // Streaming placeholder (with the streaming flag so the bubble can
    // render its cursor). We update this same ID as deltas arrive.
    var current = ChatMessage(
      id: placeholderId,
      content: '',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    messages.add(current);

    try {
      final stream = _chatService.streamMessage(
        message,
        region: selectedRegion.value,
        city: city,
      );
      await for (final snapshot in stream) {
        // Stabilise the bubble id across deltas. The repository assigns
        // its own messageId from the SSE event; if we let that propagate
        // into the messages list, _replaceMessage(placeholderId, ...) on
        // the next iteration won't find the entry and falls through to
        // add — producing one bubble per delta instead of an in-place
        // update. Force the placeholderId on every snapshot so the
        // ListView builder keeps the same widget instance throughout the
        // stream (animation + scroll anchoring stay intact).
        final stable = snapshot.copyWith(
          id: placeholderId,
          isStreaming: !_isFinal(snapshot),
        );
        _replaceMessage(placeholderId, stable);
        current = stable;
      }
      // Persist the final form.
      final finalised = _findById(placeholderId);
      if (finalised != null) {
        // ignore: unawaited_futures
        _history?.append(finalised);
        if (finalised.suggestedActions.isNotEmpty) {
          _updateSuggestions(finalised.suggestedActions);
        }
      }
      isOffline.value = _chatService.isOffline;
    } catch (e) {
      Get.log('Stream consumer error: $e');
      _replaceMessage(
        placeholderId,
        ChatMessage(
          id: placeholderId,
          content: 'Sorry, I encountered an error. Please try again.',
          type: MessageType.bot,
          timestamp: DateTime.now(),
          suggestedActions: const ['Try again', 'Emergency helplines'],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _isFinal(ChatMessage m) =>
      // Final snapshots from the repository carry sources OR helplines OR
      // suggested actions OR carry the LLM-used flag — i.e., they're the
      // `done` event, not a delta.
      m.sources.isNotEmpty ||
      m.helplines.isNotEmpty ||
      m.suggestedActions.isNotEmpty ||
      m.usedLlm ||
      // Offline / non-streaming responses always come as a single message.
      (!m.isStreaming && m.content.isNotEmpty);

  void _replaceMessage(String id, ChatMessage replacement) {
    final idx = messages.indexWhere((m) => m.id == id);
    if (idx >= 0) {
      messages[idx] = replacement;
    } else {
      messages.add(replacement);
    }
  }

  ChatMessage? _findById(String id) {
    for (final m in messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  void sendSuggestion(String suggestion) {
    sendMessage(suggestion);
  }

  void _updateSuggestions(List<String> suggestions) {
    suggestedQuestions
      ..clear()
      ..addAll(suggestions.take(4));
  }

  void setRegion(String region) {
    selectedRegion.value = region;
  }

  Future<void> clearChat() async {
    messages.clear();
    suggestedQuestions.clear();
    await _chatService.clearSession();
    await _history?.clear();
  }

  Future<List<HelplineInfo>> getHelplines() async {
    return _chatService.getHelplines(region: selectedRegion.value);
  }

  Future<bool> submitFeedback(
    String messageId,
    bool helpful, {
    String? comment,
  }) async {
    return _chatService.submitFeedback(
      messageId: messageId,
      helpful: helpful,
      comment: comment,
    );
  }

  /// Phase 4: long-press "Report wrong info" hands off to the same feedback
  /// pipeline with a structured comment prefix so reviewers can filter.
  Future<bool> reportWrongInfo(String messageId, {String? note}) async {
    final body = '[INCORRECT] ${(note ?? '').trim()}'.trim();
    return submitFeedback(messageId, false, comment: body);
  }

  Future<void> tryReconnect() async {
    final reconnected = await _chatService.tryReconnect();
    isOffline.value = !reconnected;

    if (reconnected) {
      final sysMsg = ChatMessage(
        id: _uuid.v4(),
        content: '✅ Back online! I can now provide more detailed responses.',
        type: MessageType.system,
        timestamp: DateTime.now(),
      );
      messages.add(sysMsg);
      // ignore: unawaited_futures
      _history?.append(sysMsg);
    }
  }
}
