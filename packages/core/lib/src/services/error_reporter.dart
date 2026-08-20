/// Typed crash / non-fatal sink (T2.73).
///
/// Default is a no-op so unit tests and the admin panel do not need
/// Crashlytics. The mobile app replaces [ErrorReporter.instance] at
/// bootstrap with a sink that forwards to `FirebaseCrashlytics.recordError`.
class ErrorReporter {
  ErrorReporter({ErrorSink? sink}) : _sink = sink ?? _noop;

  /// Process-wide reporter. Repositories call this so they do not need a
  /// Crashlytics dependency (Architecture §2 — core stays Firebase-SDK-thin
  /// on observability).
  static ErrorReporter instance = ErrorReporter();

  final ErrorSink _sink;

  Future<void> record(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) {
    return _sink(error, stack, fatal: fatal, reason: reason);
  }
}

typedef ErrorSink = Future<void> Function(
  Object error,
  StackTrace stack, {
  required bool fatal,
  String? reason,
});

Future<void> _noop(
  Object error,
  StackTrace stack, {
  required bool fatal,
  String? reason,
}) async {}
