import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safelink/features/chatbot/controllers/chat_controller.dart';
import 'package:safelink/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/chat_history_service.dart';
import 'package:safelink/features/chatbot/services/chatbot_service.dart';

/// Fake [ChatbotService] that yields a caller-supplied sequence of
/// [ChatMessage] snapshots from `streamMessage`. Each snapshot carries
/// its own `id`, mimicking how the real repository propagates the SSE
/// event's `message_id` (which is the source of the bubble-identity bug).
class _FakeChatbotService extends ChatbotService {
  _FakeChatbotService(this._snapshots)
      : super(repository: _PassthroughRepo());

  final List<ChatMessage> _snapshots;
  final RxBool _offline = false.obs;

  @override
  RxBool get offlineState => _offline;

  @override
  bool get isOffline => false;

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Future<void> syncOfflineData() async {}

  @override
  Stream<ChatMessage> streamMessage(
    String message, {
    String region = 'pakistan',
    String? city,
    String? language,
    Map<String, double>? location,
  }) async* {
    for (final s in _snapshots) {
      // Yield in microtasks so the controller's await-for actually pumps.
      await Future<void>.delayed(Duration.zero);
      yield s;
    }
  }
}

/// Real [ChatbotRepository] (so the parent service constructor type-checks)
/// — every method that matters is overridden on `_FakeChatbotService`. The
/// repository's constructor still runs `_initialize()` which reads
/// SharedPreferences; the test mocks it so the call resolves.
class _PassthroughRepo extends ChatbotRepository {}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempDir = await Directory.systemTemp.createTemp('chat_controller_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<Map>(ChatHistoryService.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await Hive.box<Map>(ChatHistoryService.boxName).clear();
    Get.reset();
    Get.put<ChatHistoryService>(ChatHistoryService(), permanent: true);
  });

  group('ChatController._streamWithFallback — bubble identity (regression)', () {
    test(
      'three deltas + one done with mismatched ids produce ONE bot bubble',
      () async {
        // Simulate the real ChatbotRepository → ChatController stream:
        //   - Three streaming snapshots, each with a different id (the
        //     repository falls back to a microsecond timestamp when the
        //     SSE event has no message_id).
        //   - One final snapshot with a stable id, sources, used_llm.
        // None of these ids match the controller's placeholderId.
        // Pre-fix behaviour: 4 bubbles. Post-fix: exactly 1.
        final snapshots = <ChatMessage>[
          ChatMessage(
            id: 'srv-id-001',
            content: 'To provide you',
            type: MessageType.bot,
            timestamp: DateTime(2026, 5, 8),
            isStreaming: true,
          ),
          ChatMessage(
            id: 'srv-id-002',
            content: 'To provide you with the correct',
            type: MessageType.bot,
            timestamp: DateTime(2026, 5, 8),
            isStreaming: true,
          ),
          ChatMessage(
            id: 'srv-id-003',
            content: 'To provide you with the correct emergency helplines',
            type: MessageType.bot,
            timestamp: DateTime(2026, 5, 8),
            isStreaming: true,
          ),
          // Final / done event — carries metadata, !isStreaming.
          ChatMessage(
            id: 'srv-id-final',
            content:
                'To provide you with the correct emergency helplines, please tell me your city.',
            type: MessageType.bot,
            timestamp: DateTime(2026, 5, 8),
            sources: const [SourceCitation(name: 'NDMA Pakistan')],
            usedLlm: true,
          ),
        ];

        final fake = _FakeChatbotService(snapshots);
        Get.put<ChatbotService>(fake, permanent: true);

        final controller = ChatController(chatService: fake);
        // onInit isn't auto-called outside Get.put plumbing; trigger
        // manually so the offline-state worker is bound. We still avoid
        // calling Get.put for the controller because we want to drive its
        // public API directly and reset state per-test.
        controller.onInit();

        await controller.sendMessage('what is the helpline');

        // Expected: 1 user message + 1 bot message = 2 total.
        expect(controller.messages.length, 2,
            reason:
                'expected the streaming consumer to upsert a single bot '
                'bubble; got ${controller.messages.length} entries — '
                'pre-fix this was 5 (1 user + 4 bot bubbles, one per delta).');

        final user = controller.messages.first;
        expect(user.type, MessageType.user);
        expect(user.content, 'what is the helpline');

        final bot = controller.messages.last;
        expect(bot.type, MessageType.bot);
        expect(bot.isStreaming, isFalse,
            reason: 'final bubble should have streaming flag cleared');
        expect(
          bot.content,
          'To provide you with the correct emergency helplines, please tell me your city.',
          reason: 'final bubble should carry the accumulated text from the '
              'done event',
        );
        expect(bot.sources, hasLength(1));
        expect(bot.sources.first.name, 'NDMA Pakistan');
        expect(bot.usedLlm, isTrue);
      },
    );
  });
}
