import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';

/// Service for chatbot API communication and offline support
class ChatbotService {
  // TODO: Update with your deployed server URL
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // static const String _baseUrl = 'http://localhost:8000/api/v1'; // iOS simulator
  // static const String _baseUrl = 'https://your-server.com/api/v1'; // Production

  static const String _offlineDataKey = 'chatbot_offline_data';
  static const String _sessionIdKey = 'chatbot_session_id';

  String? _sessionId;
  OfflineData? _offlineData;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  ChatbotService() {
    _initSession();
    _loadOfflineData();
  }

  /// Initialize or retrieve session ID
  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionIdKey);

    if (_sessionId == null) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_sessionIdKey, _sessionId!);
    }
  }

  /// Load cached offline data
  Future<void> _loadOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_offlineDataKey);

      if (data != null) {
        _offlineData = OfflineData.fromJson(jsonDecode(data));
      }
    } catch (e) {
      print('Error loading offline data: $e');
    }
  }

  /// Send message to chatbot
  Future<ChatMessage> sendMessage(String message, {String region = 'pakistan'}) async {
    // Try online first
    if (!_isOffline) {
      try {
        final response = await _sendMessageOnline(message, region);
        return response;
      } catch (e) {
        print('Online request failed, trying offline: $e');
        _isOffline = true;
      }
    }

    // Fallback to offline response
    return _generateOfflineResponse(message, region);
  }

  /// Send message to online API
  Future<ChatMessage> _sendMessageOnline(String message, String region) async {
    final request = ChatRequest(
      message: message,
      sessionId: _sessionId,
      region: region,
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/message'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ChatMessage.fromJson(json);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  ChatMessage _generateOfflineResponse(String message, String region) {
    final lowerMessage = message.toLowerCase();

    bool isEmergency = _checkEmergencyKeywords(lowerMessage);

    String responseContent;
    List<HelplineInfo> helplines = [];
    UrgencyLevel urgency = UrgencyLevel.low;
    List<String> suggestedActions = [];

    if (isEmergency) {
      urgency = UrgencyLevel.critical;
      helplines = _offlineData?.helplines[region] ?? _getDefaultHelplines(region);
      responseContent = _getEmergencyResponse(helplines);
      suggestedActions = ['Call emergency services now', 'Move to safety'];
    } else if (_containsDisasterKeyword(lowerMessage)) {
      String? disasterType = _detectDisasterType(lowerMessage);
      responseContent = _getQuickTip(disasterType) ?? _getGeneralSafetyTip();
      helplines = _offlineData?.helplines[region]?.take(3).toList() ?? [];
      urgency = UrgencyLevel.medium;
      suggestedActions = ['Learn more about safety', 'View emergency contacts'];
    } else if (_containsHelplineKeyword(lowerMessage)) {
      helplines = _offlineData?.helplines[region] ?? _getDefaultHelplines(region);
      responseContent = _formatHelplinesResponse(helplines, region);
    } else if (_isGreeting(lowerMessage)) {
      responseContent = _getGreetingResponse();
      suggestedActions = [
        'Earthquake safety tips',
        'Flood preparedness',
        'Emergency helplines',
        'First aid basics'
      ];
    } else {
      responseContent = _getFallbackResponse();
      suggestedActions = [
        'Disaster safety tips',
        'Emergency numbers',
        'First aid help'
      ];
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responseContent,
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isEmergency: isEmergency,
      urgencyLevel: urgency,
      suggestedActions: suggestedActions,
      helplines: helplines,
      intentType: 'offline_response',
      confidence: 0.7,
    );
  }

  bool _checkEmergencyKeywords(String message) {
    final emergencyKeywords = _offlineData?.emergencyKeywords ?? [
      'help', 'emergency', 'sos', 'trapped', 'dying',
      'earthquake happening', 'flood rising', 'drowning',
      'madad', 'bachao'
    ];

    for (var keyword in emergencyKeywords) {
      if (message.contains(keyword)) return true;
    }
    return false;
  }

  bool _containsDisasterKeyword(String message) {
    final disasterKeywords = [
      'earthquake', 'flood', 'zalzala', 'sailab', 'barish', 'monsoon'
    ];
    return disasterKeywords.any((k) => message.contains(k));
  }

  bool _containsHelplineKeyword(String message) {
    final keywords = ['helpline', 'number', 'call', 'emergency number', 'contact'];
    return keywords.any((k) => message.contains(k));
  }

  bool _isGreeting(String message) {
    final greetings = ['hi', 'hello', 'hey', 'good morning', 'good evening', 'assalam', 'salam'];
    return greetings.any((g) => message.startsWith(g) || message == g);
  }

  String? _detectDisasterType(String message) {
    final disasters = {
      'earthquake': ['earthquake', 'quake', 'tremor', 'seismic', 'zalzala', 'zalzala'],
      'flood': ['flood', 'flooding', 'water rising', 'sailab', 'barish', 'monsoon', 'seelab'],
    };

    for (var entry in disasters.entries) {
      if (entry.value.any((k) => message.contains(k))) {
        return entry.key;
      }
    }
    return null;
  }

  String? _getQuickTip(String? disasterType) {
    if (disasterType == null) return null;

    final tips = _offlineData?.quickTips ?? {
      'earthquake': '🏠 **Quick Earthquake Tips (Pakistan):**\nDROP, COVER, HOLD ON | Stay away from windows | Don\'t run outside during shaking | Call 1122 or 115',
      'flood': '🌊 **Quick Flood Tips (Pakistan):**\nMove to higher ground | Never walk/drive through flood water | Call 1122 or 115 | Contact NDMA: 051-9205037',
    };

    return tips[disasterType];
  }

  String _getGeneralSafetyTip() {
    return '''**General Safety Tips - Pakistan**

• Stay calm and assess the situation
• Follow official instructions from NDMA/PDMA
• Have an emergency kit ready
• Know your evacuation routes
• Keep emergency contacts accessible: 1122, 115

For specific disaster information, please ask about earthquake or flood safety.''';
  }

  String _getEmergencyResponse(List<HelplineInfo> helplines) {
    String helplineText = helplines.take(3).map((h) =>
      '• **${h.name}**: ${h.number}'
    ).join('\n');

    return '''🚨 **EMERGENCY DETECTED**

If you are in immediate danger:
1. **Call emergency services NOW**
2. Stay calm and follow safety protocols
3. Move to a safe location if possible

**Emergency Contacts:**
$helplineText

Stay on the line with emergency services until help arrives.''';
  }

  String _formatHelplinesResponse(List<HelplineInfo> helplines, String region) {
    String helplineText = helplines.map((h) =>
      '• **${h.name}**: ${h.number}${h.available24x7 ? ' (24/7)' : ''}'
    ).join('\n');

    return '''**Emergency Helplines - Pakistan:**

$helplineText

💾 Save these numbers for quick access during emergencies.''';
  }

  String _getGreetingResponse() {
    return '''Assalam-o-Alaikum! I'm the SafeLink Safety Assistant. 👋

🇵🇰 I'm here to help you with:
• **Disaster Safety Guidance** - Earthquake & Flood
• **Emergency Helplines** - Pakistan emergency contacts
• **First Aid Information** - Basic first aid guidance

How can I assist you today?

⚠️ *Currently in offline mode - responses are based on cached data.*''';
  }

  String _getFallbackResponse() {
    return '''I'm here to help with disaster safety information for Pakistan.

I can assist with:
• Safety tips for earthquakes and floods
• Emergency helpline numbers (1122, 115, NDMA)
• Basic first aid information
• Evacuation guidance

What would you like to know?

⚠️ *Currently in offline mode - for detailed guidance, please connect to the internet.*''';
  }

  List<HelplineInfo> _getDefaultHelplines(String region) {
    return [
      HelplineInfo(name: 'Rescue 1122', number: '1122', region: 'pakistan'),
      HelplineInfo(name: 'Edhi Foundation', number: '115', region: 'pakistan'),
      HelplineInfo(name: 'Police', number: '15', region: 'pakistan'),
      HelplineInfo(name: 'Fire Brigade', number: '16', region: 'pakistan'),
      HelplineInfo(name: 'NDMA', number: '051-9205037', region: 'pakistan'),
    ];
  }

  Future<void> syncOfflineData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/offline-data'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _offlineData = OfflineData.fromJson(json);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_offlineDataKey, response.body);

        _isOffline = false;
        print('Offline data synced successfully');
      }
    } catch (e) {
      print('Failed to sync offline data: $e');
    }
  }

  Future<List<HelplineInfo>> getHelplines({String region = 'pakistan'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/helplines/$region'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final helplinesList = json['helplines'] as List<dynamic>;
        return helplinesList.map((h) => HelplineInfo.fromJson(h)).toList();
      }
    } catch (e) {
      print('Failed to fetch helplines: $e');
    }

    return _offlineData?.helplines[region] ?? _getDefaultHelplines(region);
  }

  Future<bool> submitFeedback({
    required String messageId,
    required bool helpful,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message_id': messageId,
          'helpful': helpful,
          if (comment != null) 'comment': comment,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Failed to submit feedback: $e');
      return false;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_sessionIdKey, _sessionId!);
  }

  Future<bool> tryReconnect() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/../health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _isOffline = false;
        return true;
      }
    } catch (e) {
      print('Reconnection failed: $e');
    }
    return false;
  }
}
