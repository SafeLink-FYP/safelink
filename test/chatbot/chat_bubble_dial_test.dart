// Phase 5a.2 — dial-regex tests for the suggested-action chip dispatcher.
//
// The dispatcher in `_ChatBubbleState` routes "Call <name> <number>" chips
// to the phone dialer (with confirmation) and everything else to the
// legacy sendMessage path. The tests cover the parser in isolation —
// the actual `tel:` launch requires platform integration and is out of
// scope for unit testing.
//
// `tryParseDialNumber` and the underlying `dialActionRegex` are exposed
// from chat_bubble.dart via `@visibleForTesting`.

import 'package:flutter_test/flutter_test.dart';
import 'package:safelink/features/chatbot/presentation/widgets/chat_bubble.dart';

void main() {
  group('tryParseDialNumber — suggested-action chip dispatcher', () {
    test('"Call 115 now" matches and extracts 115', () {
      final number = tryParseDialNumber('Call 115 now');
      expect(number, '115',
          reason:
              'short-code emergency numbers (115 Edhi, 1122 Rescue) must '
              'route to the dialer, not be re-sent as chat prompts.');
    });

    test('"Earthquake safety tips" does NOT match (falls through to send-as-prompt)',
        () {
      final number = tryParseDialNumber('Earthquake safety tips');
      expect(number, isNull,
          reason: 'non-Call labels must fall through to the legacy '
              'sendMessage path so the user gets the safety guide.');
    });

    test('"Call PDMA Sindh 021-99213340" matches and extracts the PSTN form',
        () {
      final number = tryParseDialNumber('Call PDMA Sindh 021-99213340');
      expect(number, '021-99213340',
          reason: 'hyphenated provincial PDMA numbers must dial as-is — '
              'the dialer normalises the separator.');
    });

    test('"Call your local PDMA" does NOT match (no digits)', () {
      final number = tryParseDialNumber('Call your local PDMA');
      expect(number, isNull,
          reason: 'a Call label without a parsable number is informational; '
              'falling through to sendMessage lets the assistant follow up '
              'with the actual number rather than dialing nothing.');
    });

    test('"Tell me about 115" does NOT match (does not start with "Call")',
        () {
      final number = tryParseDialNumber('Tell me about 115');
      expect(number, isNull,
          reason: 'mentions of a number outside a Call-prefixed action must '
              'not trigger the dialer. The ^ anchor in the regex protects '
              'this.');
    });
  });

  group('tryParseDialNumber — additional shape coverage', () {
    test('"Call 1122" alone matches the short code', () {
      expect(tryParseDialNumber('Call 1122'), '1122');
    });

    test('"call 115 (edhi)" — case-insensitive, parens ignored', () {
      expect(tryParseDialNumber('call 115 (edhi)'), '115');
    });

    test('international form "+92 21 99213340" matches', () {
      final n = tryParseDialNumber('Call NDMA Helpline +92 21 99213340');
      expect(n, isNotNull, reason: 'international prefix should still match');
    });

    test('empty string does NOT match', () {
      expect(tryParseDialNumber(''), isNull);
    });
  });
}
