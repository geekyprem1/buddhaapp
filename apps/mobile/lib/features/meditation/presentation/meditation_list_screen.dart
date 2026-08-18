import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../content/presentation/content_list_scaffold.dart';

/// Meditation list (PRD FR-10.1, 10.2) — rows with narrator + multi-part
/// series. Series grouping and the sleep-timer player land in T2.48/T2.49.
class MeditationListScreen extends StatelessWidget {
  const MeditationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Meditation player with sleep timer — T2.49.
          },
        );
      },
    );
  }
}
