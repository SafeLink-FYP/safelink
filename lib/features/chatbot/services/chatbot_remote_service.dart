import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safelink/core/secrets/app_secrets.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';

class ChatbotRemoteService {
  // Audit F1: was a hardcoded `http://10.0.2.2:8000/api/v1`. Now reads from
  // AppSecrets which is platform-aware for dev and respects --dart-define
  // overrides for prod. The /api/v1 prefix lives here because it's a wire
  // contract, not a deployment concern.
  String get _baseUrl => '${AppSecrets.chatbotBaseUrl}/api/v1';

  Map<String, String> get _baseHeaders => {
    'Accept': 'application/json',
    if (AppSecrets.chatbotApiKey.isNotEmpty)
      'X-API-Key': AppSecrets.chatbotApiKey,
  };

  Map<String, String> get _jsonHeaders => {
    ..._baseHeaders,
    'Content-Type': 'application/json',
  };

  Future<ChatMessage> sendMessage({
    required String message,
    required String? sessionId,
    required String region,
    String? province,
    String? city,
    String language = 'en',
    Map<String, double>? location,
    bool offlineContext = false,
  }) async {
    final request = ChatRequest(
      message: message,
      sessionId: sessionId,
      region: region,
      province: province,
      city: city,
      language: language,
      location: location,
      offlineContext: offlineContext,
    );

    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat/message'),
          headers: _jsonHeaders,
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return ChatMessage.fromJson(jsonDecode(response.body));
  }

  Future<String?> fetchOfflineDataJson() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/chat/offline-data'), headers: _baseHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return null;
    }

    return response.body;
  }

  Future<List<HelplineInfo>> fetchHelplines(String region) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/chat/helplines/$region'),
          headers: _baseHeaders,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final helplinesList = json['helplines'] as List<dynamic>;
    return helplinesList.map((h) => HelplineInfo.fromJson(h)).toList();
  }

  Future<bool> submitFeedback({
    required String messageId,
    required bool helpful,
    String? comment,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat/feedback'),
          headers: _jsonHeaders,
          body: jsonEncode({
            'message_id': messageId,
            'helpful': helpful,
            if (comment != null) 'comment': comment,
          }),
        )
        .timeout(const Duration(seconds: 10));

    return response.statusCode == 200;
  }

  Future<bool> checkHealth() async {
    // Audit F2: was '$baseUrl/../health' which relied on path normalization
    // by the server (and was rejected by some reverse proxies). The backend
    // now exposes /api/v1/health as a mirror of /health, so we hit it
    // directly with no traversal hacks.
    final response = await http
        .get(Uri.parse('$_baseUrl/health'), headers: _baseHeaders)
        .timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  }
}
