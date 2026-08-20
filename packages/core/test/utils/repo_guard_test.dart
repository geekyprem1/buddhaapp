import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingReporter reporter;

  setUp(() {
    reporter = _RecordingReporter();
    ErrorReporter.instance = ErrorReporter(sink: reporter.sink);
  });

  tearDown(() {
    ErrorReporter.instance = ErrorReporter();
  });

  test('guardedRead reports and rethrows permission-denied', () async {
    final repo = _SampleRepo();
    await expectLater(
      () => repo.readDenied(),
      throwsA(isA<FirebaseException>()),
    );
    expect(reporter.reasons, ['sample.read:permission-denied']);
  });

  test('guardedWrite reports without retrying', () async {
    final repo = _SampleRepo();
    await expectLater(() => repo.writeFail(), throwsA(isA<StateError>()));
    expect(reporter.reasons, ['sample.write']);
  });
}

class _SampleRepo with RepoGuard {
  Future<void> readDenied() {
    return guardedRead(
      'sample.read',
      () async => throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      ),
    );
  }

  Future<void> writeFail() {
    return guardedWrite(
      'sample.write',
      () async => throw StateError('nope'),
    );
  }
}

class _RecordingReporter {
  final reasons = <String?>[];

  Future<void> sink(
    Object error,
    StackTrace stack, {
    required bool fatal,
    String? reason,
  }) async {
    reasons.add(reason);
  }
}
