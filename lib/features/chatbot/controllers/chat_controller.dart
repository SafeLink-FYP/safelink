import 'package:get/get.dart';
import '../models/chat_models.dart';
import '../services/chatbot_service.dart';

class ChatController extends GetxController {
  final ChatbotService _chatService = ChatbotService();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  final RxString selectedRegion = 'pakistan'.obs;
  final RxList<String> suggestedQuestions = <String>[].obs;

  String _currentInput = '';

  @override
  void onInit() {
    super.onInit();
    _initChat();
  }

  Future<void> _initChat() async {
    _chatService.syncOfflineData();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _currentInput = text.trim();

    final userMessage = ChatMessage.user(_currentInput);
    messages.add(userMessage);

    isLoading.value = true;
    final loadingMessage = ChatMessage.loading();
    messages.add(loadingMessage);

    try {
      final response = await _chatService.sendMessage(
        _currentInput,
        region: selectedRegion.value,
      );

      messages.removeWhere((m) => m.isLoading);

      _addBotMessage(response);

      if (response.suggestedActions.isNotEmpty) {
        _updateSuggestions(response.suggestedActions);
      }

      isOffline.value = _chatService.isOffline;

    } catch (e) {
      messages.removeWhere((m) => m.isLoading);

      _addBotMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        type: MessageType.bot,
        timestamp: DateTime.now(),
        suggestedActions: ['Try again', 'Emergency helplines'],
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void sendSuggestion(String suggestion) {
    sendMessage(suggestion);
  }

  void _addBotMessage(ChatMessage message) {
    messages.add(message);
  }

  void _updateSuggestions(List<String> suggestions) {
    suggestedQuestions.clear();
    suggestedQuestions.addAll(suggestions.take(4));
  }

  void setRegion(String region) {
    selectedRegion.value = region;
  }

  void clearChat() {
    messages.clear();
    suggestedQuestions.clear();
    _chatService.clearSession();
  }

  Future<List<HelplineInfo>> getHelplines() async {
    return await _chatService.getHelplines(region: selectedRegion.value);
  }

  Future<bool> submitFeedback(String messageId, bool helpful, {String? comment}) async {
    return await _chatService.submitFeedback(
      messageId: messageId,
      helpful: helpful,
      comment: comment,
    );
  }

  Future<void> tryReconnect() async {
    final reconnected = await _chatService.tryReconnect();
    isOffline.value = !reconnected;

    if (reconnected) {
      _addBotMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '✅ Back online! I can now provide more detailed responses.',
        type: MessageType.system,
        timestamp: DateTime.now(),
      ));
    }
  }
}
