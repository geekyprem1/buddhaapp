import 'package:dhamma_path/features/player/application/sleep_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presets match FR-10.4', () {
    expect(SleepTimerPresets.minutes, [5, 10, 15, 30, 60]);
  });

  test('start then cancel does not fire', () {
    var fired = 0;
    final timer = SleepTimer(onElapsed: () => fired++);
    timer.start(const Duration(minutes: 5));
    expect(timer.isActive, isTrue);
    expect(timer.chosen, const Duration(minutes: 5));
    timer.cancel();
    expect(timer.isActive, isFalse);
    expect(timer.remaining, isNull);
    expect(fired, 0);
    timer.dispose();
  });

  test('remaining follows the injected clock', () {
    var now = DateTime(2026, 1, 1, 12);
    final timer = SleepTimer(onElapsed: () {}, clock: () => now);
    timer.start(const Duration(minutes: 15));
    expect(timer.remaining, const Duration(minutes: 15));
    now = now.add(const Duration(minutes: 4));
    expect(timer.remaining, const Duration(minutes: 11));
    timer.cancel();
    timer.dispose();
  });
}
