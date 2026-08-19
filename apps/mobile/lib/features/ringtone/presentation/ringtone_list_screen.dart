import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/audio_list_tile.dart';
import '../../content/presentation/content_list_scaffold.dart';
import '../../player/application/audio_providers.dart';
import 'set_ringtone_sheet.dart';

/// Ringtones list (PRD FR-8.1–8.3). Tap previews inline (T2.39).
/// Set opens the kind sheet and finishes after WRITE_SETTINGS (T2.40).
class RingtoneListScreen extends ConsumerStatefulWidget {
  const RingtoneListScreen({super.key});

  @override
  ConsumerState<RingtoneListScreen> createState() => _RingtoneListScreenState();
}

class _RingtoneListScreenState extends ConsumerState<RingtoneListScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        completePendingRingtoneSet(context: context, ref: ref);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      completePendingRingtoneSet(context: context, ref: ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(currentMediaItemProvider).valueOrNull;
    final playback = ref.watch(audioPlaybackStateProvider).valueOrNull;
    return ContentListScaffold(
      module: ContentType.ringtone,
      collection: FirestoreCollections.ringtones,
      title: l10n?.homeRingtone ?? 'Ringtones',
      emptyMessage: l10n?.ringtoneEmpty ?? 'No ringtones yet.',
      helpAction: TextButton.icon(
        onPressed: () => context.push(AppRoutes.ringtoneHelp),
        icon: const Icon(Icons.play_arrow, size: 18),
        label: Text(l10n?.help ?? 'Help'),
      ),
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        final isThis = current?.id == item.id;
        final playing = isThis && (playback?.playing ?? false);
        final url = item.mediaUrl;
        return AudioListTile(
          item: item,
          language: language,
          isPlaying: playing,
          trailing: FilledButton.tonal(
            onPressed: url == null
                ? null
                : () => showSetRingtoneSheet(
                      context: context,
                      ref: ref,
                      audioUrl: url,
                      itemId: item.id,
                      title: item.title.resolve(language),
                    ),
            child: Text(l10n?.set ?? 'Set'),
          ),
          onTap: () {
            final handler = ref.read(audioHandlerProvider);
            if (playing) {
              handler.pause();
            } else if (isThis) {
              handler.play();
            } else {
              handler.playContent(item, language: language);
            }
          },
        );
      },
    );
  }
}
