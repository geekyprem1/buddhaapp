import 'dart:convert';

import 'package:hive/hive.dart';

/// One chat message as shown in the UI and persisted locally.
class BodhiMessage {
  const BodhiMessage({
    required this.role,
    required this.text,
    this.pending = false,
  });

  /// `user` or `assistant`.
  final String role;
  final String text;

  /// True while the assistant reply is still streaming in.
  final bool pending;

  bool get isUser => role == 'user';

  BodhiMessage copyWith({String? text, bool? pending}) => BodhiMessage(
        role: role,
        text: text ?? this.text,
        pending: pending ?? this.pending,
      );

  Map<String, dynamic> toJson() => {'role': role, 'text': text};

  factory BodhiMessage.fromJson(Map<String, dynamic> json) => BodhiMessage(
        role: json['role'] as String? ?? 'assistant',
        text: json['text'] as String? ?? '',
      );
}

/// Local, on-device transcript for Bodhi AI.
///
/// The server stores nothing (design § Chat history — local only), so history
/// lives here in the `bodhi_chat` Hive box, opened at startup by
/// `AlarmLocalStore.init`. Capped so a long-running user doesn't grow it
/// unbounded.
class BodhiChatStore {
  static const boxName = 'bodhi_chat';
  static const _key = 'messages';
  static const _maxMessages = 200;

  Box<String>? get _box =>
      Hive.isBoxOpen(boxName) ? Hive.box<String>(boxName) : null;

  List<BodhiMessage> load() {
    final raw = _box?.get(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => BodhiMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<BodhiMessage> messages) async {
    final box = _box;
    if (box == null) return;
    // Persist only settled messages, and only the most recent [_maxMessages].
    final settled = messages
        .where((m) => !m.pending && m.text.trim().isNotEmpty)
        .toList();
    final capped = settled.length > _maxMessages
        ? settled.sublist(settled.length - _maxMessages)
        : settled;
    await box.put(_key, jsonEncode([for (final m in capped) m.toJson()]));
  }

  Future<void> clear() async => _box?.delete(_key);
}
