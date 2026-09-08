import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// One Buddhist place — an image gallery (swipe) followed by the title and
/// description. Images and text come from the admin.
class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({required this.place, super.key});

  final BuddhistPlace place;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    // Prefer the gallery; fall back to the thumbnail so there's always a hero.
    final images = place.imageUrls.isNotEmpty
        ? place.imageUrls
        : (place.thumbUrl != null ? [place.thumbUrl!] : const <String>[]);

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        children: [
          if (images.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pages,
                    itemCount: images.length,
                    onPageChanged: (i) {
                      AppHaptics.selection();
                      setState(() => _index = i);
                    },
                    itemBuilder: (context, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: AppColors.disabled),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.disabled,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < images.length; i++)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _index
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (place.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    place.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
