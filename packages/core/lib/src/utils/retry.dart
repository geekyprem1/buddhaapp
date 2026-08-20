import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/// Transient network / backend codes that are worth retrying (T2.5).
///
/// Permanent failures (`permission-denied`, `not-found`, `invalid-argument`,
/// `unauthenticated`, `failed-precondition`) are **not** retried — they
/// would just delay the error the user already needs to see.
bool isRetryableError(Object error) {
  if (error is TimeoutException) return true;
  if (error is FirebaseException) {
    return const {
      'unavailable',
      'deadline-exceeded',
      'resource-exhausted',
      'aborted',
    }.contains(error.code);
  }
  final text = error.toString();
  return text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('ClientException') ||
      text.contains('HttpException') ||
      text.contains('Connection closed') ||
      text.contains('Network is unreachable') ||
      text.contains('Connection timed out');
}

/// Runs [action] up to [maxAttempts] times with exponential backoff.
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 250),
}) async {
  assert(maxAttempts >= 1, 'maxAttempts must be at least 1');
  var delay = initialDelay;
  Object? lastError;
  StackTrace? lastStack;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (error, stack) {
      lastError = error;
      lastStack = stack;
      if (attempt == maxAttempts || !isRetryableError(error)) {
        rethrow;
      }
      await Future<void>.delayed(delay);
      delay *= 2;
    }
  }
  Error.throwWithStackTrace(lastError!, lastStack!);
}
