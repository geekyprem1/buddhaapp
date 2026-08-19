import 'package:dhamma_path/platform/wallpaper_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('channel values match the Kotlin plugin contract', () {
    expect(WallpaperTarget.home.channelValue, 'home');
    expect(WallpaperTarget.lock.channelValue, 'lock');
    expect(WallpaperTarget.both.channelValue, 'both');
  });
}
