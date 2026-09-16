import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'bodhi_chat_store.dart';

part 'bodhi_chat_controller.g.dart';

@riverpod
BodhiChatStore bodhiChatStore(Ref ref) => BodhiChatStore();

/// Live `config/bodhi_ai`, watched by the app shell to show/hide the tab and
/// by the chat screen. Mirrors the `premiumConfigProvider` style.
@riverpod
Stream<BodhiAiConfig> bodhiAiConfig(Ref ref) {
  return ref.watch(configRepositoryProvider).watchBodhiAiConfig();
}

/// How a send attempt ended, so the screen can react (e.g. open the paywall
/// when a free user runs out).
enum BodhiSendOutcome { ok, refused, quotaExhausted, disabled, error }

/// UI state for the Ask Buddha screen.
class BodhiChatState {
  const BodhiChatState({
    this.messages = const [],
    this.sending = false,
    this.remainingSeconds,
    this.remainingMessages,
  });

  final List<BodhiMessage> messages;
  final bool sending;

  /// Null until the first server response (session start or a reply) lands.
  final int? remainingSeconds;
  final int? remainingMessages;

  BodhiChatState copyWith({
    List<BodhiMessage>? messages,
    bool? sending,
    int? remainingSeconds,
    int? remainingMessages,
  }) {
    return BodhiChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      remainingMessages: remainingMessages ?? this.remainingMessages,
    );
  }
}

/// Drives the Ask Buddha conversation: local history, streamed sends, and the
/// server-side minute session. The screen owns the lifecycle (calls
/// [startSession] on focus, [heartbeat] on a timer, [endSession] on leave);
/// this keeps `AppLifecycleListener` wiring in the widget where it belongs.
@riverpod
class BodhiChatController extends _$BodhiChatController {
  BodhiAiFunctionsService get _service =>
      ref.read(bodhiAiFunctionsServiceProvider);
  BodhiChatStore get _store => ref.read(bodhiChatStoreProvider);

  static const _historyTurns = 10;

  @override
  BodhiChatState build() {
    return BodhiChatState(messages: _store.load());
  }

  /// Recent turns sent to the server for context. The server re-sanitises and
  /// re-caps this, so it is only a courtesy trim.
  List<BodhiChatTurn> _history() {
    final settled = state.messages.where((m) => !m.pending && m.text.isNotEmpty);
    return [
      for (final m in settled.toList().reversed.take(_historyTurns).toList().reversed)
        m.isUser ? BodhiChatTurn.user(m.text) : BodhiChatTurn.assistant(m.text),
    ];
  }

  Future<BodhiSendOutcome> send(String text, {required String lang}) async {
    final question = text.trim();
    if (question.isEmpty || state.sending) return BodhiSendOutcome.ok;

    final history = _history();
    final withUser = [
      ...state.messages,
      BodhiMessage(role: 'user', text: question),
      const BodhiMessage(role: 'assistant', text: '', pending: true),
    ];
    state = state.copyWith(messages: withUser, sending: true);

    final buffer = StringBuffer();
    var outcome = BodhiSendOutcome.ok;
    try {
      await for (final event in _service.streamMessage(
        message: question,
        history: history,
      )) {
        switch (event) {
          case BodhiChatDelta(text: final delta):
            buffer.write(delta);
            _updateLastAssistant(buffer.toString(), pending: true);
          case BodhiChatDone(result: final result):
            _updateLastAssistant(
              result.reply.isNotEmpty ? result.reply : buffer.toString(),
              pending: false,
            );
            state = state.copyWith(
              remainingSeconds: result.remainingSeconds,
              remainingMessages: result.remainingMessages,
            );
            outcome =
                result.onTopic ? BodhiSendOutcome.ok : BodhiSendOutcome.refused;
        }
      }
      // Stream ended without a done event carrying text.
      if (buffer.isEmpty &&
          (state.messages.lastOrNull?.text ?? '').isEmpty) {
        _updateLastAssistant('', pending: false, drop: true);
      }
    } on FirebaseFunctionsException catch (e) {
      outcome = _mapError(e);
      _updateLastAssistant('', pending: false, drop: true);
    } catch (_) {
      outcome = BodhiSendOutcome.error;
      _updateLastAssistant('', pending: false, drop: true);
    } finally {
      state = state.copyWith(sending: false);
      await _store.save(state.messages);
    }
    return outcome;
  }

  BodhiSendOutcome _mapError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'resource-exhausted':
        return BodhiSendOutcome.quotaExhausted;
      case 'failed-precondition':
        return BodhiSendOutcome.disabled;
      default:
        return BodhiSendOutcome.error;
    }
  }

  void _updateLastAssistant(
    String text, {
    required bool pending,
    bool drop = false,
  }) {
    final list = [...state.messages];
    final i = list.lastIndexWhere((m) => m.role == 'assistant');
    if (i < 0) return;
    if (drop && text.isEmpty) {
      list.removeAt(i);
    } else {
      list[i] = list[i].copyWith(text: text, pending: pending);
    }
    state = state.copyWith(messages: list);
  }

  // --- Minute session (driven by the screen) ---

  Future<void> startSession() => _tick(BodhiSessionAction.start);
  Future<void> heartbeat() => _tick(BodhiSessionAction.heartbeat);
  Future<void> endSession() => _tick(BodhiSessionAction.end);

  Future<void> _tick(BodhiSessionAction action) async {
    try {
      final r = await _service.session(action);
      state = state.copyWith(
        remainingSeconds: r.remainingSeconds,
        remainingMessages: r.remainingMessages,
      );
    } catch (_) {
      // Session ticks are best-effort; a dropped heartbeat just means that
      // interval isn't charged. Quota errors surface on the next send.
    }
  }

  Future<void> clear() async {
    state = const BodhiChatState();
    await _store.clear();
  }
}
