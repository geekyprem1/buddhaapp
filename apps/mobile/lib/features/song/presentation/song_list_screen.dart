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

/// Songs list (PRD FR-9.1, 9.2) — rows opening the full player (T2.44).
class SongListScreen extends ConsumerWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.song,
      collection: FirestoreCollections.songs,
      title: l10n?.homeSong ?? 'Song',
      emptyMessage: 'No songs yet.',
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        return AudioListTile(
          item: item,
          language: language,
          onTap: () {
            final teacherId = ref.read(
              contentTeacherFilterProvider(ContentType.song),
            );
            final queue = ref
                    .read(
                      contentListControllerProvider(
                        FirestoreCollections.songs,
                        teacherId,
                      ),
                    )
                    .valueOrNull
                    ?.items ??
                [item];
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
