import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';

class ChangeLanguageScreen extends ConsumerWidget {
  const ChangeLanguageScreen({super.key});

  static const _options = [
    (code: 'en', name: 'English', native: 'English'),
    (code: 'hi', name: 'Hindi', native: 'हिन्दी'),
    (code: 'mr', name: 'Marathi', native: 'मराठी'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current =
        ref.watch(currentAppUserProvider).valueOrNull?.language ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.profileChangeLanguage ?? 'Change Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          for (final opt in _options)
            Card(
              child: ListTile(
                title: Text(opt.name),
                subtitle: Text(opt.native),
                trailing: current == opt.code
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () async {
                  final uid = ref.read(authStateProvider).valueOrNull?.uid;
                  if (uid == null) return;
                  await ref
                      .read(userRepositoryProvider)
                      .setPreferredLanguage(uid, opt.code);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    );
  }
}
