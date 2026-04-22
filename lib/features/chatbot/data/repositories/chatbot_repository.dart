import 'dart:convert';
import 'package:get/get.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/chatbot_local_store_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_offline_response_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_remote_service.dart';

class ChatbotRepository {
  final ChatbotRemoteService _remote;
  final ChatbotLocalStoreService _localStore;
  final ChatbotOfflineResponseService _offlineResponse;

  String? _sessionId;
  OfflineData? _offlineData;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  ChatbotRepository({
    ChatbotRemoteService? remote,
    ChatbotLocalStoreService? localStore,
    ChatbotOfflineResponseService? offlineResponse,
  }) : _remote = remote ?? ChatbotRemoteService(),
       _localStore = localStore ?? ChatbotLocalStoreService(),
       _offlineResponse = offlineResponse ?? ChatbotOfflineResponseService();

  Future<void> initialize() async {
    _sessionId = await _localStore.getOrCreateSessionId();
    final offlineJson = await _localStore.readOfflineDataJson();
    if (offlineJson == null) return;
    try {
      _offlineData = OfflineData.fromJson(jsonDecode(offlineJson));
    } catch (e) {
      Get.log('Failed to parse cached offline chatbot data: $e');
    }
  }

  Future<ChatMessage> sendMessage(String message, {String region = 'pakistan'}) async {
    if (!_isOffline) {
      try {
        return await _remote.sendMessage(
          message: message,
          sessionId: _sessionId,
          region: region,
        );
      } catch (e) {
        Get.log('Online request failed, switching offline: $e');
        _isOffline = true;
      }
    }

    return _offlineResponse.buildResponse(
      message: message,
      region: region,
      offlineData: _offlineData,
    );
  }

  Future<void> syncOfflineData() async {
    try {
      final data = await _remote.fetchOfflineDataJson();
      if (data == null) return;
      _offlineData = OfflineData.fromJson(jsonDecode(data));
      await _localStore.writeOfflineDataJson(data);
      _isOffline = false;
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
      return await _remote.submitFeedback(
        messageId: messageId,
        helpful: helpful,
        comment: comment,
      );
    } catch (e) {
      Get.log('Failed to submit chatbot feedback: $e');
      return false;
    }
  }

  Future<void> clearSession() async {
    await _localStore.resetSessionId();
    _sessionId = await _localStore.getOrCreateSessionId();
  }

  Future<bool> tryReconnect() async {
    try {
      final ok = await _remote.checkHealth();
      if (ok) _isOffline = false;
      return ok;
    } catch (e) {
      Get.log('Chatbot reconnect failed: $e');
      return false;
    }
  }
}
