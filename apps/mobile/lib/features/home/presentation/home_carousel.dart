import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../wisdom/application/wisdom_providers.dart';
import 'module_catalog.dart';

/// One horizontal, auto-advancing carousel shown at the top of Home.
///
/// The first slide is the Today's Wisdom card (tapping it opens the wisdom
/// detail, exactly as before). Any active [HomeBanner]s the admin has added
/// follow it (capped at 4) — tapping a banner opens its chosen module using
/// the same routing the home grid uses.
///
/// Hides itself entirely while loading or when there is nothing to show, so
/// Home looks unchanged when no wisdom/banners exist.
class HomeCarousel extends ConsumerStatefulWidget {
  const HomeCarousel({super.key});

  /// Slides share the wisdom card's shape so the row stays uniform.
  static const _aspectRatio = 16 / 9;
  static const _maxBanners = 4;
  static const _autoAdvance = Duration(seconds: 4);

  @override
  ConsumerState<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends ConsumerState<HomeCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;
  int _slideCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartAutoAdvance(int slideCount) {
    _timer?.cancel();
    _slideCount = slideCount;
    if (slideCount <= 1) return;
    _timer = Timer.periodic(HomeCarousel._autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % _slideCount;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _openBanner(HomeBanner banner, AppLocalizations? l10n) {
    final id = banner.moduleId;
    if (id.isEmpty || !HomeModuleIds.isKnown(id)) return;
    AppHaptics.tap();
    openModule(context, l10n, id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wisdom = ref.watch(todayWisdomProvider);
    final banners = (ref.watch(activeHomeBannersProvider).valueOrNull ??
            const <HomeBanner>[])
        .where((b) => b.imageUrl != null && b.imageUrl!.isNotEmpty)
        .take(HomeCarousel._maxBanners)
        .toList();

    // Build the ordered slide list: wisdom first (if any), then banners.
    final slides = <Widget>[
      if (wisdom != null && wisdom.imageUrl != null)
        _CarouselImage(
          imageUrl: wisdom.imageUrl!,
          onTap: () {
            AppHaptics.tap();
            context.push(AppRoutes.wisdomDetail, extra: wisdom.id);
          },
        ),
      for (final banner in banners)
        _CarouselImage(
          imageUrl: banner.imageUrl!,
          onTap: () => _openBanner(banner, l10n),
        ),
    ];

    if (slides.isEmpty) return const SizedBox.shrink();

    // Keep the auto-advance timer in sync with the number of slides.
    if (slides.length != _slideCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restartAutoAdvance(slides.length);
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: HomeCarousel._aspectRatio,
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => slides[i],
            ),
          ),
          if (slides.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            _Dots(count: slides.length, active: _page),
          ],
        ],
      ),
    );
  }
}

/// A single rounded card image used for both the wisdom and banner slides.
class _CarouselImage extends StatelessWidget {
  const _CarouselImage({required this.imageUrl, required this.onTap});

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (context, _, __) => const ColoredBox(
            color: Colors.black12,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      ),
    );
  }
}

/// Small page-indicator dots below the carousel.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
