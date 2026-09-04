import 'package:core/core.dart';
import 'package:dhamma_path_admin/features/content/application/content_type_config.dart';
import 'package:dhamma_path_admin/features/content/presentation/content_list_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('image rows try thumbUrl then mediaUrl, skipping duplicates', () {
    const item = ContentItem(
      id: 'wp_1',
      type: ContentType.wallpaper,
      title: LocalisedText(en: '2'),
      thumbUrl:
          'https://firebasestorage.googleapis.com/v0/b/x/o/wallpapers%2Fwp_1%2Foriginal.jpeg?alt=media&token=stale',
      mediaUrl:
          'https://firebasestorage.googleapis.com/v0/b/x/o/wallpapers%2Fwp_1%2Foriginal.jpeg?alt=media&token=fresh',
    );

    expect(
      contentRowPreviewUrls(item, ContentMediaKind.image),
      [
        item.thumbUrl,
        item.mediaUrl,
      ],
    );
  });

  test('audio rows only preview a dedicated thumbnail', () {
    const item = ContentItem(
      id: 'sg_1',
      type: ContentType.song,
      title: LocalisedText(en: 'Song'),
      mediaUrl: 'https://example.com/audio.mp3',
      thumbUrl: 'https://example.com/audio.mp3',
    );
    expect(contentRowPreviewUrls(item, ContentMediaKind.audio), isEmpty);

    const withThumb = ContentItem(
      id: 'sg_1',
      type: ContentType.song,
      title: LocalisedText(en: 'Song'),
      mediaUrl: 'https://example.com/audio.mp3',
      thumbUrl: 'https://example.com/cover.webp',
    );
    expect(
      contentRowPreviewUrls(withThumb, ContentMediaKind.audio),
      ['https://example.com/cover.webp'],
    );
  });
}
