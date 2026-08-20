import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/notifications/application/fcm_background.dart';
import '../features/player/application/dhamma_audio_handler.dart';
import '../features/prarthana/application/alarm_local_store.dart';
import 'app.dart';

/// Shared mobile bootstrap for both flavours (T2.1, T0.6, T2.73).
///
/// Order matters: App Check before other Firebase use; Firestore settings
/// before the first query; Hive before any cache read.
Future<void> bootstrapAndRun({
  required FirebaseOptions options,
  required bool debugAppCheck,
  required String googleServerClientId,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterFire's initializeApp gathers "plugin constants" from every
  // registered plugin. On some release builds the Crashlytics plugin throws
  // "FirebaseCrashlytics component is not present" during that gather, which
  // makes initializeApp throw even though the native FirebaseApp itself was
  // created fine. Swallow that specific case so Auth/Firestore still work and
  // we always reach runApp (crash reporting is best-effort, not a blocker).
  try {
    await Firebase.initializeApp(options: options);
  } catch (error, stack) {
    if (Firebase.apps.isEmpty) rethrow; // genuine init failure
    debugPrint('Firebase.initializeApp reported a plugin error: $error');
    await _safeRecordError(error, stack, reason: 'firebase.initializeApp');
  }

  _installCrashHooks();
  _configureFirestore();

  // Every step below is best-effort AND time-bounded: in release builds a
  // Firebase/plugin call can either throw OR hang indefinitely (the App Check
  // debug provider does this on some devices). Either one must never stop us
  // from reaching `runApp`, or the app hangs forever on the native splash.
  // App Check isn't enforced, so proceeding without it is safe.
  await _guardInit(
    'app_check',
    () => _activateAppCheck(debugAppCheck),
    timeout: const Duration(seconds: 6),
  );
  await _guardInit('fcm_background', () async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });
  await _guardInit('alarm_store', AlarmLocalStore.init);
  await _guardInit('audio_handler', initAudioHandler);
  await _guardInit(
    'google_sign_in',
    () => _initGoogleSignIn(googleServerClientId),
  );

  ErrorReporter.instance = ErrorReporter(sink: _crashlyticsSink);

  runApp(
    ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(sink: _analyticsSink),
        ),
      ],
      child: const DhammaPathApp(),
    ),
  );
}

Future<void> _activateAppCheck(bool debugAppCheck) async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          debugAppCheck ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          debugAppCheck ? AppleProvider.debug : AppleProvider.appAttest,
    );
    if (kDebugMode) {
      final token = await FirebaseAppCheck.instance.getToken();
      debugPrint(
        'App Check ready (debug=$debugAppCheck, token=${token != null}). '
        'Register the debug token from logcat in Firebase Console before '
        'turning on enforcement.',
      );
    }
  } catch (error, stack) {
    // Never block launch if App Check isn't provisioned yet — login and
    // content still work until Console enforcement is flipped on.
    debugPrint('App Check activate failed: $error');
    await _safeRecordError(error, stack, reason: 'app_check.activate');
  }
}

/// Runs a startup step, swallowing any error AND capping how long it may
/// block, so `runApp` is always reached even if a native call hangs.
Future<void> _guardInit(
  String label,
  Future<void> Function() step, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    await step().timeout(timeout);
  } on TimeoutException {
    debugPrint('Init step "$label" timed out after ${timeout.inSeconds}s');
  } catch (error, stack) {
    debugPrint('Init step "$label" failed: $error');
    await _safeRecordError(error, stack, reason: 'bootstrap.$label');
  }
}

/// Best-effort error reporting for startup diagnostics.
///
/// Crashlytics is intentionally not wired here: on this toolchain
/// (AGP 9 / very new Firebase SDK) the Crashlytics native component fails to
/// register on some release devices and its failure inside
/// `Firebase.initializeApp` left the app stuck on the splash. Until it can be
/// re-introduced with a compatible SDK (see TASKS T2.73 follow-up), startup
/// errors are logged locally only.
Future<void> _safeRecordError(
  Object error,
  StackTrace stack, {
  String? reason,
}) async {
  debugPrint('Startup error ($reason): $error');
}

void _installCrashHooks() {
  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(_safeRecordError(error, stack, reason: 'platform_dispatcher'));
    return true;
  };
  ErrorWidget.builder = (details) {
    return const Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Something went wrong.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
}

void _configureFirestore() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: AppConstants.firestoreCacheSizeBytes,
  );
}

Future<void> _initGoogleSignIn(String serverClientId) async {
  try {
    // serverClientId (the Firebase project's *web* OAuth client) is required
    // on Android for `authenticate()` to return an idToken. Without it the
    // idToken is null and Firebase rejects the credential silently.
    await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
  } catch (error, stack) {
    debugPrint('Google Sign-In initialize failed: $error');
    await _safeRecordError(error, stack, reason: 'google_sign_in.initialize');
  }
}

Future<void> _crashlyticsSink(
  Object error,
  StackTrace stack, {
  required bool fatal,
  String? reason,
}) async {
  debugPrint('Repo error ($reason, fatal=$fatal): $error');
}

Future<void> _analyticsSink(String name, Map<String, Object>? params) {
  return FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
}
