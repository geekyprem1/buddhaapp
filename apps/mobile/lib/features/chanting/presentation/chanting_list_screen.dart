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

class ChantingListScreen extends ConsumerWidget {
  const ChantingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.chanting,
      collection: FirestoreCollections.chantings,
      title: l10n?.homeChanting ?? 'Chanting',
      emptyMessage: l10n?.chantingEmpty ?? 'No chants yet.',
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        return AudioListTile(
          item: item,
          language: language,
          onTap: () {
            final teacherId = ref.read(
              contentTeacherFilterProvider(ContentType.chanting),
            );
            final queue = ref
                    .read(
                      contentListControllerProvider(
                        FirestoreCollections.chantings,
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
