import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum MessageType { user, bot, system }

// Phase 1 fix: backend's UrgencyLevel is low | medium | high | critical.
// Dart was missing `high`; medium and high are now visually distinct
// (see chat_bubble.dart styling).
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
  // Phase 4: streaming + grounded-response surfacing.
  final bool isStreaming;
  final List<SourceCitation> sources;
  final bool usedLlm;

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
    this.isStreaming = false,
    this.sources = const [],
    this.usedLlm = false,
  });

  ChatMessage copyWith({
    // `id` is overridable specifically for the streaming consumer. The
    // ChatController allocates a stable placeholderId at the start of a
    // bot turn and forces every per-delta snapshot from the repository
    // onto that id; otherwise the SSE event's message_id would propagate
    // into the messages list and `_replaceMessage` would fail to find the
    // entry on the next iteration, producing one bubble per delta.
    String? id,
    String? content,
    bool? isLoading,
    bool? isStreaming,
    List<String>? suggestedActions,
    List<HelplineInfo>? helplines,
    List<SourceCitation>? sources,
    bool? usedLlm,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      isEmergency: isEmergency,
      urgencyLevel: urgencyLevel,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      helplines: helplines ?? this.helplines,
      intentType: intentType,
      confidence: confidence,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      sources: sources ?? this.sources,
      usedLlm: usedLlm ?? this.usedLlm,
    );
  }

  /// Persistence: round-trip to/from a Map for the Hive `chat_history` box.
  /// We store as Map (no TypeAdapter) so future schema additions don't need
  /// a code-gen pass. Older entries with missing fields fall back to defaults.
  Map<String, dynamic> toHive() => {
        'id': id,
        'content': content,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'is_emergency': isEmergency,
        'urgency_level': urgencyLevel.name,
        'suggested_actions': suggestedActions,
        'helplines': helplines.map((h) => h.toJson()).toList(),
        'intent_type': intentType,
        'confidence': confidence,
        'sources': sources.map((s) => s.toJson()).toList(),
        'used_llm': usedLlm,
      };

  factory ChatMessage.fromHive(Map<dynamic, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String? ?? _uuid.v4(),
      content: map['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.name == (map['type'] as String?),
        orElse: () => MessageType.bot,
      ),
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
      isEmergency: map['is_emergency'] as bool? ?? false,
      urgencyLevel: UrgencyLevel.values.firstWhere(
        (u) => u.name == (map['urgency_level'] as String?),
        orElse: () => UrgencyLevel.low,
      ),
      suggestedActions: (map['suggested_actions'] as List?)?.cast<String>() ?? const [],
      helplines: ((map['helplines'] as List?) ?? const [])
          .map((h) => HelplineInfo.fromJson(Map<String, dynamic>.from(h as Map)))
          .toList(),
      intentType: map['intent_type'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble(),
      sources: ((map['sources'] as List?) ?? const [])
          .map((s) => SourceCitation.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      usedLlm: map['used_llm'] as bool? ?? false,
    );
  }

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: _uuid.v4(),
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
    // Backend ships `intent` as a nested object {intent, confidence, sub_intent}.
    // Read the inner `intent` string; the legacy flat `intent_type` field has
    // never been populated by the wire format.
    final intentObj = json['intent'];
    final String? intentType = intentObj is Map
        ? intentObj['intent'] as String?
        : (intentObj is String ? intentObj : null);

    final dynamic confidenceRaw =
        intentObj is Map ? intentObj['confidence'] : json['confidence'];

    return ChatMessage(
      id: json['message_id'] ?? _uuid.v4(),
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
      intentType: intentType,
      confidence: (confidenceRaw as num?)?.toDouble(),
      // Phase 3 backend additive fields (default to empty / false on legacy).
      sources: (json['sources'] as List<dynamic>?)
              ?.map((s) => SourceCitation.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      usedLlm: json['used_llm'] as bool? ?? false,
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

// Mirrors backend models/schemas.py:ChatRequest. Province/city are sent so
// helpline routing returns province-specific PDMA numbers; the backend will
// derive province from city when only city is supplied.
class ChatRequest {
  final String message;
  final String? sessionId;
  final String region;
  final String? province;
  final String? city;
  final String language;
  final Map<String, double>? location;
  final bool offlineContext;
  final Map<String, dynamic>? context;

  ChatRequest({
    required this.message,
    this.sessionId,
    this.region = 'pakistan',
    this.province,
    this.city,
    this.language = 'en',
    this.location,
    this.offlineContext = false,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'session_id': sessionId,
      'region': region,
      if (province != null) 'province': province,
      if (city != null) 'city': city,
      'language': language,
      if (location != null) 'location': location,
      'offline_context': offlineContext,
      if (context != null) 'context': context,
    };
  }
}

// Phase 3 / 4: Source citation surfaced under bot bubbles when the backend
// grounded the response in KB sources.
class SourceCitation {
  final String name;
  final String? url;

  const SourceCitation({required this.name, this.url});

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      name: (json['name'] as String?) ?? '',
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (url != null) 'url': url,
      };
}

// Phase 4: structured safety step inside a GuidanceContent block. Mirrors
// backend `SafetyStep` so offline rendering can reuse server-formatted lists.
class SafetyStep {
  final int stepNumber;
  final String action;
  final String? details;
  final bool isCritical;

  const SafetyStep({
    required this.stepNumber,
    required this.action,
    this.details,
    this.isCritical = false,
  });

  factory SafetyStep.fromJson(Map<String, dynamic> json) {
    return SafetyStep(
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 0,
      action: (json['action'] as String?) ?? '',
      details: json['details'] as String?,
      isCritical: json['is_critical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'step_number': stepNumber,
        'action': action,
        if (details != null) 'details': details,
        'is_critical': isCritical,
      };
}

// Phase 4: per-disaster guidance package shipped in /offline-data. The
// Phase 3 backend populates `before_steps`, `during_steps`, `after_steps`
// from the v2 KB. Phase 1 dropped this on the client (audit F8); Phase 4
// reads it.
class GuidanceContent {
  final String disasterType;
  final String title;
  final String summary;
  final List<SafetyStep> beforeSteps;
  final List<SafetyStep> duringSteps;
  final List<SafetyStep> afterSteps;
  final List<String> warnings;
  final List<String> helpfulLinks;

  const GuidanceContent({
    required this.disasterType,
    required this.title,
    required this.summary,
    this.beforeSteps = const [],
    this.duringSteps = const [],
    this.afterSteps = const [],
    this.warnings = const [],
    this.helpfulLinks = const [],
  });

  factory GuidanceContent.fromJson(Map<String, dynamic> json) {
    List<SafetyStep> readSteps(String key) =>
        ((json[key] as List?) ?? const [])
            .map((s) => SafetyStep.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
    return GuidanceContent(
      disasterType: (json['disaster_type'] as String?) ?? 'general',
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      beforeSteps: readSteps('before_steps'),
      duringSteps: readSteps('during_steps'),
      afterSteps: readSteps('after_steps'),
      warnings: (json['warnings'] as List?)?.cast<String>() ?? const [],
      helpfulLinks: (json['helpful_links'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'disaster_type': disasterType,
        'title': title,
        'summary': summary,
        'before_steps': beforeSteps.map((s) => s.toJson()).toList(),
        'during_steps': duringSteps.map((s) => s.toJson()).toList(),
        'after_steps': afterSteps.map((s) => s.toJson()).toList(),
        'warnings': warnings,
        'helpful_links': helpfulLinks,
      };
}

// Phase 4 (audit F8 client side + F10 checksum): consumes guidance_data and
// checksum from the backend's /offline-data response.
class OfflineData {
  final Map<String, List<HelplineInfo>> helplines;
  final Map<String, String> quickTips;
  final List<String> emergencyKeywords;
  final List<GuidanceContent> guidanceData;
  final String? checksum;
  final DateTime lastUpdated;

  OfflineData({
    required this.helplines,
    required this.quickTips,
    required this.emergencyKeywords,
    this.guidanceData = const [],
    this.checksum,
    required this.lastUpdated,
  });

  /// Lookup helper: find the GuidanceContent block for a disaster type.
  GuidanceContent? guidanceFor(String disasterType) {
    for (final g in guidanceData) {
      if (g.disasterType == disasterType) return g;
    }
    return null;
  }

  factory OfflineData.fromJson(Map<String, dynamic> json) {
    Map<String, List<HelplineInfo>> helplines = {};
    final rawHelplines = json['helplines'];
    if (rawHelplines is Map) {
      // Accept both <String, dynamic> (from jsonDecode) and <dynamic, dynamic>
      // (from in-memory test fixtures / Hive maps). Dart literal maps land
      // as the latter unless explicitly typed.
      rawHelplines.forEach((region, data) {
        if (data is List) {
          helplines[region.toString()] = data
              .map((h) =>
                  HelplineInfo.fromJson(Map<String, dynamic>.from(h as Map)))
              .toList();
        }
      });
    }

    final guidance = ((json['guidance_data'] as List?) ?? const [])
        .map((g) => GuidanceContent.fromJson(Map<String, dynamic>.from(g as Map)))
        .toList();

    return OfflineData(
      helplines: helplines,
      quickTips: Map<String, String>.from(json['quick_tips'] ?? {}),
      emergencyKeywords: List<String>.from(json['emergency_keywords'] ?? []),
      guidanceData: guidance,
      checksum: json['checksum'] as String?,
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
      'guidance_data': guidanceData.map((g) => g.toJson()).toList(),
      if (checksum != null) 'checksum': checksum,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
