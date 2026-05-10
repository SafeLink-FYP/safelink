import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/province_resolver.dart';
import 'package:uuid/uuid.dart';

/// Offline-mode response builder.
///
/// Phase 4 expansion (audit F11): all 8 disaster types are routable, not
/// just earthquake + flood. The full surface:
///   earthquake / flood / heatwave / cyclone / fire / gas_leak /
///   building_collapse / electric_shock
///
/// **Roman Urdu keywords stay** per locked Phase 4 decision: zalzala,
/// sailab, seelab, barish, monsoon, madad, bachao.
///
/// Phase 4 also (audit F8 client side): when a cached `OfflineData` carries
/// a `GuidanceContent` block for the detected disaster, prefer the
/// during-phase steps over the one-line `quick_tips` entry.
///
/// Phase 4 also (audit F9): if [city] is provided, the response prefers
/// province-specific helplines over the nationwide list.
class ChatbotOfflineResponseService {
  static const _uuid = Uuid();

  ChatMessage buildResponse({
    required String message,
    required String region,
    required OfflineData? offlineData,
    String? city,
  }) {
    final lowerMessage = message.toLowerCase();
    final province = ProvinceResolver.provinceFromCity(city);

    final isEmergency = _checkEmergencyKeywords(lowerMessage, offlineData);
    List<HelplineInfo> helplines = [];
    var urgency = UrgencyLevel.low;
    List<String> suggestedActions = [];
    String responseContent;

    final disasterType = _detectDisasterType(lowerMessage);

    if (isEmergency) {
      urgency = UrgencyLevel.critical;
      helplines = _resolveHelplines(region, province, offlineData);
      responseContent = _emergencyResponse(helplines);
      suggestedActions = ['Call emergency services now', 'Move to safety'];
    } else if (disasterType != null) {
      // Prefer the rich GuidanceContent block when the synced bundle has it.
      // Falls through to the one-line quick_tip, then to a generic message.
      final guidance = offlineData?.guidanceFor(disasterType);
      if (guidance != null && guidance.duringSteps.isNotEmpty) {
        responseContent = _formatGuidance(guidance);
      } else {
        responseContent =
            _quickTip(disasterType, offlineData) ?? _generalSafetyTip();
      }
      helplines = _resolveHelplines(
        region,
        province,
        offlineData,
        limit: 3,
      );
      urgency = UrgencyLevel.medium;
      suggestedActions = ['Learn more about safety', 'View emergency contacts'];
    } else if (_containsHelplineKeyword(lowerMessage)) {
      helplines = _resolveHelplines(region, province, offlineData);
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
      id: _uuid.v4(),
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

  // ─── Helpline resolution (province-aware) ──────────────────────────────────
  List<HelplineInfo> _resolveHelplines(
    String region,
    String? province,
    OfflineData? offlineData, {
    int limit = 5,
  }) {
    if (offlineData != null) {
      // Backend keys provincial slices as `<region>.<province>`.
      if (province != null) {
        final provincialKey = '$region.$province';
        final provincial = offlineData.helplines[provincialKey];
        if (provincial != null && provincial.isNotEmpty) {
          return provincial.take(limit).toList();
        }
      }
      final nationwide = offlineData.helplines[region];
      if (nationwide != null && nationwide.isNotEmpty) {
        return nationwide.take(limit).toList();
      }
    }
    return _defaultHelplines(region).take(limit).toList();
  }

  // ─── Detection ─────────────────────────────────────────────────────────────
  bool _checkEmergencyKeywords(String message, OfflineData? offlineData) {
    final emergencyKeywords = offlineData?.emergencyKeywords ??
        const [
          'help',
          'emergency',
          'sos',
          'trapped',
          'dying',
          'earthquake happening',
          'flood rising',
          'drowning',
          // Roman Urdu (locked: keep these in offline keyword detection).
          'madad',
          'bachao',
        ];
    return emergencyKeywords.any(message.contains);
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

  /// Detect any of the 8 disaster types covered by the v2 KB. Roman Urdu
  /// terms are kept inline per the locked Phase 4 decision.
  String? _detectDisasterType(String message) {
    const disasters = <String, List<String>>{
      'earthquake': ['earthquake', 'quake', 'tremor', 'seismic', 'zalzala'],
      'flood': [
        'flood',
        'flooding',
        'water rising',
        // Roman Urdu — never remove (locked).
        'sailab',
        'seelab',
        'barish',
        'monsoon',
      ],
      'heatwave': [
        'heatwave',
        'heat wave',
        'heat stroke',
        'extreme heat',
        'loo',
      ],
      'cyclone': ['cyclone', 'hurricane', 'typhoon', 'storm surge'],
      'fire': ['fire', 'burning', 'flames', 'smoke', 'kitchen fire'],
      'gas_leak': ['gas leak', 'gas smell', 'sui gas', 'cylinder leak'],
      'building_collapse': [
        'building collapsed',
        'building collapse',
        'wall collapsed',
        'roof collapsed',
        'trapped under',
      ],
      'electric_shock': [
        'electric shock',
        'electrocution',
        'electrocuted',
        'live wire',
      ],
    };
    for (final entry in disasters.entries) {
      if (entry.value.any(message.contains)) return entry.key;
    }
    return null;
  }

  String? _quickTip(String? disasterType, OfflineData? offlineData) {
    if (disasterType == null) return null;
    final tips = offlineData?.quickTips ?? _builtinQuickTips;
    return tips[disasterType];
  }

  // ─── Formatters ────────────────────────────────────────────────────────────
  String _formatGuidance(GuidanceContent g) {
    final buf = StringBuffer();
    if (g.title.isNotEmpty) buf.writeln('**${g.title}**');
    if (g.summary.isNotEmpty) {
      buf
        ..writeln()
        ..writeln(g.summary);
    }
    if (g.duringSteps.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('**Immediate steps:**');
      for (final s in g.duringSteps) {
        buf.writeln('${s.stepNumber}. ${s.action}');
      }
    }
    if (g.beforeSteps.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('**Before / preparation:**');
      for (final s in g.beforeSteps) {
        buf.writeln('${s.stepNumber}. ${s.action}');
      }
    }
    if (g.afterSteps.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('**After:**');
      for (final s in g.afterSteps) {
        buf.writeln('${s.stepNumber}. ${s.action}');
      }
    }
    if (g.warnings.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('⚠️ ${g.warnings.first}');
    }
    buf
      ..writeln()
      ..writeln('*Currently in offline mode — based on cached safety guidance.*');
    return buf.toString().trim();
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
        .map((h) =>
            '• **${h.name}**: ${h.number}${h.available24x7 ? ' (24/7)' : ''}')
        .join('\n');
    return '''**Emergency Helplines - Pakistan:**

$helplineText

💾 Save these numbers for quick access during emergencies.''';
  }

  String _greetingResponse() =>
      '''Assalam-o-Alaikum! I'm the SafeLink Safety Assistant. 👋

🇵🇰 I'm here to help you with:
• **Disaster Safety Guidance** — Earthquake, Flood, Heatwave, Cyclone, Fire, Gas leak, Building collapse, Electric shock
• **Emergency Helplines** — Pakistan emergency contacts
• **First Aid Information** — Basic first aid guidance

How can I assist you today?

⚠️ *Currently in offline mode — responses are based on cached data.*''';

  String _fallbackResponse() =>
      '''I'm here to help with disaster safety information for Pakistan.

I can assist with:
• Safety tips for all major disasters (earthquakes, floods, heatwaves, cyclones, fire, gas leaks, building collapse, electric shock)
• Emergency helpline numbers (1122, 115, NDMA)
• Basic first aid information
• Evacuation guidance

What would you like to know?

⚠️ *Currently in offline mode — for detailed guidance, please connect to the internet.*''';

  List<HelplineInfo> _defaultHelplines(String region) {
    return [
      HelplineInfo(name: 'Rescue 1122', number: '1122', region: region),
      HelplineInfo(name: 'Edhi Foundation', number: '115', region: region),
      HelplineInfo(name: 'Police', number: '15', region: region),
      HelplineInfo(name: 'Fire Brigade', number: '16', region: region),
      HelplineInfo(name: 'NDMA', number: '051-9205037', region: region),
    ];
  }

  // Builtin quick tips covering all 8 disaster types — used when no
  // synced bundle is available. Mirrors the backend's response_templates.json
  // quick_tips entries in shape (concise, action-first).
  static const Map<String, String> _builtinQuickTips = {
    'earthquake':
        '🏠 **Quick Earthquake Tips (Pakistan):**\nDROP, COVER, HOLD ON | Stay away from windows | Don\'t run outside during shaking | Call **1122** or **115**',
    'flood':
        '🌊 **Quick Flood Tips (Pakistan):**\nMove to higher ground | Never walk/drive through flood water | Call **1122** or **115** | NDMA: **051-9205037**',
    'heatwave':
        '🌡️ **Quick Heatwave Tips:**\nStay indoors 11 AM–4 PM | Drink water every 15 min | ORS for outdoor workers | Cool with wet cloth on neck/wrists | Heat stroke = call **115** immediately',
    'cyclone':
        '🌀 **Quick Cyclone Tips (Coastal Sindh/Balochistan):**\nFollow PMD / PDMA evacuation orders | Move inland & upward | Stay indoors away from windows | Don\'t go out during the calm \'eye\' of storm | Call **1122**',
    'fire':
        '🔥 **Quick Fire Tips:**\nGET OUT, STAY OUT | Crawl under smoke | Stop, Drop, Roll if clothes catch fire | Never use elevator | Call **16** (Fire) or **1122**',
    'gas_leak':
        '⛽ **Quick Gas-Leak Tips:**\nDO NOT switch on/off any electrical | Don\'t light matches | Open windows & doors | Evacuate everyone | Call **1199** (SSGC/SNGPL) from a safe distance',
    'building_collapse':
        '🏚️ **Quick Building-Collapse Tips:**\nIf trapped: stay calm, cover mouth/nose, tap on pipes/walls | Outside: don\'t enter — wait for Rescue 1122 | Note exact location of trapped people for responders',
    'electric_shock':
        '⚡ **Quick Electric-Shock Tips:**\nNEVER touch the person while connected to power | Switch off main breaker first | Use a dry wooden stick to push the source away | Once safe → check breathing, start CPR if needed | Call **115**',
  };
}
