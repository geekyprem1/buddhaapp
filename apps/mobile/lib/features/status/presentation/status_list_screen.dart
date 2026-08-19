import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../content/presentation/content_list_scaffold.dart';
import 'status_card.dart';

class StatusListScreen extends ConsumerWidget {
  const StatusListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ContentListScaffold(
      module: ContentType.status,
      collection: FirestoreCollections.statuses,
      title: l10n?.homeTrendingStatus ?? 'Trending Status',
      emptyMessage: l10n?.statusEmpty ?? 'No statuses yet.',
      itemBuilder: (context, item, index) => StatusCard(item: item),
    );
  }
}
