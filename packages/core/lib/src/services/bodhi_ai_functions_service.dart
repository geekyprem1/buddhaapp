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
    required this.remainingSeconds,
    required this.remainingMessages,
  });

  final String reply;

  /// False when the topic gate refused the question. A refusal does not
  /// consume the minute quota, so [remainingSeconds] will be unchanged.
  final bool onTopic;
  final int remainingSeconds;
  final int remainingMessages;

  factory BodhiChatResult.fromMap(Map<String, dynamic> data) {
    return BodhiChatResult(
      reply: data['reply'] as String? ?? '',
      onTopic: data['onTopic'] as bool? ?? true,
      remainingSeconds: (data['remainingSeconds'] as num?)?.toInt() ?? 0,
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

/// Chat-session lifecycle. Minutes accrue only between `start` and `end`,
/// and only while heartbeats keep arriving.
enum BodhiSessionAction { start, heartbeat, end }

/// Remaining allowance after a session tick.
class BodhiSessionResult {
  const BodhiSessionResult({
    required this.remainingSeconds,
    required this.remainingMessages,
  });

  final int remainingSeconds;
  final int remainingMessages;

  factory BodhiSessionResult.fromMap(Map<String, dynamic> data) {
    return BodhiSessionResult(
      remainingSeconds: (data['remainingSeconds'] as num?)?.toInt() ?? 0,
      remainingMessages: (data['remainingMessages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Client wrapper for the Bodhi AI callables.
///
/// The OpenRouter key, the daily quota, the topic gate and the system prompt
/// all live server-side — this class only carries a question and renders what
/// comes back. It deliberately exposes no way to influence the model, the
/// limits, or the scope rule.
class BodhiAiFunctionsService {
  BodhiAiFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: AppConstants.functionsRegion);

  final FirebaseFunctions _functions;

  /// Longer than the 60 s default: `bodhiChat` makes two sequential model
  /// calls (topic gate, then the answer).
  static const _chatTimeout = Duration(seconds: 90);

  Map<String, dynamic> _payload(String message, List<BodhiChatTurn> history) {
    return {
      'message': message,
      'history': [for (final turn in history) turn.toJson()],
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
  }) async* {
    final callable = _functions.httpsCallable(
      AppConstants.fnBodhiChat,
      options: HttpsCallableOptions(timeout: _chatTimeout),
    );

    // Parsed defensively rather than with a hard cast: this is a network
    // boundary, and a shape change should not throw inside the stream.
    await for (final response in callable.stream<Object?, Object?>(
      _payload(message, history),
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
  }) async {
    final callable = _functions.httpsCallable(
      AppConstants.fnBodhiChat,
      options: HttpsCallableOptions(timeout: _chatTimeout),
    );
    final result = await callable.call<Map<Object?, Object?>>(
      _payload(message, history),
    );
    return BodhiChatResult.fromMap(Map<String, dynamic>.from(result.data));
  }

  /// Open, tick, or close the chat session that drives minute accrual.
  Future<BodhiSessionResult> session(BodhiSessionAction action) async {
    final callable = _functions.httpsCallable(AppConstants.fnBodhiSession);
    final result = await callable.call<Map<Object?, Object?>>({
      'action': action.name,
    });
    return BodhiSessionResult.fromMap(Map<String, dynamic>.from(result.data));
  }
}
