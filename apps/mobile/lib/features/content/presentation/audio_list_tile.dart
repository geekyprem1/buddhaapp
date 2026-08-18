import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A row for audio content (ringtone / song / meditation): square thumbnail
/// with a play overlay, title, and `artist • duration` subtitle, plus an
/// optional trailing action (e.g. the ringtone "Set" button). Playback and
/// the Set action are wired in later tasks (T2.34, T2.37) — this renders the
/// row and reports taps.
class AudioListTile extends StatelessWidget {
  const AudioListTile({
    required this.item,
    required this.language,
    this.trailing,
    this.onTap,
    super.key,
  });

  final ContentItem item;
  final String language;
  final Widget? trailing;
  final VoidCallback? onTap;

  String get _subtitle {
    final artist = (item.artist == null || item.artist!.trim().isEmpty)
        ? 'Anonymous'
        : item.artist!;
    final secs = item.audio?.durationSec;
    if (secs == null) return artist;
    final m = secs ~/ 60;
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$artist • $m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final title = item.title.resolve(language);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item.thumbUrl != null)
                  CachedNetworkImage(
                    imageUrl: item.thumbUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const ColoredBox(color: AppColors.disabled),
                  )
                else
                  const ColoredBox(color: AppColors.disabled),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          _subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
