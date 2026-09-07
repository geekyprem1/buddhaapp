import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/wisdom_providers.dart';

/// One wisdom card's detail page — banner image, title and the admin's
/// text. Text only, no audio.
class WisdomDetailScreen extends ConsumerWidget {
  const WisdomDetailScreen({required this.wisdomId, super.key});

  final String wisdomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wisdomByIdProvider(wisdomId));
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          async.valueOrNull?.title.resolve(language) ??
              l10n?.todayWisdom ??
              "Today's Wisdom",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(
          message: l10n?.errorLoadFailed ?? 'Could not load content.',
          onRetry: () => ref.invalidate(wisdomByIdProvider(wisdomId)),
        ),
        data: (wisdom) {
          if (wisdom == null) {
            return const EmptyState(
              message: 'This wisdom is not available yet.',
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wisdom.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: wisdom.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorWidget: (context, _, __) => const SizedBox(height: 72),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wisdom.title.resolve(language),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        wisdom.body.resolve(language),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
