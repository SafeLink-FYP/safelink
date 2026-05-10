import 'package:flutter_test/flutter_test.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';

void main() {
  group('ChatRequest.toJson — expanded field set (audit F9)', () {
    test('includes city/province/language/location/offline_context when set', () {
      final request = ChatRequest(
        message: 'flood safety',
        sessionId: 'sess_123',
        province: 'punjab',
        city: 'lahore',
        language: 'en',
        location: const {'lat': 31.5, 'lng': 74.3},
        offlineContext: false,
      );

      final json = request.toJson();
      expect(json['message'], 'flood safety');
      expect(json['session_id'], 'sess_123');
      expect(json['region'], 'pakistan'); // default
      expect(json['province'], 'punjab');
      expect(json['city'], 'lahore');
      expect(json['language'], 'en');
      expect(json['location'], {'lat': 31.5, 'lng': 74.3});
      expect(json['offline_context'], false);
    });

    test('omits null province/city/location keys', () {
      final request = ChatRequest(message: 'hi');
      final json = request.toJson();
      expect(json.containsKey('province'), false);
      expect(json.containsKey('city'), false);
      expect(json.containsKey('location'), false);
      expect(json['offline_context'], false);
      expect(json['language'], 'en');
    });
  });

  group('UrgencyLevel.high (audit: enum gap)', () {
    test('parses "high" from backend wire format', () {
      // Round-trip through ChatMessage.fromJson which is the only public
      // path that exercises _parseUrgencyLevel.
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'careful',
        'urgency_level': 'high',
      });
      expect(msg.urgencyLevel, UrgencyLevel.high);
    });

    test('parses "critical"', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'evacuate',
        'urgency_level': 'critical',
      });
      expect(msg.urgencyLevel, UrgencyLevel.critical);
    });

    test('parses "medium" and "low"', () {
      final mid = ChatMessage.fromJson({
        'message_id': 'm2',
        'response': 'tip',
        'urgency_level': 'medium',
      });
      expect(mid.urgencyLevel, UrgencyLevel.medium);

      final lo = ChatMessage.fromJson({
        'message_id': 'm3',
        'response': 'thanks',
        'urgency_level': 'low',
      });
      expect(lo.urgencyLevel, UrgencyLevel.low);
    });

    test('unknown urgency falls through to low', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm4',
        'response': 'x',
        'urgency_level': 'something_new',
      });
      expect(msg.urgencyLevel, UrgencyLevel.low);
    });
  });

  group('ChatMessage.fromJson — intent shape (audit: intent_type bug)', () {
    test('reads intent.intent from the nested object the backend ships', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'safety advice',
        'intent': {
          'intent': 'safety_advice',
          'confidence': 0.87,
          'sub_intent': 'earthquake',
        },
        'urgency_level': 'medium',
      });
      expect(msg.intentType, 'safety_advice');
      expect(msg.confidence, closeTo(0.87, 1e-6));
    });

    test('legacy flat string intent field also parsed', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'hi',
        'intent': 'greetings',
      });
      expect(msg.intentType, 'greetings');
    });

    test('missing intent yields null intentType', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'hi',
      });
      expect(msg.intentType, null);
    });
  });

  group('Message IDs are uuids (audit F13)', () {
    test('ChatMessage.user() generates a uuid id', () {
      final a = ChatMessage.user('hello');
      final b = ChatMessage.user('hello');
      expect(a.id, isNot(b.id));
      expect(a.id.length, 36);
      expect(a.id.contains('-'), true);
    });
  });

  group('Phase 4 — ChatMessage.sources + usedLlm', () {
    test('parses sources and used_llm from backend response', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'grounded',
        'used_llm': true,
        'sources': [
          {'name': 'NDMA Pakistan', 'url': 'https://ndma.gov.pk'},
          {'name': 'PMD'},
        ],
      });
      expect(msg.usedLlm, isTrue);
      expect(msg.sources.length, 2);
      expect(msg.sources.first.name, 'NDMA Pakistan');
      expect(msg.sources.first.url, 'https://ndma.gov.pk');
      expect(msg.sources.last.url, isNull);
    });

    test('legacy responses default sources=[] and usedLlm=false', () {
      final msg = ChatMessage.fromJson({
        'message_id': 'm1',
        'response': 'hi',
      });
      expect(msg.usedLlm, isFalse);
      expect(msg.sources, isEmpty);
    });
  });

  group('Phase 4 — OfflineData consumes guidance_data + checksum', () {
    test('guidance_data parsed into typed objects', () {
      final od = OfflineData.fromJson({
        'helplines': {},
        'quick_tips': {},
        'emergency_keywords': [],
        'guidance_data': [
          {
            'disaster_type': 'flood',
            'title': 'Flood Safety',
            'summary': 'Move to higher ground.',
            'before_steps': [],
            'during_steps': [
              {'step_number': 1, 'action': 'Move to higher ground'},
              {'step_number': 2, 'action': 'Avoid flood water'},
            ],
            'after_steps': [],
            'warnings': ['Don\'t drink tap water'],
            'helpful_links': ['https://ndma.gov.pk'],
          }
        ],
        'checksum': 'abc123',
        'last_updated': '2026-05-08T00:00:00Z',
      });
      expect(od.checksum, 'abc123');
      expect(od.guidanceData.length, 1);
      final g = od.guidanceFor('flood');
      expect(g, isNotNull);
      expect(g!.duringSteps.length, 2);
      expect(g.duringSteps.first.action, 'Move to higher ground');
      expect(g.warnings.first, contains('tap water'));
    });

    test('guidance_data missing → empty list, checksum null', () {
      final od = OfflineData.fromJson({
        'helplines': {},
        'quick_tips': {},
        'emergency_keywords': [],
        'last_updated': '2026-05-08T00:00:00Z',
      });
      expect(od.guidanceData, isEmpty);
      expect(od.checksum, isNull);
    });
  });

  group('ChatMessage.toHive / fromHive round-trip', () {
    test('preserves type, urgency, sources, usedLlm', () {
      final original = ChatMessage(
        id: 'mid',
        content: 'hi',
        type: MessageType.bot,
        timestamp: DateTime(2026, 5, 8, 12, 0, 0),
        urgencyLevel: UrgencyLevel.high,
        sources: const [SourceCitation(name: 'NDMA')],
        usedLlm: true,
      );
      final round = ChatMessage.fromHive(original.toHive());
      expect(round.id, 'mid');
      expect(round.type, MessageType.bot);
      expect(round.urgencyLevel, UrgencyLevel.high);
      expect(round.usedLlm, isTrue);
      expect(round.sources.single.name, 'NDMA');
    });
  });
}
