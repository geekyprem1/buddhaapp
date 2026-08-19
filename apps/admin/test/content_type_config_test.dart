import 'package:core/core.dart';
import 'package:dhamma_path_admin/features/content/application/content_type_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry covers the six launch content types', () {
    expect(contentTypeConfigs, hasLength(6));
    expect(
      contentTypeConfigs.map((c) => c.type).toSet(),
      {
        ContentType.wallpaper,
        ContentType.ringtone,
        ContentType.song,
        ContentType.meditation,
        ContentType.status,
        ContentType.prarthana,
      },
    );
  });

  test('wallpapers stay static-only; songs expose lyrics', () {
    final wallpapers = configForType(ContentType.wallpaper);
    expect(wallpapers.hasWallpaperMeta, isTrue);
    expect(wallpapers.media, ContentMediaKind.image);

    final songs = configForType(ContentType.song);
    expect(songs.hasLyrics, isTrue);
    expect(songs.hasAlbum, isTrue);
  });
}
