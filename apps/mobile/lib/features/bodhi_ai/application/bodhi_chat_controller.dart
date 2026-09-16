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
///
/// [quotaExhausted] covers running out of the daily message allowance. It used
/// to be split from a separate `messageLimit` case, because a wall-clock meter
/// could run out independently of the message cap; with that meter gone there
/// is only one way to run out.
enum BodhiSendOutcome { ok, refused, quotaExhausted, disabled, error }

/// UI state for the Ask Buddha screen.
class BodhiChatState {
  const BodhiChatState({
    this.messages = const [],
    this.sending = false,
    this.remainingMessages,
  });

  final List<BodhiMessage> messages;
  final bool sending;

  /// Null until the first server response (the opening quota fetch, or a
  /// reply) lands, so the counter is hidden rather than showing a wrong zero.
  final int? remainingMessages;

  BodhiChatState copyWith({
    List<BodhiMessage>? messages,
    bool? sending,
    int? remainingMessages,
  }) {
    return BodhiChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      remainingMessages: remainingMessages ?? this.remainingMessages,
    );
  }
}

/// Drives the Ask Buddha conversation: local history and streamed sends.
///
/// The quota is per-message and charged server-side on send, so there is no
/// session to keep open — the screen just calls [refreshQuota] once when it
/// opens so the counter is populated before the first reply.
@riverpod
class BodhiChatController extends _$BodhiChatController {
  BodhiAiFunctionsService get _service =>
      ref.read(bodhiAiFunctionsServiceProvider);
  BodhiChatStore get _store => ref.read(bodhiChatStoreProvider);

  static const _historyTurns = 10;

  /// Monotonic request id (N1): every [send] captures one; [clear] and account
  /// switches (via [build]) invalidate it, so a late reply from a superseded
  /// request can never overwrite a newer conversation or reset its flags.
  int _generation = 0;

  @override
  BodhiChatState build() {
    // Per-account transcript (A6): only the uid is watched, so profile
    // updates (name, lastActiveAt, …) don't reset in-flight chat, but an
    // account switch reloads the correct namespaced history. Signed out →
    // empty, so no other account's transcript is ever shown or re-sent as
    // history to the server.
    final uid = ref.watch(
      currentAppUserProvider.select((v) => v.valueOrNull?.uid),
    );
    // A rebuild here means an account switch (only uid is watched): retire any
    // in-flight request from the previous account (N1).
    _generation++;
    if (uid == null) return const BodhiChatState();
    return BodhiChatState(messages: _store.load(uid));
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
    // Sending account, captured up front (A6): a mid-send account switch must
    // not write this transcript into the new account's namespace.
    final uid = ref.read(currentAppUserProvider).valueOrNull?.uid;
    // Claim this request's generation (N1).
    final gen = ++_generation;

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
        lang: lang,
      )) {
        // Superseded by a clear / newer send / account switch (N1): stop
        // touching state; the finally below will also stand down.
        if (gen != _generation) return BodhiSendOutcome.ok;
        switch (event) {
          case BodhiChatDelta(text: final delta):
            buffer.write(delta);
            _updateLastAssistant(buffer.toString(), pending: true);
          case BodhiChatDone(result: final result):
            _updateLastAssistant(
              result.reply.isNotEmpty ? result.reply : buffer.toString(),
              pending: false,
            );
            state =
                state.copyWith(remainingMessages: result.remainingMessages);
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
      // A superseded request's error belongs to a dead conversation (N1).
      if (gen != _generation) return BodhiSendOutcome.ok;
      outcome = _mapError(e);
      _updateLastAssistant('', pending: false, drop: true);
      // A failed send must not linger as an unanswered user turn (A8): it
      // would be persisted and re-sent as "successful" context next time.
      // The screen restores the text into the composer for retry.
      _removeLastUserTurn(question);
    } catch (_) {
      if (gen != _generation) return BodhiSendOutcome.ok;
      outcome = BodhiSendOutcome.error;
      _updateLastAssistant('', pending: false, drop: true);
      _removeLastUserTurn(question);
    } finally {
      // Only the current generation may settle flags or persist (N1): a late
      // reply must not unblock a newer send or save over its transcript.
      if (gen == _generation) {
        state = state.copyWith(sending: false);
        // Signed-out sends stay in memory only — never persist one account's
        // transcript where another account could adopt it.
        if (uid != null) await _store.save(uid, state.messages);
      }
    }
    return outcome;
  }

  BodhiSendOutcome _mapError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'resource-exhausted':
        // Distinct server reasons (A9): only running out of the daily
        // allowance nudges the paywall. Strike-lockout and upstream rate
        // limits are plain errors — a paywall would be nonsense there, since
        // paying wouldn't help. An unknown reason is treated as quota, which
        // is also what older deployed functions ('time-limit') map to.
        final details = e.details;
        final reason = details is Map ? details['reason'] : null;
        switch (reason) {
          case 'off-topic-limit':
          case 'upstream-rate-limit':
            return BodhiSendOutcome.error;
          default:
            return BodhiSendOutcome.quotaExhausted;
        }
      case 'failed-precondition':
        return BodhiSendOutcome.disabled;
      default:
        return BodhiSendOutcome.error;
    }
  }

  /// Removes the just-added user turn after a failed send (A8), matched by
  /// exact text so a newer message can never be removed by mistake.
  void _removeLastUserTurn(String question) {
    final list = [...state.messages];
    if (list.isNotEmpty && list.last.isUser && list.last.text == question) {
      list.removeLast();
      state = state.copyWith(messages: list);
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

  /// Fetch today's remaining messages without spending anything. Called when
  /// the screen opens; best-effort, since the count is only informational —
  /// the real limit is enforced server-side on the next send.
  Future<void> refreshQuota() async {
    final gen = _generation;
    try {
      final r = await _service.quota();
      // An account switch or clear happened while this was in flight (N1).
      if (gen != _generation) return;
      state = state.copyWith(remainingMessages: r.remainingMessages);
    } catch (_) {
      // Offline, disabled, or App Check hiccup — leave the counter hidden.
    }
  }

  Future<void> clear() async {
    final uid = ref.read(currentAppUserProvider).valueOrNull?.uid;
    // Retire any in-flight request first (N1): its late events must not touch
    // the fresh empty state or a message sent right after clearing.
    _generation++;
    state = const BodhiChatState();
    await _store.clear(uid);
  }
}
