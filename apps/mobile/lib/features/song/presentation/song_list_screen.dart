import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../content/presentation/content_list_scaffold.dart';

/// Songs list (PRD FR-9.1, 9.2) — rows opening the full player (T2.44).
class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Full player screen — T2.44.
          },
        );
      },
    );
  }
}
