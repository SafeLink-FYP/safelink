import 'package:get/get.dart';
import 'package:safelink/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';

class ChatbotService {
  final ChatbotRepository _repository;

  ChatbotService({ChatbotRepository? repository})
      : _repository = repository ?? ChatbotRepository();

  bool get isOffline => _repository.isOffline;

  /// Reactive offline flag — controllers listen via `ever()` to keep the
  /// UI in sync without polling.
  RxBool get offlineState => _repository.offlineState;

  Future<void> get ready => _repository.ready;

  Future<ChatMessage> sendMessage(
    String message, {
    String region = 'pakistan',
    String? city,
    String? language,
    Map<String, double>? location,
  }) {
    return _repository.sendMessage(
      message,
      region: region,
      city: city,
      language: language,
      location: location,
    );
  }

  /// Phase 4: streaming dispatch. Yields incremental + final ChatMessage
  /// snapshots. Falls back internally to non-streaming + offline.
  Stream<ChatMessage> streamMessage(
    String message, {
    String region = 'pakistan',
    String? city,
    String? language,
    Map<String, double>? location,
  }) {
    return _repository.streamMessage(
      message,
      region: region,
      city: city,
      language: language,
      location: location,
    );
  }

  Future<void> syncOfflineData() {
    return _repository.syncOfflineData();
  }

  Future<List<HelplineInfo>> getHelplines({String region = 'pakistan'}) {
    return _repository.getHelplines(region: region);
  }

  Future<bool> submitFeedback({
    required String messageId,
    required bool helpful,
    String? comment,
  }) {
    return _repository.submitFeedback(
      messageId: messageId,
      helpful: helpful,
      comment: comment,
    );
  }

  Future<void> clearSession() {
    return _repository.clearSession();
  }

  Future<bool> tryReconnect() {
    return _repository.tryReconnect();
  }
}
