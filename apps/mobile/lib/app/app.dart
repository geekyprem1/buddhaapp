import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bodhi_ai/application/bodhi_chat_controller.dart';
import '../features/notifications/application/fcm_coordinator.dart';
import '../features/player/presentation/mini_player.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_chrome_layout.dart';
import 'offline_banner.dart';
import 'router.dart';
import 'theme_controller.dart';

/// Root widget for Dhamma Path. Wraps the app in the shared theme,
/// localisation delegates (Architecture §12) and the go_router-based auth
/// gate (Architecture §9.1).
class DhammaPathApp extends ConsumerWidget {
  const DhammaPathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fcmCoordinatorProvider);
    final router = ref.watch(appRouterProvider);
    final appUser = ref.watch(currentAppUserProvider).valueOrNull;
    final language = appUser?.language;
    final onboardingStep = appUser?.onboardingStep;
    final showDaan = appUser != null &&
        onboardingStep != AppConstants.onboardingStepLanguage &&
        onboardingStep != AppConstants.onboardingStepPersonInfo;
    final themeMode = ref.watch(themeModeControllerProvider);
    // Drives whether the Ask Buddha tab is shown (BA-1.3). Defaults to hidden
    // until the config stream resolves with enabled: true.
    final bodhiAiEnabled =
        ref.watch(bodhiAiConfigProvider).valueOrNull?.enabled ?? false;
    return MaterialApp.router(
      title: 'Dhamma Path',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: language == null ? null : Locale(language),
      scaffoldMessengerKey: rootMessengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        // Home keeps the full donation banner and tab bar. Other ordinary
        // screens replace both with one compact Daan / Ask Buddha action row.
        // Gate and immersive routes keep all bottom chrome hidden.
        //
        return AppChromeLayout(
          router: router,
          body: child ?? const SizedBox.shrink(),
          topBanner: const OfflineBanner(),
          miniPlayer: const MiniPlayer(),
          chromeEnabled: showDaan,
          bodhiAiEnabled: bodhiAiEnabled,
        );
      },
    );
  }
}
