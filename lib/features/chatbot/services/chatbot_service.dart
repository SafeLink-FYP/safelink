import 'package:safelink/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';

class ChatbotService {
  final ChatbotRepository _repository;

  ChatbotService({ChatbotRepository? repository})
      : _repository = repository ?? ChatbotRepository() {
    _repository.initialize();
  }

  bool get isOffline => _repository.isOffline;

  Future<ChatMessage> sendMessage(String message, {String region = 'pakistan'}) {
    return _repository.sendMessage(message, region: region);
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
