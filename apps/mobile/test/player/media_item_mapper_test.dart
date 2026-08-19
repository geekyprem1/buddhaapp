import 'package:core/core.dart';
import 'package:dhamma_path/features/player/application/media_item_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps title, anonymous artist and duration', () {
    const item = ContentItem(
      id: 'sg_001',
      type: ContentType.song,
      title: LocalisedText(en: 'Jayamangal Sutta', hi: 'जयमंगल'),
      mediaUrl: 'https://example.com/a.mp3',
      thumbUrl: 'https://example.com/a.jpg',
      audio: AudioMeta(durationSec: 180),
    );

    final media = mediaItemFromContent(item, language: 'hi');

    expect(media.id, 'sg_001');
    expect(media.title, 'जयमंगल');
    expect(media.artist, 'Anonymous');
    expect(media.duration, const Duration(seconds: 180));
    expect(mediaUrlOf(media), 'https://example.com/a.mp3');
    expect(contentTypeOf(media), ContentType.song);
    expect(isMeditationMedia(media), isFalse);
  });

  test('meditation extras expose type for the sleep-timer affordance', () {
    const item = ContentItem(
      id: 'md_001',
      type: ContentType.meditation,
      title: LocalisedText(en: 'Anapana'),
      mediaUrl: 'https://example.com/m.mp3',
    );
    final media = mediaItemFromContent(item);
    expect(isMeditationMedia(media), isTrue);
  });
}
