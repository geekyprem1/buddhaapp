import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'loading_shimmer.dart';

/// A generic thumbnail card used by wallpaper/ringtone/song/meditation/status
/// lists. Specific screens compose this with their own overlay (a Set
/// button, a play icon, a Live badge slot etc.) via [trailing]/[overlay].
class ContentCard extends StatelessWidget {
  const ContentCard({
    required this.thumbUrl,
    required this.title,
    this.subtitle,
    this.overlay,
    this.onTap,
    this.aspectRatio = 1.0,
    this.badge,
    super.key,
  });

  final String? thumbUrl;
  final String title;
  final String? subtitle;

  /// Positioned on top of the thumbnail, e.g. a play icon or a Set button.
  final Widget? overlay;

  /// Small badge in the top-left corner — reserved for the Phase 2 "Live"
  /// badge (PRD FR-7.3) and kept inert until then.
  final Widget? badge;
  final VoidCallback? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: subtitle == null ? title : '$title, $subtitle',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbUrl != null)
                      CachedNetworkImage(
                        imageUrl: thumbUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const LoadingShimmer(),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: AppColors.disabled,
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      )
                    else
                      const ColoredBox(color: AppColors.disabled),
                    if (badge != null)
                      Positioned(top: 8, left: 8, child: badge!),
                    if (overlay != null)
                      Positioned.fill(child: overlay!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
