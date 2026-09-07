import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../application/wisdom_providers.dart';

/// Home hero — today's wisdom card. The card artwork already contains its own
/// text (title, verse, translation), so we show the full uncropped image and
/// make the whole thing tappable to open the detail screen. Hides itself while
/// loading or when no card/image is published.
class WisdomHeroCard extends ConsumerWidget {
  const WisdomHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wisdom = ref.watch(todayWisdomProvider);
    if (wisdom == null || wisdom.imageUrl == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(
            AppRoutes.wisdomDetail,
            extra: wisdom.id,
          ),
          child: CachedNetworkImage(
            imageUrl: wisdom.imageUrl!,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorWidget: (context, _, __) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
