enum MessageType { user, bot, system }

enum UrgencyLevel { low, medium, high, critical }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isEmergency;
  final UrgencyLevel urgencyLevel;
  final List<String> suggestedActions;
  final List<HelplineInfo> helplines;
  final String? intentType;
  final double? confidence;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isEmergency = false,
    this.urgencyLevel = UrgencyLevel.low,
    this.suggestedActions = const [],
    this.helplines = const [],
    this.intentType,
    this.confidence,
    this.isLoading = false,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading',
      content: '',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id:
          json['message_id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['response'] ?? json['content'] ?? '',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      isEmergency: json['is_emergency'] ?? false,
      urgencyLevel: _parseUrgencyLevel(json['urgency_level']),
      suggestedActions: List<String>.from(json['suggested_actions'] ?? []),
      helplines:
          (json['helplines'] as List<dynamic>?)
              ?.map((h) => HelplineInfo.fromJson(h))
              .toList() ??
          [],
      intentType: json['intent_type'],
      confidence: json['confidence']?.toDouble(),
    );
  }

  static UrgencyLevel _parseUrgencyLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'high':
        return UrgencyLevel.high;
      case 'medium':
        return UrgencyLevel.medium;
      default:
        return UrgencyLevel.low;
    }
  }
}

class HelplineInfo {
  final String name;
  final String number;
  final String? description;
  final String region;
  final bool available24x7;
  final String? category;

  HelplineInfo({
    required this.name,
    required this.number,
    this.description,
    this.region = 'pakistan',
    this.available24x7 = true,
    this.category,
  });

  factory HelplineInfo.fromJson(Map<String, dynamic> json) {
    return HelplineInfo(
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      description: json['description'],
      region: json['region'] ?? 'pakistan',
      available24x7: json['available_24x7'] ?? true,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'description': description,
      'region': region,
      'available_24x7': available24x7,
      'category': category,
    };
  }
}

class ChatRequest {
  final String message;
  final String? sessionId;
  final String region;
  final Map<String, dynamic>? context;

  ChatRequest({
    required this.message,
    this.sessionId,
    this.region = 'pakistan',
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'session_id': sessionId,
      'region': region,
      if (context != null) 'context': context,
    };
  }
}

class OfflineData {
  final Map<String, List<HelplineInfo>> helplines;
  final Map<String, String> quickTips;
  final List<String> emergencyKeywords;
  final DateTime lastUpdated;

  OfflineData({
    required this.helplines,
    required this.quickTips,
    required this.emergencyKeywords,
    required this.lastUpdated,
  });

  factory OfflineData.fromJson(Map<String, dynamic> json) {
    Map<String, List<HelplineInfo>> helplines = {};
    if (json['helplines'] != null) {
      (json['helplines'] as Map<String, dynamic>).forEach((region, data) {
        helplines[region] = (data as List<dynamic>)
            .map((h) => HelplineInfo.fromJson(h))
            .toList();
      });
    }

    return OfflineData(
      helplines: helplines,
      quickTips: Map<String, String>.from(json['quick_tips'] ?? {}),
      emergencyKeywords: List<String>.from(json['emergency_keywords'] ?? []),
      lastUpdated:
          DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'helplines': helplines.map(
        (k, v) => MapEntry(k, v.map((h) => h.toJson()).toList()),
      ),
      'quick_tips': quickTips,
      'emergency_keywords': emergencyKeywords,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
