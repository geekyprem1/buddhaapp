import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../content/application/content_list_controller.dart';
import '../../content/application/teacher_filter_providers.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../content/presentation/content_list_scaffold.dart';
import '../../player/application/audio_providers.dart';
import '../application/meditation_series.dart';

/// Meditation list (PRD FR-10.1, 10.2). Opens the shared player, which
/// shows the sleep timer for meditation items (T2.49).
class MeditationListScreen extends ConsumerWidget {
  const MeditationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.meditation,
      collection: FirestoreCollections.meditations,
      title: l10n?.homeMeditation ?? 'Meditation',
      emptyMessage: 'No meditations yet.',
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        return AudioListTile(
          item: item,
          language: language,
          onTap: () {
            final teacherId = ref.read(
              contentTeacherFilterProvider(ContentType.meditation),
            );
            final loaded = ref
                    .read(
                      contentListControllerProvider(
                        FirestoreCollections.meditations,
                        teacherId,
                      ),
                    )
                    .valueOrNull
                    ?.items ??
                [item];
            // A series plays its parts in order; a standalone meditation
            // queues the whole list (FR-10.3, T2.48).
            final queue = meditationPlayQueue(item, loaded);
            ref.read(audioHandlerProvider).playContent(
                  item,
                  queue: queue,
                  language: language,
                );
            context.push(AppRoutes.player);
          },
        );
      },
    );
  }
}
