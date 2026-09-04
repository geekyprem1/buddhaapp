import 'package:dhamma_path/features/player/application/player_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slider is disabled at zero duration', () {
    expect(sliderValue(const Duration(seconds: 1), Duration.zero), 0);
    expect(
      sliderValue(const Duration(seconds: 30), const Duration(seconds: 60)),
      0.5,
    );
  });

  test('resolveDuration prefers a positive media duration, then player', () {
    expect(resolveDuration(null, null), Duration.zero);
    expect(
      resolveDuration(Duration.zero, const Duration(seconds: 12)),
      const Duration(seconds: 12),
    );
    expect(
      resolveDuration(const Duration(seconds: 90), const Duration(seconds: 12)),
      const Duration(seconds: 90),
    );
  });

  test('formatPlayerTime pads mm:ss and includes hours when needed', () {
    expect(formatPlayerTime(Duration.zero), '00:00');
    expect(formatPlayerTime(const Duration(seconds: 5)), '00:05');
    expect(formatPlayerTime(const Duration(minutes: 3, seconds: 7)), '03:07');
    expect(formatPlayerTime(const Duration(hours: 1, minutes: 2)), '1:02:00');
  });
}
