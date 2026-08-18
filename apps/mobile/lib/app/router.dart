import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/meditation/presentation/meditation_list_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/person_info_screen.dart';
import '../features/onboarding/presentation/teacher_select_screen.dart';
import '../features/ringtone/presentation/ringtone_list_screen.dart';
import '../features/song/presentation/song_list_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/wallpaper/presentation/wallpaper_list_screen.dart';

part 'router.g.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const onboardingLanguage = '/onboarding/language';
  static const onboardingPersonInfo = '/onboarding/person-info';
  static const onboardingTeacher = '/onboarding/teacher';
  static const home = '/home';
  static const wallpapers = '/wallpapers';
  static const ringtones = '/ringtones';
  static const songs = '/songs';
  static const meditations = '/meditations';
}

/// Single-place auth/onboarding gate (Architecture §9.1, PRD D2 — login is
/// mandatory, there is no guest browsing path). Every screen relies on this
/// redirect instead of checking auth itself.
@riverpod
GoRouter appRouter(Ref ref) {
  // Router needs to re-run its redirect whenever auth state OR the user's
  // Firestore profile (onboardingStep) changes — go_router only re-checks
  // redirects on navigation or when `refreshListenable` notifies.
  final refresh = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, __) => refresh.ping());
  ref.listen(currentAppUserProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authValue = ref.read(authStateProvider);
      final path = state.matchedLocation;

      // While auth state is loading, only the splash screen is allowed —
      // it owns the bootstrap sequence (FR-1.2).
      if (authValue.isLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authValue.valueOrNull;
      final isAuthRoute =
          path == AppRoutes.login || path == AppRoutes.otp;

      if (user == null) {
        // Not signed in: land on login. splash's only job was to wait for
        // auth state to resolve — once resolved, move on immediately.
        if (isAuthRoute) return null;
        return AppRoutes.login;
      }

      // Signed in — check onboarding completion via the Firestore profile.
      final profileValue = ref.read(currentAppUserProvider);
      if (profileValue.isLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final profile = profileValue.valueOrNull;
      final step = profile?.onboardingStep ?? AppConstants.onboardingStepLanguage;

      if (isAuthRoute || path == AppRoutes.splash) {
        return _routeForStep(step);
      }

      // Signed in but mid-onboarding: force the correct step if the user
      // tries to jump ahead (FR-1.5 resume-at-exact-step).
      if (step != AppConstants.onboardingStepComplete) {
        final expected = _routeForStep(step);
        if (path != expected) return expected;
        return null;
      }

      // Onboarding complete: keep users out of onboarding/auth screens.
      if (path.startsWith('/onboarding')) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPersonInfo,
        builder: (context, state) => const PersonInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingTeacher,
        builder: (context, state) => const TeacherSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallpapers,
        builder: (context, state) => const WallpaperListScreen(),
      ),
      GoRoute(
        path: AppRoutes.ringtones,
        builder: (context, state) => const RingtoneListScreen(),
      ),
      GoRoute(
        path: AppRoutes.songs,
        builder: (context, state) => const SongListScreen(),
      ),
      GoRoute(
        path: AppRoutes.meditations,
        builder: (context, state) => const MeditationListScreen(),
      ),
    ],
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}

String _routeForStep(String step) {
  switch (step) {
    case AppConstants.onboardingStepLanguage:
      return AppRoutes.onboardingLanguage;
    case AppConstants.onboardingStepPersonInfo:
      return AppRoutes.onboardingPersonInfo;
    case AppConstants.onboardingStepTeacher:
      return AppRoutes.onboardingTeacher;
    default:
      return AppRoutes.home;
  }
}
