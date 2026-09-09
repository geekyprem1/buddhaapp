import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/application/category_filter_providers.dart';
import '../../content/application/content_list_controller.dart';
import '../../premium/application/premium_guard.dart';
import '../application/wallpaper_providers.dart';
import 'set_wallpaper_sheet.dart';

/// Wallpapers — full-screen vertical "reel". One wallpaper fills the screen;
/// swipe up/down for the next/previous. A category chip row sits at the top,
/// and the only per-image action is "Set wallpaper". Pages load on demand from
/// the paginated content controller as the user nears the end (FR-7.1, 7.2).
class WallpaperListScreen extends ConsumerStatefulWidget {
  const WallpaperListScreen({super.key});

  @override
  ConsumerState<WallpaperListScreen> createState() =>
      _WallpaperListScreenState();
}

class _WallpaperListScreenState extends ConsumerState<WallpaperListScreen> {
  final _pages = PageController();

  // No teacher filtering in the reel; category comes from the chip row.
  static const _teacherId = null;

  ContentListControllerProvider _providerFor(String? categoryId) =>
      contentListControllerProvider(
        FirestoreCollections.wallpapers,
        _teacherId,
        categoryId: categoryId,
      );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, PagedContent paged, String? categoryId) {
    AppHaptics.selection(); // premium tick as each wallpaper snaps into view
    // Prefetch the next page as the user approaches the end of the list.
    if (index >= paged.items.length - 2 &&
        paged.hasMore &&
        !paged.isLoadingMore) {
      ref.read(_providerFor(categoryId).notifier).loadMore();
    }
  }

  Future<void> _setLive(String itemId, String videoUrl) async {
    if (!ensurePremium(ref, context)) return;
    AppHaptics.impact();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n?.setWallpaperLivePreparing ?? 'Preparing…'),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      await ref.read(wallpaperServiceProvider).setLiveWallpaper(videoUrl);
    } catch (e, st) {
      await ErrorReporter.instance.record(e, st, reason: 'wallpaper.setLive');
      AppHaptics.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.wallpaperSetFailed ?? 'Could not set wallpaper.',
          ),
        ),
      );
    }
  }

  void _selectCategory(String? categoryId) {
    AppHaptics.tap();
    ref
        .read(contentCategoryFilterProvider(ContentType.wallpaper).notifier)
        .select(categoryId);
    // New filtered list — jump back to the top.
    if (_pages.hasClients) _pages.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryId =
        ref.watch(contentCategoryFilterProvider(ContentType.wallpaper));
    final categoryChips =
        ref.watch(moduleCategoryChipsProvider(ContentType.wallpaper));
    final async = ref.watch(_providerFor(categoryId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (_, __) => Center(
                child: Text(
                  l10n?.errorLoadFailed ?? 'Could not load content.',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n?.homeWallpaper ?? 'No wallpapers yet.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return PageView.builder(
                  controller: _pages,
                  scrollDirection: Axis.vertical,
                  itemCount: paged.items.length,
                  onPageChanged: (i) => _onPageChanged(i, paged, categoryId),
                  itemBuilder: (context, i) {
                    final item = paged.items[i];
                    final isLive = item.wallpaper?.kind == 'live';
                    final videoUrl = item.wallpaper?.videoUrl;
                    final posterUrl = item.mediaUrl ?? item.thumbUrl;

                    if (isLive && videoUrl != null) {
                      return _LiveWallpaperPage(
                        videoUrl: videoUrl,
                        posterUrl: posterUrl,
                        onSet: () => _setLive(item.id, videoUrl),
                        setLabel: l10n?.setWallpaperLive ?? 'Set live wallpaper',
                      );
                    }

                    return _WallpaperPage(
                      imageUrl: posterUrl,
                      onSet: posterUrl == null
                          ? null
                          : () {
                              if (!ensurePremium(ref, context)) return;
                              showSetWallpaperSheet(
                                context: context,
                                ref: ref,
                                imageUrl: posterUrl,
                                itemId: item.id,
                              );
                            },
                      setLabel: l10n?.setWallpaperTitle ?? 'Set wallpaper',
                    );
                  },
                );
              },
            ),
          ),
          // Top chrome: back button + category chips over a soft scrim.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              categories: categoryChips,
              selectedCategoryId: categoryId,
              onSelect: _selectCategory,
              onBack: () => context.pop(),
              allLabel: l10n?.filterAll ?? 'All',
            ),
          ),
        ],
      ),
    );
  }
}

/// Back button + horizontal category chips, styled for a dark full-screen
/// backdrop, over a top gradient scrim.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
    required this.onBack,
    required this.allLabel,
  });

  final List<TeacherChipData> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelect;
  final VoidCallback onBack;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Row(
            children: [
              const SizedBox(width: 4),
              _CircleIconButton(icon: Icons.arrow_back, onPressed: onBack),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _DarkChip(
                        label: allLabel,
                        selected: selectedCategoryId == null,
                        onTap: () => onSelect(null),
                      ),
                      for (final c in categories) ...[
                        const SizedBox(width: 8),
                        _DarkChip(
                          label: c.label,
                          selected: selectedCategoryId == c.id,
                          onTap: () => onSelect(c.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.black.withValues(alpha: 0.35),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? Colors.white : Colors.white54,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-bleed LIVE wallpaper page: loops the video (muted), showing the
/// poster image until the first frame is ready, with a "Set live wallpaper"
/// button and a LIVE badge.
class _LiveWallpaperPage extends StatefulWidget {
  const _LiveWallpaperPage({
    required this.videoUrl,
    required this.posterUrl,
    required this.onSet,
    required this.setLabel,
  });

  final String videoUrl;
  final String? posterUrl;
  final VoidCallback onSet;
  final String setLabel;

  @override
  State<_LiveWallpaperPage> createState() => _LiveWallpaperPageState();
}

class _LiveWallpaperPageState extends State<_LiveWallpaperPage> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller = c;
    c.initialize().then((_) {
      if (!mounted) return;
      c
        ..setVolume(0)
        ..setLooping(true)
        ..play();
      setState(() => _ready = true);
    }).catchError((_) {
      // Leave the poster showing if the video can't load.
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Poster underneath until the video is ready.
        if (widget.posterUrl != null)
          CachedNetworkImage(
            imageUrl: widget.posterUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) =>
                const ColoredBox(color: Colors.black),
          )
        else
          const ColoredBox(color: Colors.black),
        if (_ready && controller != null)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onSet,
                  icon: const Icon(Icons.bolt),
                  label: Text(widget.setLabel),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One full-bleed wallpaper page with the Set button pinned to the bottom.
class _WallpaperPage extends StatelessWidget {
  const _WallpaperPage({
    required this.imageUrl,
    required this.onSet,
    required this.setLabel,
  });

  final String? imageUrl;
  final VoidCallback? onSet;
  final String setLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white54),
            ),
          )
        else
          const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white54),
          ),
        // Bottom scrim so the button stays legible over bright images.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSet,
                  icon: const Icon(Icons.wallpaper),
                  label: Text(setLabel),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
