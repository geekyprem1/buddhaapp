import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../home/application/home_providers.dart';
import '../../home/presentation/module_catalog.dart';

/// Discover tab — the full grid of feature modules (wallpapers, meditation,
/// ringtones, songs, chanting, calendar, prarthana, status, …). Reuses the
/// same catalogue rendering as Home, without the wisdom hero on top.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final layout =
        ref.watch(homeLayoutProvider).valueOrNull ?? HomeLayout.defaults;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.navExplore ?? 'Discover',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          for (var i = 0; i < layout.sections.length; i++)
            ...moduleSectionSlivers(
              context,
              l10n,
              layout.sections[i],
              first: i == 0,
              last: i == layout.sections.length - 1,
            ),
        ],
      ),
    );
  }
}
