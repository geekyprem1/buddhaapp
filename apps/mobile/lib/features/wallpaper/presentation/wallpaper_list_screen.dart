import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/content_list_scaffold.dart';

/// Wallpapers list (PRD FR-7.1, 7.2) — a grid of previews. Tapping opens the
/// detail/set flow (native set-wallpaper lands in T2.23–T2.26); for now the
/// screen validates the content pipeline against seeded wallpapers.
class WallpaperListScreen extends StatelessWidget {
  const WallpaperListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.wallpaper,
      collection: FirestoreCollections.wallpapers,
      title: l10n?.homeWallpaper ?? 'Wallpapers',
      gridColumns: 2,
      emptyMessage: 'No wallpapers yet.',
      itemBuilder: (context, item, index) {
        final language =
            Localizations.localeOf(context).languageCode;
        return ContentCard(
          thumbUrl: item.thumbUrl ?? item.mediaUrl,
          title: item.title.resolve(language),
          aspectRatio: 0.7,
          onTap: () {
            // Wallpaper detail + Set flow — T2.25/T2.26.
          },
        );
      },
    );
  }
}
