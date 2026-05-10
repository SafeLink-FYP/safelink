import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatbotLocalStoreService {
  static const String offlineDataKey = 'chatbot_offline_data';
  static const String offlineDataChecksumKey = 'chatbot_offline_data_checksum';
  static const String sessionIdKey = 'chatbot_session_id';

  static const _uuid = Uuid();

  Future<String> getOrCreateSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(sessionIdKey);
    if (existing != null) return existing;

    final sessionId = 'session_${_uuid.v4()}';
    await prefs.setString(sessionIdKey, sessionId);
    return sessionId;
  }

  Future<void> resetSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionIdKey);
    final newSession = 'session_${_uuid.v4()}';
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

  // Audit F10 / Phase 1: persist the backend-supplied checksum so we can
  // skip the rewrite when the bundle hasn't changed. The Phase 4 work will
  // also expose this through OfflineData; for now it's a private contract
  // between the repository and this store.
  Future<String?> readOfflineDataChecksum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(offlineDataChecksumKey);
  }

  Future<void> writeOfflineDataChecksum(String checksum) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(offlineDataChecksumKey, checksum);
  }
}
