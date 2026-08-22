import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/buddhist_calendar/presentation/buddhist_calendar_screen.dart';
import '../features/chanting/presentation/chanting_list_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/meditation/presentation/meditation_list_screen.dart';
import '../features/onboarding/presentation/language_screen.dart';
import '../features/onboarding/presentation/person_info_screen.dart';
import '../features/onboarding/presentation/teacher_select_screen.dart';
import '../features/player/presentation/full_player_screen.dart';
import '../features/profile/presentation/change_language_screen.dart';
import '../features/profile/presentation/contact_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/edit_teachers_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/static_page_screen.dart';
import '../features/prarthana/presentation/prarthana_help_screen.dart';
import '../features/prarthana/presentation/prarthana_list_screen.dart';
import '../features/prarthana/presentation/prarthana_setup_screen.dart';
import '../features/ringtone/presentation/ringtone_help_screen.dart';
import '../features/ringtone/presentation/ringtone_list_screen.dart';
import '../features/song/presentation/song_list_screen.dart';
import '../features/vandana/presentation/vandana_list_screen.dart';
import '../features/splash/application/app_bootstrap.dart';
import '../features/splash/presentation/force_update_screen.dart';
import '../features/splash/presentation/maintenance_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/status/presentation/status_list_screen.dart';
import '../features/wallpaper/application/wallpaper_gallery.dart';
import '../features/wallpaper/presentation/wallpaper_detail_screen.dart';
import '../features/wallpaper/presentation/wallpaper_list_screen.dart';

part 'router.g.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const forceUpdate = '/update';
  static const maintenance = '/maintenance';
  static const legal = '/legal';
  static const login = '/login';
  static const otp = '/otp';
  static const onboardingLanguage = '/onboarding/language';
  static const onboardingPersonInfo = '/onboarding/person-info';
  static const onboardingTeacher = '/onboarding/teacher';
  static const home = '/home';
  static const buddhistCalendar = '/buddhist-calendar';
  static const wallpapers = '/wallpapers';
  static const ringtones = '/ringtones';
  static const ringtoneHelp = '/ringtones/help';
  static const songs = '/songs';
  static const vandanas = '/vandana';
  static const chantings = '/chanting';
  static const meditations = '/meditations';
  static const player = '/player';
  static const wallpaperDetail = '/wallpapers/view';
  static const prarthana = '/prarthana';
  static const prarthanaHelp = '/prarthana/help';
  static const prarthanaEdit = '/prarthana/edit';
  static const statuses = '/statuses';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileLanguage = '/profile/language';
  static const profileTeachers = '/profile/teachers';
  static const profileContact = '/profile/contact';
  static const profilePage = '/profile/page';
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
  ref.listen(appBootstrapProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final boot = ref.read(appBootstrapProvider);

      // Config gates first (FR-1.3, FR-1.4). Splash owns the wait.
      if (boot.isLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }
      final gate = boot.valueOrNull?.gate ?? AppGate.ready;
      if (gate == AppGate.forceUpdate) {
        return path == AppRoutes.forceUpdate ? null : AppRoutes.forceUpdate;
      }
      if (gate == AppGate.maintenance) {
        return path == AppRoutes.maintenance ? null : AppRoutes.maintenance;
      }

      final authValue = ref.read(authStateProvider);

      // While auth state is loading, only the splash screen is allowed —
      // it owns the bootstrap sequence (FR-1.2).
      if (authValue.isLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = authValue.valueOrNull;
      final isAuthRoute = path == AppRoutes.login || path == AppRoutes.otp;
      final isLegalRoute = path.startsWith('${AppRoutes.legal}/');

      if (user == null) {
        // Not signed in: land on login. splash's only job was to wait for
        // auth state to resolve — once resolved, move on immediately.
        if (isAuthRoute || isLegalRoute) return null;
        return AppRoutes.login;
      }

      // Signed in — check onboarding completion via the Firestore profile.
      final profileValue = ref.read(currentAppUserProvider);
      if (profileValue.isLoading) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final profile = profileValue.valueOrNull;
      final step =
          profile?.onboardingStep ?? AppConstants.onboardingStepLanguage;

      if (isAuthRoute ||
          path == AppRoutes.splash ||
          path == AppRoutes.forceUpdate ||
          path == AppRoutes.maintenance) {
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
        path: AppRoutes.forceUpdate,
        builder: (context, state) => const ForceUpdateScreen(),
      ),
      GoRoute(
        path: AppRoutes.maintenance,
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.legal}/:slug',
        builder: (context, state) => StaticPageScreen(
          slug: state.pathParameters['slug'] ?? StaticPageSlugs.about,
        ),
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
        path: AppRoutes.buddhistCalendar,
        builder: (context, state) => const BuddhistCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileLanguage,
        builder: (context, state) => const ChangeLanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileTeachers,
        builder: (context, state) => const EditTeachersScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileContact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: AppRoutes.profilePage,
        builder: (context, state) {
          final slug = state.extra as String? ?? StaticPageSlugs.about;
          return StaticPageScreen(slug: slug);
        },
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
        path: AppRoutes.ringtoneHelp,
        builder: (context, state) => const RingtoneHelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.songs,
        builder: (context, state) => const SongListScreen(),
      ),
      GoRoute(
        path: AppRoutes.vandanas,
        builder: (context, state) => const VandanaListScreen(),
      ),
      GoRoute(
        path: AppRoutes.chantings,
        builder: (context, state) => const ChantingListScreen(),
      ),
      GoRoute(
        path: AppRoutes.meditations,
        builder: (context, state) => const MeditationListScreen(),
      ),
      GoRoute(
        path: AppRoutes.player,
        builder: (context, state) => const FullPlayerScreen(),
      ),
      GoRoute(
        path: AppRoutes.statuses,
        builder: (context, state) => const StatusListScreen(),
      ),
      GoRoute(
        path: AppRoutes.prarthana,
        builder: (context, state) => const PrarthanaListScreen(),
      ),
      GoRoute(
        path: AppRoutes.prarthanaHelp,
        builder: (context, state) => const PrarthanaHelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.prarthanaEdit,
        builder: (context, state) => PrarthanaSetupScreen(
          existing: state.extra as Alarm?,
        ),
      ),
      GoRoute(
        path: AppRoutes.wallpaperDetail,
        builder: (context, state) {
          final gallery = state.extra as WallpaperGallery?;
          if (gallery == null || gallery.items.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Wallpaper not found.')),
            );
          }
          return WallpaperDetailScreen(gallery: gallery);
        },
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
