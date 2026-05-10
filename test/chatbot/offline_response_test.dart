import 'package:flutter_test/flutter_test.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/chatbot_offline_response_service.dart';

OfflineData _emptyBundle() => OfflineData(
      helplines: const {},
      quickTips: const {},
      emergencyKeywords: const [],
      lastUpdated: DateTime.now(),
    );

void main() {
  late ChatbotOfflineResponseService svc;

  setUp(() {
    svc = ChatbotOfflineResponseService();
  });

  group('Phase 4 — extended disaster detection (audit F11)', () {
    final cases = <String, String>{
      'tell me about earthquake safety': 'earthquake',
      'we feel a strong tremor': 'earthquake',
      'water rising near my home': 'flood',
      'sailab rising fast': 'flood',
      'monsoon flood preparedness': 'flood',
      'heatwave alert in karachi': 'heatwave',
      'extreme heat at work': 'heatwave',
      'cyclone near gwadar': 'cyclone',
      'hurricane is approaching': 'cyclone',
      'kitchen fire what to do': 'fire',
      'i smell smoke': 'fire',
      'gas leak in the house': 'gas_leak',
      'sui gas smell strong': 'gas_leak',
      'building collapsed nearby': 'building_collapse',
      'electric shock victim': 'electric_shock',
      'someone got electrocuted': 'electric_shock',
    };

    for (final entry in cases.entries) {
      test('routes "${entry.key}" to ${entry.value}', () {
        final reply = svc.buildResponse(
          message: entry.key,
          region: 'pakistan',
          offlineData: null,
        );
        // Either returned content mentions the disaster type token, or
        // the canonical built-in tip carries the category prefix.
        final lower = reply.content.toLowerCase();
        final dt = entry.value;
        // Heuristic — content mentions the category or a canonical
        // keyword from the built-in tip for that disaster.
        final tokens = {
          'earthquake': ['earthquake', 'drop', 'cover', 'hold'],
          'flood': ['flood', 'higher ground'],
          'heatwave': ['heatwave', 'heat'],
          'cyclone': ['cyclone'],
          'fire': ['fire'],
          'gas_leak': ['gas'],
          'building_collapse': ['building', 'trapped'],
          'electric_shock': ['electric'],
        };
        final keys = tokens[dt] ?? const [];
        expect(
          keys.any(lower.contains),
          isTrue,
          reason: 'expected $dt-related content for "${entry.key}", got: ${reply.content}',
        );
      });
    }
  });

  group('Roman Urdu keywords stay (locked Phase 4 decision)', () {
    test('zalzala routes to earthquake', () {
      final reply = svc.buildResponse(
        message: 'zalzala aaya hai',
        region: 'pakistan',
        offlineData: null,
      );
      expect(reply.content.toLowerCase(), contains('earthquake'));
    });

    test('sailab routes to flood', () {
      final reply = svc.buildResponse(
        message: 'sailab ka khatra',
        region: 'pakistan',
        offlineData: null,
      );
      expect(reply.content.toLowerCase().contains('flood') ||
              reply.content.toLowerCase().contains('higher ground'),
          isTrue);
    });

    test('madad triggers emergency response', () {
      final reply = svc.buildResponse(
        message: 'madad chahiye',
        region: 'pakistan',
        offlineData: null,
      );
      expect(reply.isEmergency, isTrue);
      expect(reply.urgencyLevel, UrgencyLevel.critical);
    });
  });

  group('Audit F8 client-side: prefer guidance_data when present', () {
    test('uses cached during-steps over the one-line tip', () {
      final bundle = OfflineData(
        helplines: {
          'pakistan': [
            HelplineInfo(name: 'Rescue 1122', number: '1122', region: 'pakistan'),
          ],
        },
        quickTips: const {
          'heatwave': 'BUILT-IN ONE-LINER (should NOT appear)',
        },
        emergencyKeywords: const [],
        guidanceData: const [
          GuidanceContent(
            disasterType: 'heatwave',
            title: 'Heatwave Safety',
            summary: 'Cool down and hydrate',
            duringSteps: [
              SafetyStep(stepNumber: 1, action: 'Stay indoors 11 AM-4 PM'),
              SafetyStep(stepNumber: 2, action: 'Drink water every 15 min'),
              SafetyStep(stepNumber: 3, action: 'Wet cloth on neck'),
            ],
          ),
        ],
        lastUpdated: DateTime.now(),
      );
      final reply = svc.buildResponse(
        message: 'heatwave karachi',
        region: 'pakistan',
        offlineData: bundle,
      );
      expect(reply.content, contains('Stay indoors 11 AM-4 PM'));
      expect(reply.content, contains('Drink water every 15 min'));
      expect(reply.content.contains('BUILT-IN ONE-LINER'), isFalse);
    });
  });

  group('Audit F9 client-side: province-aware helplines via city', () {
    test('uses provincial slice when city resolves to province', () {
      final bundle = OfflineData(
        helplines: {
          'pakistan': [
            HelplineInfo(name: 'Nationwide', number: '1122', region: 'pakistan'),
          ],
          'pakistan.punjab': [
            HelplineInfo(
              name: 'PDMA Punjab',
              number: '042-99205316',
              region: 'pakistan',
              category: 'disaster',
            ),
          ],
        },
        quickTips: const {},
        emergencyKeywords: const [],
        lastUpdated: DateTime.now(),
      );
      final reply = svc.buildResponse(
        message: 'helpline number',
        region: 'pakistan',
        offlineData: bundle,
        city: 'lahore',
      );
      final numbers = reply.helplines.map((h) => h.number).toList();
      expect(numbers, contains('042-99205316'));
    });

    test('falls back to nationwide when city is unknown', () {
      final bundle = OfflineData(
        helplines: {
          'pakistan': [
            HelplineInfo(name: 'Nationwide', number: '1122', region: 'pakistan'),
          ],
          'pakistan.punjab': [
            HelplineInfo(name: 'PDMA Punjab', number: '042-99205316', region: 'pakistan'),
          ],
        },
        quickTips: const {},
        emergencyKeywords: const [],
        lastUpdated: DateTime.now(),
      );
      final reply = svc.buildResponse(
        message: 'helpline number',
        region: 'pakistan',
        offlineData: bundle,
        city: 'atlantis',
      );
      final numbers = reply.helplines.map((h) => h.number).toList();
      expect(numbers, contains('1122'));
    });
  });

  test('greeting still routes to greeting (unchanged behaviour)', () {
    final reply = svc.buildResponse(
      message: 'hello',
      region: 'pakistan',
      offlineData: _emptyBundle(),
    );
    expect(reply.suggestedActions, isNotEmpty);
    expect(reply.content.toLowerCase(), contains('safelink'));
  });
}
