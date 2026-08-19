import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/application/content_list_controller.dart';
import '../../content/presentation/audio_list_tile.dart';

Future<ContentItem?> showPrarthanaSongPicker(BuildContext context) {
  return AppBottomSheet.show<ContentItem>(
    context: context,
    title: AppLocalizations.of(context)?.prarthanaChooseSong ??
        'Choose prarthana',
    child: const SizedBox(
      height: 360,
      child: _SongPickerList(),
    ),
  );
}

class _SongPickerList extends ConsumerWidget {
  const _SongPickerList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      contentListControllerProvider(FirestoreCollections.prarthanas, null),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          AppLocalizations.of(context)?.prarthanaNoSongs ??
              'Could not load prarthanas.',
        ),
      ),
      data: (page) {
        if (page.items.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)?.prarthanaNoSongs ??
                  'No prarthanas yet.',
            ),
          );
        }
        final language = Localizations.localeOf(context).languageCode;
        return ListView.separated(
          itemCount: page.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final item = page.items[i];
            return AudioListTile(
              item: item,
              language: language,
              onTap: () => Navigator.of(context).pop(item),
            );
          },
        );
      },
    );
  }
}
