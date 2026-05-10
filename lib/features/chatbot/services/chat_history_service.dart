import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/chat_models.dart';

/// Hive-backed chat history with a hard cap and FIFO eviction.
///
/// Phase 4 locked decision (O9): box name is `chat_history`. The cap is 200
/// messages. We persist as Map (no TypeAdapter), mirroring [OutboxService]
/// so adding new fields to ChatMessage doesn't require code-gen.
///
/// Storage shape: a single box keyed by integer-stringified insertion index.
/// Hive `LinkedHashMap` preserves insertion order, so ``box.values`` is
/// already chronological.
class ChatHistoryService extends GetxService {
  // Locked box name (O9). Never rename without a migration.
  static const String boxName = 'chat_history';
  static const int maxMessages = 200;

  Box<Map>? _box;

  Box<Map> get _safeBox {
    final b = _box ?? Hive.box<Map>(boxName);
    _box = b;
    return b;
  }

  int get length => _safeBox.length;
  bool get isEmpty => _safeBox.isEmpty;

  /// Load the entire persisted history in chronological order.
  /// Skipped silently for any malformed entries (defensive — bad rows
  /// shouldn't break the screen).
  List<ChatMessage> load() {
    final out = <ChatMessage>[];
    for (final raw in _safeBox.values) {
      try {
        out.add(ChatMessage.fromHive(raw));
      } catch (e) {
        if (kDebugMode) {
          // Bad rows are dropped on read but don't crash the controller.
          // The next save will overwrite them.
          // ignore: avoid_print
          print('ChatHistoryService: skipping malformed entry: $e');
        }
      }
    }
    // Filter out the loading placeholder if it was somehow persisted.
    return out.where((m) => !m.isLoading).toList(growable: false);
  }

  /// Append a single message and enforce the FIFO cap.
  Future<void> append(ChatMessage message) async {
    if (message.isLoading) return; // never persist transient loading rows
    final box = _safeBox;
    await box.add(message.toHive());
    await _enforceCap(box);
  }

  /// Append a list. More efficient than calling `append` in a loop.
  Future<void> appendAll(Iterable<ChatMessage> messages) async {
    final box = _safeBox;
    final maps = messages
        .where((m) => !m.isLoading)
        .map((m) => m.toHive())
        .toList(growable: false);
    if (maps.isEmpty) return;
    await box.addAll(maps);
    await _enforceCap(box);
  }

  /// Replace a message by id (used by streaming: append placeholder, then
  /// upsert deltas / final). If the message isn't found, append it.
  Future<void> upsert(ChatMessage message) async {
    if (message.isLoading) return;
    final box = _safeBox;
    final keys = box.keys.toList();
    for (final key in keys) {
      final raw = box.get(key);
      if (raw is Map && raw['id'] == message.id) {
        await box.put(key, message.toHive());
        return;
      }
    }
    await append(message);
  }

  /// Drop everything. Used by "Clear chat" + sign-out hand-off.
  Future<int> clear() async {
    final n = _safeBox.length;
    await _safeBox.clear();
    return n;
  }

  Future<void> _enforceCap(Box<Map> box) async {
    if (box.length <= maxMessages) return;
    // Evict from the head until we're back under the cap.
    final toEvict = box.length - maxMessages;
    final headKeys = box.keys.take(toEvict).toList();
    await box.deleteAll(headKeys);
  }
}
