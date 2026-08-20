import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notifications/application/fcm_coordinator.dart';
import '../features/player/presentation/mini_player.dart';
import '../l10n/generated/app_localizations.dart';
import 'offline_banner.dart';
import 'router.dart';

/// Root widget for Dhamma Path. Wraps the app in the shared theme,
/// localisation delegates (Architecture §12) and the go_router-based auth
/// gate (Architecture §9.1).
class DhammaPathApp extends ConsumerWidget {
  const DhammaPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fcmCoordinatorProvider);
    final router = ref.watch(appRouterProvider);
    final language = ref.watch(currentAppUserProvider).valueOrNull?.language;
    return MaterialApp.router(
      title: 'Dhamma Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: language == null ? null : Locale(language),
      scaffoldMessengerKey: rootMessengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return Column(
          children: [
            const OfflineBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
            const MiniPlayer(),
          ],
        );
      },
    );
  }
}
