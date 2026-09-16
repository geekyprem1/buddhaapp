import 'package:cloud_functions/cloud_functions.dart';

import '../constants/app_constants.dart';

/// One turn of chat history sent back to the server for context.
///
/// Only `user` and `assistant` are permitted. The `system` role is constructed
/// server-side and a client-supplied one is dropped, so a modified client
/// cannot inject instructions (see design § Scope Restriction).
class BodhiChatTurn {
  const BodhiChatTurn.user(this.content) : role = 'user';
  const BodhiChatTurn.assistant(this.content) : role = 'assistant';

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Terminal payload of a chat call.
class BodhiChatResult {
  const BodhiChatResult({
    required this.reply,
    required this.onTopic,
    required this.remainingMessages,
  });

  final String reply;

  /// False when the question was off topic and the model declined. A refusal
  /// refunds the message charge, so [remainingMessages] is unchanged by it.
  final bool onTopic;
  final int remainingMessages;

  factory BodhiChatResult.fromMap(Map<String, dynamic> data) {
    return BodhiChatResult(
      reply: data['reply'] as String? ?? '',
      onTopic: data['onTopic'] as bool? ?? true,
      remainingMessages: (data['remainingMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Events emitted while a reply streams in.
sealed class BodhiChatEvent {}

/// An incremental slice of reply text.
class BodhiChatDelta extends BodhiChatEvent {
  BodhiChatDelta(this.text);
  final String text;
}

/// Stream finished; carries the full reply and refreshed quota.
class BodhiChatDone extends BodhiChatEvent {
  BodhiChatDone(this.result);
  final BodhiChatResult result;
}

/// Today's remaining allowance, as reported by `bodhiQuota`.
class BodhiQuotaResult {
  const BodhiQuotaResult({required this.remainingMessages});

  final int remainingMessages;

  factory BodhiQuotaResult.fromMap(Map<String, dynamic> data) {
    return BodhiQuotaResult(
      remainingMessages: (data['remainingMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Client wrapper for the Bodhi AI callables.
///
/// The OpenRouter key, the daily quota and the system prompt all live
/// server-side — this class only carries a question and renders what comes
/// back. It deliberately exposes no way to influence the model, the limits, or
/// the scope rule.
class BodhiAiFunctionsService {
  BodhiAiFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: AppConstants.functionsRegion);

  final FirebaseFunctions _functions;

  /// Longer than the 60 s default: a reasoning model can take a while on a
  /// long answer, and a timeout here reads to the user as a lost message.
  static const _chatTimeout = Duration(seconds: 90);

  Map<String, dynamic> _payload(
    String message,
    List<BodhiChatTurn> history,
    String lang,
  ) {
    return {
      'message': message,
      'history': [for (final turn in history) turn.toJson()],
      // BCP-47-ish app language code; the server validates against its own
      // allowlist and falls back to English (A2 — previously never sent).
      'lang': lang,
    };
  }

  /// Streamed reply.
  ///
  /// Wire contract with the Function: each `sendChunk` carries a plain text
  /// delta (a `String`), and the returned value is the [BodhiChatResult] map.
  /// `sendChunk` is a documented no-op when the platform does not accept
  /// streaming, in which case only [BodhiChatDone] is emitted.
  Stream<BodhiChatEvent> streamMessage({
    required String message,
    List<BodhiChatTurn> history = const [],
    String lang = 'en',
  }) async* {
    final callable = _functions.httpsCallable(
      AppConstants.fnBodhiChat,
      options: HttpsCallableOptions(timeout: _chatTimeout),
    );

    // Parsed defensively rather than with a hard cast: this is a network
    // boundary, and a shape change should not throw inside the stream.
    await for (final response in callable.stream<Object?, Object?>(
      _payload(message, history, lang),
    )) {
      switch (response) {
        case Chunk(partialData: final data):
          final text = data is String ? data : data?.toString() ?? '';
          if (text.isNotEmpty) yield BodhiChatDelta(text);
        case Result(result: final result):
          final data = result.data;
          if (data is Map) {
            yield BodhiChatDone(
              BodhiChatResult.fromMap(Map<String, dynamic>.from(data)),
            );
          }
      }
    }
  }

  /// Unary reply, for callers that do not want to render a stream.
  Future<BodhiChatResult> sendMessage({
    required String message,
    List<BodhiChatTurn> history = const [],
    String lang = 'en',
  }) async {
    final callable = _functions.httpsCallable(
      AppConstants.fnBodhiChat,
      options: HttpsCallableOptions(timeout: _chatTimeout),
    );
    final result = await callable.call<Map<Object?, Object?>>(
      _payload(message, history, lang),
    );
    return BodhiChatResult.fromMap(Map<String, dynamic>.from(result.data));
  }

  /// Today's remaining allowance, without spending anything. Called when the
  /// chat screen opens so the counter is populated before the first reply.
  Future<BodhiQuotaResult> quota() async {
    final callable = _functions.httpsCallable(AppConstants.fnBodhiQuota);
    final result = await callable.call<Map<Object?, Object?>>();
    return BodhiQuotaResult.fromMap(Map<String, dynamic>.from(result.data));
  }
}
