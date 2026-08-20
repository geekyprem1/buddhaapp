import 'package:firebase_core/firebase_core.dart';

import '../services/error_reporter.dart';
import 'retry.dart';

/// Shared retry + Crashlytics reporting for repository I/O (T2.5, T2.73).
///
/// Reads retry transient failures. Writes are reported but not retried, so
/// a timeout cannot double-create a document.
mixin RepoGuard {
  Future<T> guardedRead<T>(String op, Future<T> Function() action) {
    return _guard(op, action, retry: true);
  }

  Future<T> guardedWrite<T>(String op, Future<T> Function() action) {
    return _guard(op, action, retry: false);
  }

  Stream<T> guardedStream<T>(String op, Stream<T> stream) {
    return stream.handleError((Object error, StackTrace stack) {
      ErrorReporter.instance.record(
        error,
        stack,
        reason: _reason(op, error),
      );
    });
  }

  Future<T> _guard<T>(
    String op,
    Future<T> Function() action, {
    required bool retry,
  }) async {
    try {
      return retry ? await retryWithBackoff(action) : await action();
    } catch (error, stack) {
      await ErrorReporter.instance.record(
        error,
        stack,
        reason: _reason(op, error),
      );
      rethrow;
    }
  }

  String _reason(String op, Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return '$op:permission-denied';
    }
    return op;
  }
}
