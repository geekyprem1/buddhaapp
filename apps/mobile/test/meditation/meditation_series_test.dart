import 'package:core/core.dart';
import 'package:dhamma_path/features/meditation/application/meditation_series.dart';
import 'package:flutter_test/flutter_test.dart';

ContentItem _item(
  String id, {
  String? seriesId,
  int? part,
}) {
  return ContentItem(
    id: id,
    type: ContentType.meditation,
    title: const LocalisedText(en: 'x'),
    status: 'published',
    audio: AudioMeta(seriesId: seriesId, partNumber: part),
  );
}

void main() {
  group('meditationPlayQueue', () {
    test('standalone meditation queues the whole loaded list', () {
      final all = [_item('a'), _item('b'), _item('c')];
      final queue = meditationPlayQueue(all[1], all);
      expect(queue.map((e) => e.id), ['a', 'b', 'c']);
    });

    test('series item queues only its parts, ordered by partNumber', () {
      final all = [
        _item('s2', seriesId: 'anapana', part: 2),
        _item('solo'),
        _item('s1', seriesId: 'anapana', part: 1),
        _item('s3', seriesId: 'anapana', part: 3),
        _item('other', seriesId: 'metta', part: 1),
      ];
      final queue = meditationPlayQueue(all[0], all);
      expect(queue.map((e) => e.id), ['s1', 's2', 's3']);
    });

    test('empty loaded list falls back to the tapped item', () {
      final tapped = _item('a');
      expect(meditationPlayQueue(tapped, const []), [tapped]);
    });

    test('tapped series item missing from the page is prepended', () {
      final tapped = _item('s1', seriesId: 'anapana', part: 1);
      final loaded = [_item('s2', seriesId: 'anapana', part: 2)];
      final queue = meditationPlayQueue(tapped, loaded);
      expect(queue.map((e) => e.id), ['s1', 's2']);
    });
  });
}
