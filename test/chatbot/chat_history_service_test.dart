import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safelink/features/chatbot/models/chat_models.dart';
import 'package:safelink/features/chatbot/services/chat_history_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('chat_history_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<Map>(ChatHistoryService.boxName);
  });

  tearDown(() async {
    await Hive.box<Map>(ChatHistoryService.boxName).clear();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  ChatMessage userMsg(String content) => ChatMessage.user(content);
  ChatMessage botMsg(String id, String content) => ChatMessage(
        id: id,
        content: content,
        type: MessageType.bot,
        timestamp: DateTime.now(),
      );

  test('append + load round-trips', () async {
    final svc = ChatHistoryService();
    await svc.append(userMsg('hello'));
    await svc.append(botMsg('b1', 'hi there'));
    final loaded = svc.load();
    expect(loaded.length, 2);
    expect(loaded[0].type, MessageType.user);
    expect(loaded[0].content, 'hello');
    expect(loaded[1].type, MessageType.bot);
    expect(loaded[1].content, 'hi there');
  });

  test('FIFO eviction at 200-message cap', () async {
    final svc = ChatHistoryService();
    final batch = List<ChatMessage>.generate(
      ChatHistoryService.maxMessages + 5,
      (i) => botMsg('b$i', 'msg$i'),
    );
    await svc.appendAll(batch);
    final loaded = svc.load();
    expect(loaded.length, ChatHistoryService.maxMessages);
    // Oldest 5 should be gone (msg0..msg4); msg5 should be the head.
    expect(loaded.first.content, 'msg5');
    expect(loaded.last.content, 'msg${ChatHistoryService.maxMessages + 4}');
  });

  test('loading messages are never persisted', () async {
    final svc = ChatHistoryService();
    await svc.append(ChatMessage.loading());
    expect(svc.length, 0);
  });

  test('upsert replaces by id', () async {
    final svc = ChatHistoryService();
    await svc.append(botMsg('b1', 'first version'));
    await svc.upsert(botMsg('b1', 'second version'));
    final loaded = svc.load();
    expect(loaded.length, 1);
    expect(loaded.first.content, 'second version');
  });

  test('clear empties the box', () async {
    final svc = ChatHistoryService();
    await svc.append(userMsg('hi'));
    await svc.append(botMsg('b1', 'hello'));
    final n = await svc.clear();
    expect(n, 2);
    expect(svc.length, 0);
  });

  test('AuthController sign-out hand-off: clear() empties persistent storage',
      () async {
    // Mirrors what AuthController.signOut() does: wipe every persisted
    // message so the next user on a shared device can't see the previous
    // user's chat history. The clear must affect the underlying Hive box,
    // not just an in-memory cache — verify by reloading via a fresh
    // service instance.
    final writer = ChatHistoryService();
    await writer.append(userMsg('user-A: previous turn'));
    await writer.append(botMsg('b1', 'user-A bot reply'));
    expect(writer.length, 2);

    await writer.clear();

    // The same instance reports empty.
    expect(writer.length, 0);
    expect(writer.load(), isEmpty);

    // A brand-new instance — simulating the next user signing in and the
    // chatbot stack rebuilding against the same Hive box — also sees empty.
    final readerAfterSignIn = ChatHistoryService();
    expect(readerAfterSignIn.length, 0);
    expect(readerAfterSignIn.load(), isEmpty);
  });

  test('streaming + sources round-trip via toHive/fromHive', () async {
    final svc = ChatHistoryService();
    final original = ChatMessage(
      id: 'b1',
      content: 'grounded reply',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      sources: const [
        SourceCitation(name: 'NDMA Pakistan', url: 'https://ndma.gov.pk'),
        SourceCitation(name: 'PMD'),
      ],
      usedLlm: true,
    );
    await svc.append(original);
    final loaded = svc.load().single;
    expect(loaded.id, 'b1');
    expect(loaded.usedLlm, isTrue);
    expect(loaded.sources.length, 2);
    expect(loaded.sources.first.name, 'NDMA Pakistan');
    expect(loaded.sources.first.url, 'https://ndma.gov.pk');
  });
}
