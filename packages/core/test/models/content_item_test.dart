import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentItem', () {
    test('JSON round-trip preserves all fields for a wallpaper', () {
      final item = ContentItem(
        id: 'wp_001',
        type: ContentType.wallpaper,
        teacherIds: const ['buddha'],
        categoryId: 'cat_calm',
        title: const LocalisedText(en: 'Golden Buddha', hi: 'स्वर्ण बुद्ध'),
        mediaUrl: 'https://example.com/full.webp',
        thumbUrl: 'https://example.com/thumb.webp',
        status: ContentStatus.published,
        source: 'own-artwork',
        licence: 'original',
        wallpaper: const WallpaperMeta(
          width: 1080,
          height: 1920,
          orientation: 'portrait',
        ),
      );

      final json = item.toJson();
      final decoded = ContentItem.fromJson(json);

      expect(decoded, item);
      expect(decoded.isPublished, isTrue);
      expect(decoded.wallpaper?.kind, 'static');
    });

    test('tolerates missing optional fields (partial admin draft)', () {
      final json = <String, dynamic>{
        'id': 'wp_002',
        'type': ContentType.wallpaper,
        'title': <String, dynamic>{'en': 'Draft'},
      };

      final decoded = ContentItem.fromJson(json);

      expect(decoded.status, ContentStatus.draft);
      expect(decoded.isPublished, isFalse);
      expect(decoded.teacherIds, isEmpty);
      expect(decoded.title.resolve('hi'), 'Draft');
    });

    test('LocalisedText resolves with fallback to English', () {
      const text = LocalisedText(en: 'Hello');
      expect(text.resolve('mr'), 'Hello');
      expect(text.resolve('en'), 'Hello');
    });

    test('statusMeta round-trips normalised layout rects', () {
      final item = ContentItem(
        id: 'st_001',
        type: ContentType.status,
        title: const LocalisedText(en: 'Festival'),
        statusMeta: const StatusMeta(
          photoFrame: LayoutRect(x: 0.6, y: 0.7, w: 0.2, h: 0.2),
          nameText: StatusTextStyle(x: 0.1, y: 0.9),
        ),
      );

      final decoded = ContentItem.fromJson(item.toJson());

      expect(decoded.statusMeta?.photoFrame.x, 0.6);
      expect(decoded.statusMeta?.nameText.y, 0.9);
    });
  });

  group('AppUser', () {
    test('onboarding completion helper', () {
      const incomplete = AppUser(uid: 'u1', onboardingStep: 'teacher');
      const complete = AppUser(uid: 'u1', onboardingStep: 'complete');

      expect(incomplete.hasCompletedOnboarding, isFalse);
      expect(complete.hasCompletedOnboarding, isTrue);
    });
  });
}
