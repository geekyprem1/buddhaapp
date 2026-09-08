import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Buddhist Places — a grid of admin-curated places (thumbnail + title).
/// Tapping opens the detail screen with an image gallery + description.
class PlacesListScreen extends ConsumerWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(activePlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.homeBuddhistPlaces ?? 'Buddhist Places',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(
          message: l10n?.errorLoadFailed ?? 'Could not load content.',
          onRetry: () => ref.invalidate(activePlacesProvider),
        ),
        data: (places) {
          if (places.isEmpty) {
            return EmptyState(
              message: l10n?.placesEmpty ?? 'No places yet.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.82,
            ),
            itemCount: places.length,
            itemBuilder: (context, i) {
              final place = places[i];
              return _PlaceCard(
                place: place,
                onTap: () {
                  AppHaptics.tap();
                  context.push(AppRoutes.placeDetail, extra: place);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onTap});

  final BuddhistPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: place.thumbUrl != null
                  ? CachedNetworkImage(
                      imageUrl: place.thumbUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: AppColors.disabled),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: AppColors.disabled,
                        child: Icon(Icons.image_outlined),
                      ),
                    )
                  : const ColoredBox(
                      color: AppColors.disabled,
                      child: Icon(Icons.place_outlined),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                place.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
