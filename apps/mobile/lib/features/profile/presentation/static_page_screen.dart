import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/profile_providers.dart';

class StaticPageScreen extends ConsumerWidget {
  const StaticPageScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(staticPageProvider(slug));
    final language = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          page.valueOrNull?.title.resolve(language) ?? slug,
        ),
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const ErrorState(message: 'Could not load this page.'),
        data: (doc) {
          if (doc == null) {
            return const EmptyState(message: 'This page is not available yet.');
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SimpleHtmlText(
              html: doc.body.resolve(language),
              onLinkTap: (href) {
                final uri = Uri.tryParse(href);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
