import 'package:shared_preferences/shared_preferences.dart';

class ChatbotLocalStoreService {
  static const String offlineDataKey = 'chatbot_offline_data';
  static const String sessionIdKey = 'chatbot_session_id';

  Future<String> getOrCreateSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(sessionIdKey);
    if (existing != null) return existing;

    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(sessionIdKey, sessionId);
    return sessionId;
  }

  Future<void> resetSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionIdKey);
    final newSession = 'session_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(sessionIdKey, newSession);
  }

  Future<String?> readOfflineDataJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(offlineDataKey);
  }

  Future<void> writeOfflineDataJson(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(offlineDataKey, jsonData);
  }
}
