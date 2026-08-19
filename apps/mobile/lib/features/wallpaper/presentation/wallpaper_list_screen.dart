import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../content/application/content_list_controller.dart';
import '../../content/application/teacher_filter_providers.dart';
import '../../content/presentation/content_list_scaffold.dart';
import '../application/wallpaper_gallery.dart';
import 'set_wallpaper_sheet.dart';

/// Wallpapers list (PRD FR-7.1, 7.2) — grid of previews. Tap opens detail;
/// the overlaid Set button opens the Home/Lock/Both sheet.
class WallpaperListScreen extends ConsumerWidget {
  const WallpaperListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.wallpaper,
      collection: FirestoreCollections.wallpapers,
      title: l10n?.homeWallpaper ?? 'Wallpapers',
      gridColumns: 2,
      emptyMessage: 'No wallpapers yet.',
      itemBuilder: (context, item, index) {
        final language = Localizations.localeOf(context).languageCode;
        return ContentCard(
          thumbUrl: item.thumbUrl ?? item.mediaUrl,
          title: item.title.resolve(language),
          aspectRatio: 0.7,
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton(
                onPressed: () {
                  final url = item.mediaUrl ?? item.thumbUrl;
                  if (url == null) return;
                  showSetWallpaperSheet(
                    context: context,
                    ref: ref,
                    imageUrl: url,
                    itemId: item.id,
                  );
                },
                child: Text(l10n?.setWallpaperTitle ?? 'Set wallpaper'),
              ),
            ),
          ),
          onTap: () {
            final teacherId = ref.read(
              contentTeacherFilterProvider(ContentType.wallpaper),
            );
            final items = ref
                    .read(
                      contentListControllerProvider(
                        FirestoreCollections.wallpapers,
                        teacherId,
                      ),
                    )
                    .valueOrNull
                    ?.items ??
                [item];
            context.push(
              AppRoutes.wallpaperDetail,
              extra: WallpaperGallery(items: items, initialIndex: index),
            );
          },
        );
      },
    );
  }
}
