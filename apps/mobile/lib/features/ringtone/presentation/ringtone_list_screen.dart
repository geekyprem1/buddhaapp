import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../content/presentation/content_list_scaffold.dart';

/// Ringtones list (PRD FR-8.1–8.3) — rows with a play preview and a "Set"
/// button. Inline preview (T2.39) and the native set flow (T2.37, T2.40)
/// land later; this validates the pipeline against seeded ringtones.
class RingtoneListScreen extends StatelessWidget {
  const RingtoneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.ringtone,
      collection: FirestoreCollections.ringtones,
      title: l10n?.homeRingtone ?? 'Ringtones',
      emptyMessage: 'No ringtones yet.',
      helpAction: TextButton.icon(
        onPressed: () {
          // "▶ Help" WRITE_SETTINGS explainer — T2.41.
        },
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Help'),
      ),
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        return AudioListTile(
          item: item,
          language: language,
          trailing: FilledButton.tonal(
            onPressed: () {
              // Set as ringtone/alarm/notification sheet — T2.40.
            },
            child: const Text('Set'),
          ),
          onTap: () {
            // Inline preview playback — T2.39.
          },
        );
      },
    );
  }
}
