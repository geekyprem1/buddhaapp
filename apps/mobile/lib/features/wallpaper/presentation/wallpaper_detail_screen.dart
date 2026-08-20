import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/wallpaper_gallery.dart';
import '../application/wallpaper_providers.dart';
import 'set_wallpaper_sheet.dart';

/// Full-screen wallpaper viewer — pinch-zoom, swipe, Set / Download / Share
/// (T2.25, T2.26).
class WallpaperDetailScreen extends ConsumerStatefulWidget {
  const WallpaperDetailScreen({required this.gallery, super.key});

  final WallpaperGallery gallery;

  @override
  ConsumerState<WallpaperDetailScreen> createState() =>
      _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends ConsumerState<WallpaperDetailScreen> {
  late final PageController _pages;
  late int _index;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _index = widget.gallery.initialIndex.clamp(
      0,
      widget.gallery.items.length - 1,
    );
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  ContentItem get _item => widget.gallery.items[_index];

  String? get _imageUrl => _item.mediaUrl ?? _item.thumbUrl;

  Future<void> _download() async {
    final url = _imageUrl;
    if (url == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(wallpaperServiceProvider).saveToGallery(url);
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.savedToGallery ?? 'Saved to gallery.')),
      );
      await ref.read(analyticsServiceProvider).wallpaperDownload(id: _item.id);
      unawaited(
        ref
            .read(eventsRepositoryProvider)
            .record(
              collection: ContentCollections.wallpapers,
              itemId: _item.id,
              type: ContentEventType.download,
            )
            .catchError((_) {}),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.wallpaperSetFailed ?? 'Could not save image.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    final url = _imageUrl;
    if (url == null || _busy) return;
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _busy = true);
    try {
      await ref.read(wallpaperServiceProvider).share(
            url: url,
            title: _item.title.resolve(language),
          );
      unawaited(
        ref
            .read(eventsRepositoryProvider)
            .record(
              collection: ContentCollections.wallpapers,
              itemId: _item.id,
              type: ContentEventType.share,
            )
            .catchError((_) {}),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final items = widget.gallery.items;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _item.title.resolve(language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final url = items[i].mediaUrl ?? items[i].thumbUrl;
                if (url == null) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  );
                }
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || _imageUrl == null
                          ? null
                          : () => showSetWallpaperSheet(
                                context: context,
                                ref: ref,
                                imageUrl: _imageUrl!,
                                itemId: _item.id,
                              ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n?.setWallpaperTitle ?? 'Set wallpaper',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: l10n?.download ?? 'Download',
                    onPressed: _busy ? null : _download,
                    icon: const Icon(Icons.download),
                  ),
                  IconButton.filledTonal(
                    tooltip: l10n?.share ?? 'Share',
                    onPressed: _busy ? null : _share,
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
