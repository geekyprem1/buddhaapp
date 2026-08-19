import 'package:core/core.dart';

/// Payload for the wallpaper detail route — the current filtered list plus
/// the index the user tapped, so swipe can move between items.
class WallpaperGallery {
  const WallpaperGallery({
    required this.items,
    required this.initialIndex,
  });

  final List<ContentItem> items;
  final int initialIndex;
}
