import 'package:safelink/features/chatbot/models/chat_models.dart';

class ChatbotOfflineResponseService {
  ChatMessage buildResponse({
    required String message,
    required String region,
    required OfflineData? offlineData,
  }) {
    final lowerMessage = message.toLowerCase();

    final isEmergency = _checkEmergencyKeywords(lowerMessage, offlineData);
    List<HelplineInfo> helplines = [];
    var urgency = UrgencyLevel.low;
    List<String> suggestedActions = [];
    String responseContent;

    if (isEmergency) {
      urgency = UrgencyLevel.critical;
      helplines = offlineData?.helplines[region] ?? _defaultHelplines(region);
      responseContent = _emergencyResponse(helplines);
      suggestedActions = ['Call emergency services now', 'Move to safety'];
    } else if (_containsDisasterKeyword(lowerMessage)) {
      final disasterType = _detectDisasterType(lowerMessage);
      responseContent =
          _quickTip(disasterType, offlineData) ?? _generalSafetyTip();
      helplines = offlineData?.helplines[region]?.take(3).toList() ?? [];
      urgency = UrgencyLevel.medium;
      suggestedActions = ['Learn more about safety', 'View emergency contacts'];
    } else if (_containsHelplineKeyword(lowerMessage)) {
      helplines = offlineData?.helplines[region] ?? _defaultHelplines(region);
      responseContent = _helplinesResponse(helplines);
    } else if (_isGreeting(lowerMessage)) {
      responseContent = _greetingResponse();
      suggestedActions = [
        'Earthquake safety tips',
        'Flood preparedness',
        'Emergency helplines',
        'First aid basics',
      ];
    } else {
      responseContent = _fallbackResponse();
      suggestedActions = [
        'Disaster safety tips',
        'Emergency numbers',
        'First aid help',
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

  List<HelplineInfo> fallbackHelplines({required String region}) {
    return _defaultHelplines(region);
  }

  bool _checkEmergencyKeywords(String message, OfflineData? offlineData) {
    final emergencyKeywords =
        offlineData?.emergencyKeywords ??
        [
          'help',
          'emergency',
          'sos',
          'trapped',
          'dying',
          'earthquake happening',
          'flood rising',
          'drowning',
          'madad',
          'bachao',
        ];
    return emergencyKeywords.any(message.contains);
  }

  bool _containsDisasterKeyword(String message) {
    const disasterKeywords = [
      'earthquake',
      'flood',
      'zalzala',
      'sailab',
      'barish',
      'monsoon',
    ];
    return disasterKeywords.any(message.contains);
  }

  bool _containsHelplineKeyword(String message) {
    const keywords = ['helpline', 'number', 'call', 'emergency number', 'contact'];
    return keywords.any(message.contains);
  }

  bool _isGreeting(String message) {
    const greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good evening',
      'assalam',
      'salam',
    ];
    return greetings.any((g) => message.startsWith(g) || message == g);
  }

  String? _detectDisasterType(String message) {
    const disasters = {
      'earthquake': ['earthquake', 'quake', 'tremor', 'seismic', 'zalzala'],
      'flood': ['flood', 'flooding', 'water rising', 'sailab', 'barish', 'monsoon', 'seelab'],
    };

    for (final entry in disasters.entries) {
      if (entry.value.any(message.contains)) return entry.key;
    }
    return null;
  }

  String? _quickTip(String? disasterType, OfflineData? offlineData) {
    if (disasterType == null) return null;
    final tips =
        offlineData?.quickTips ??
        {
          'earthquake':
              '🏠 **Quick Earthquake Tips (Pakistan):**\nDROP, COVER, HOLD ON | Stay away from windows | Don\'t run outside during shaking | Call 1122 or 115',
          'flood':
              '🌊 **Quick Flood Tips (Pakistan):**\nMove to higher ground | Never walk/drive through flood water | Call 1122 or 115 | Contact NDMA: 051-9205037',
        };
    return tips[disasterType];
  }

  String _generalSafetyTip() => '''**General Safety Tips - Pakistan**

• Stay calm and assess the situation
• Follow official instructions from NDMA/PDMA
• Have an emergency kit ready
• Know your evacuation routes
• Keep emergency contacts accessible: 1122, 115

For specific disaster information, please ask about earthquake or flood safety.''';

  String _emergencyResponse(List<HelplineInfo> helplines) {
    final helplineText = helplines
        .take(3)
        .map((h) => '• **${h.name}**: ${h.number}')
        .join('\n');
    return '''🚨 **EMERGENCY DETECTED**

If you are in immediate danger:
1. **Call emergency services NOW**
2. Stay calm and follow safety protocols
3. Move to a safe location if possible

**Emergency Contacts:**
$helplineText

Stay on the line with emergency services until help arrives.''';
  }

  String _helplinesResponse(List<HelplineInfo> helplines) {
    final helplineText = helplines
        .map((h) => '• **${h.name}**: ${h.number}${h.available24x7 ? ' (24/7)' : ''}')
        .join('\n');
    return '''**Emergency Helplines - Pakistan:**

$helplineText

💾 Save these numbers for quick access during emergencies.''';
  }

  String _greetingResponse() => '''Assalam-o-Alaikum! I'm the SafeLink Safety Assistant. 👋

🇵🇰 I'm here to help you with:
• **Disaster Safety Guidance** - Earthquake & Flood
• **Emergency Helplines** - Pakistan emergency contacts
• **First Aid Information** - Basic first aid guidance

How can I assist you today?

⚠️ *Currently in offline mode - responses are based on cached data.*''';

  String _fallbackResponse() => '''I'm here to help with disaster safety information for Pakistan.

I can assist with:
• Safety tips for earthquakes and floods
• Emergency helpline numbers (1122, 115, NDMA)
• Basic first aid information
• Evacuation guidance

What would you like to know?

⚠️ *Currently in offline mode - for detailed guidance, please connect to the internet.*''';

  List<HelplineInfo> _defaultHelplines(String region) {
    return [
      HelplineInfo(name: 'Rescue 1122', number: '1122', region: region),
      HelplineInfo(name: 'Edhi Foundation', number: '115', region: region),
      HelplineInfo(name: 'Police', number: '15', region: region),
      HelplineInfo(name: 'Fire Brigade', number: '16', region: region),
      HelplineInfo(name: 'NDMA', number: '051-9205037', region: region),
    ];
  }
}
