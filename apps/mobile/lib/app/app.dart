import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/bodhi_ai/application/bodhi_chat_controller.dart';
import '../features/notifications/application/fcm_coordinator.dart';
import '../features/player/presentation/mini_player.dart';
import '../l10n/generated/app_localizations.dart';
import 'bottom_app_chrome.dart';
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
        // Bottom chrome that persists on EVERY ordinary screen: a Donate &
        // Support banner sitting directly above a fixed navigation bar. Shown
        // once the user is signed in and past the first onboarding steps (the
        // same gate the old floating Daan bubble used), and hidden on the
        // router's gate screens.
        //
        // Rebuilt on every navigation so the active tab highlights correctly
        // and the chrome disappears on gate/immersive routes.
        return ListenableBuilder(
          listenable: router.routerDelegate,
          builder: (context, _) {
            final showChrome = showDaan && BottomAppChrome.isVisibleFor(router);
            return Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const OfflineBanner(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                    if (showChrome)
                      BottomAppChrome(
                        router: router,
                        bodhiAiEnabled: bodhiAiEnabled,
                      ),
                  ],
                ),
                // The mini player floats above the chrome so its controls
                // stay reachable. When the chrome is present it already
                // absorbs the system bottom inset, so strip it from the mini
                // player to avoid an empty double gap.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: showChrome
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: BottomAppChrome.heightOf(context),
                          ),
                          child: MediaQuery.removePadding(
                            context: context,
                            removeBottom: true,
                            child: const MiniPlayer(),
                          ),
                        )
                      : const MiniPlayer(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
