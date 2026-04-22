import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safelink/features/chatbot/models/chat_models.dart';

class ChatbotRemoteService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  Future<ChatMessage> sendMessage({
    required String message,
    required String? sessionId,
    required String region,
  }) async {
    final request = ChatRequest(
      message: message,
      sessionId: sessionId,
      region: region,
    );

    final response = await http
        .post(
          Uri.parse('$baseUrl/chat/message'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
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
        .get(
          Uri.parse('$baseUrl/chat/offline-data'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      return null;
    }

    return response.body;
  }

  Future<List<HelplineInfo>> fetchHelplines(String region) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/chat/helplines/$region'),
          headers: const {'Accept': 'application/json'},
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
          Uri.parse('$baseUrl/chat/feedback'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
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
    final response = await http
        .get(
          Uri.parse('$baseUrl/../health'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  }
}
