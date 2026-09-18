import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Diagnostics for the "user is logged out after the app is killed and
/// reopened" bug.
///
/// Why this exists: on Android, Firebase Auth restores the signed-in user
/// from a private on-disk store during `Firebase.initializeApp()` with **no
/// network call**. So if the app cold-starts signed-out after a previous
/// successful login, the stored session was *wiped*. That only happens when
/// the background ID-token refresh on launch is **rejected** with a fatal
/// server code (not when it merely fails on a flaky network — a transport
/// failure keeps the session).
///
/// Sign-in and token refresh talk to *different* backends:
///   - sign-in / OTP  -> identitytoolkit.googleapis.com
///   - token refresh  -> securetoken.googleapis.com
/// That is why "login works but the session is gone on the next launch" is a
/// real, common shape: the refresh endpoint (or its API-key/App Check gate) is
/// misconfigured while sign-in is fine.
///
/// These probes print, under the tag [_tag], exactly what happened so the
/// real (server/console-side) cause can be confirmed from the device log:
///   adb logcat -s flutter:V | findstr AUTH_PERSIST     (Windows)
///   adb logcat -s flutter:V | grep AUTH_PERSIST        (macOS/Linux)
///
/// This whole module is diagnostic-only; it never signs anyone out or changes
/// state. Wire it in from bootstrap behind a debug/`--dart-define` gate.
const String _tag = 'AUTH_PERSIST';

StreamSubscription<User?>? _idTokenSub;

/// Whether `currentUser` was already null the moment `Firebase.initializeApp()`
/// returned. The verdict compares this against the value a few seconds later.
bool _initialUserWasNull = true;

/// Logs whether a session survived to this launch, and — if it did — actively
/// reproduces the cold-start token refresh so any rejection (and its reason)
/// shows up in the log. Call once, right after Firebase is initialised.
void runAuthPersistenceProbe() {
  final user = FirebaseAuth.instance.currentUser;
  _initialUserWasNull = user == null;
  if (user == null) {
    debugPrint(
      '$_tag: after init there is NO persisted user. Either this build never '
      'signed in, or a previous launch had its token refresh rejected and the '
      'session was wiped. Sign in once, kill the app, reopen, and read this '
      'line again: if it still says NO user, the refresh is being rejected.',
    );
  } else {
    // Deliberately no phone number / email here: this probe can ship in an
    // internal-testing build, and logcat is readable by adb.
    debugPrint(
      '$_tag: session RESTORED from disk on launch: uid=${user.uid} '
      'hasPhone=${user.phoneNumber != null} '
      'providers=${user.providerData.map((p) => p.providerId).toList()}. '
      'Now forcing the same refresh the SDK does on cold start...',
    );
    unawaited(_probeTokenRefresh(user));
  }
  unawaited(_probeAppCheck());
  _installIdTokenLogger();
  unawaited(_snapshotLater());
  _logExpectedStoreName();
  unawaited(dumpAuthStoreFiles('at startup'));
}

/// Inspects the app's own `shared_prefs` directory for Firebase Auth's
/// persistence file.
///
/// Firebase Auth on Android stores the signed-in user in a private
/// SharedPreferences file named
/// `com.google.firebase.auth.api.Store.<base64url(appName)>+<base64url(appId)>`
/// and restores it on startup with a plain disk read. Listing that directory
/// therefore separates the two remaining possibilities, which look identical
/// from `currentUser` alone:
///
///   * called right after login, no store file  -> the session is never being
///     written to disk at all.
///   * store file present after login but gone/empty on the next cold start
///     -> something is wiping it.
///
/// An app can always read its own data directory, so this works on a release
/// build installed from Play (where `adb run-as` is not available).
Future<void> dumpAuthStoreFiles(String when) async {
  try {
    final prefsDir = await _findSharedPrefsDir();
    if (prefsDir == null) {
      debugPrint('$_tag: [$when] could not locate the shared_prefs directory.');
      return;
    }
    final files = prefsDir.listSync().whereType<File>().toList();
    final authStores = files
        .where((f) => f.path.contains('com.google.firebase.auth.api.Store'))
        .toList();

    if (authStores.isEmpty) {
      debugPrint(
        '$_tag: [$when] >>> NO Firebase Auth store file in '
        '${prefsDir.path}. Files present: '
        '${files.map((f) => _baseName(f.path)).toList()}',
      );
    } else {
      for (final f in authStores) {
        // lastModified is the decisive bit: if it does not advance when the
        // user signs in, this build never rewrites the store and the file on
        // disk is a leftover from an earlier build — which would explain a
        // present-but-unreadable session.
        debugPrint(
          '$_tag: [$when] >>> Auth store present: ${_baseName(f.path)} '
          '(${f.lengthSync()} bytes, lastModified=${f.lastModifiedSync().toIso8601String()})',
        );
        _describeStoreShape(f, when);
      }
    }
  } catch (error) {
    debugPrint('$_tag: [$when] could not inspect shared_prefs: $error');
  }
}

String _baseName(String path) => path.split(Platform.pathSeparator).last;

/// Logs the *shape* of the persisted session: the SharedPreferences entry names
/// and the top-level JSON keys inside them.
///
/// Deliberately never logs values — the store holds ID and refresh tokens.
/// Key names alone answer the question that matters: whether the stored blob
/// still uses the field names this build's Firebase Auth expects. R8 assigns
/// fresh obfuscated names on every run, so a store written by an earlier build
/// can become unreadable to a later one even though the file is intact.
void _describeStoreShape(File file, String when) {
  try {
    final xml = file.readAsStringSync();
    final entryNames = RegExp(r'name="([^"]+)"')
        .allMatches(xml)
        .map((m) => m.group(1))
        .whereType<String>()
        .toList();
    debugPrint('$_tag: [$when] store entry names: $entryNames');

    // Top-level JSON keys only, capped so the log stays readable.
    final jsonKeys = RegExp(r'&quot;([A-Za-z_][A-Za-z0-9_]*)&quot;\s*:')
        .allMatches(xml)
        .map((m) => m.group(1))
        .whereType<String>()
        .toSet()
        .take(40)
        .toList();
    if (jsonKeys.isNotEmpty) {
      debugPrint('$_tag: [$when] store JSON keys (deduped): $jsonKeys');
    }
  } catch (error) {
    debugPrint('$_tag: [$when] could not describe the store shape: $error');
  }
}

/// Logs the store filename Firebase Auth is expected to use for this build.
///
/// The name is derived from `FirebaseApp.getPersistenceKey()`, which is
/// `base64Url(appName) + "+" + base64Url(options.applicationId)`. Because the
/// Google app id comes from `google-services.json`, a build that ships a
/// different config reads a different file — a session written by one variant
/// is invisible to the other. Printing the expected name next to the files
/// actually on disk makes that mismatch obvious instead of theoretical.
void _logExpectedStoreName() {
  try {
    final appId = Firebase.app().options.appId;
    String enc(String s) => base64Url.encode(utf8.encode(s));
    final withPadding = '${enc('[DEFAULT]')}+${enc(appId)}';
    final withoutPadding = withPadding.replaceAll('=', '');
    debugPrint(
      '$_tag: appId=$appId\n'
      '$_tag: expected store file = '
      'com.google.firebase.auth.api.Store.$withoutPadding '
      '(padded variant: com.google.firebase.auth.api.Store.$withPadding)',
    );
  } catch (error) {
    debugPrint('$_tag: could not compute the expected store name: $error');
  }
}

/// `getApplicationSupportDirectory()` sits inside the app's data directory
/// (e.g. `<data>/files`), so walk up until the sibling `shared_prefs` appears.
Future<Directory?> _findSharedPrefsDir() async {
  Directory? current = await getApplicationSupportDirectory();
  for (var i = 0; i < 4 && current != null; i++) {
    final candidate = Directory('${current.path}/shared_prefs');
    if (candidate.existsSync()) return candidate;
    final parent = current.parent;
    if (parent.path == current.path) break;
    current = parent;
  }
  return null;
}

/// The decisive discriminator.
///
/// `authStateChanges()` yields the plugin's cached `currentUser` *immediately*,
/// and that cache is only filled from the plugin constants gathered during
/// `Firebase.initializeApp()`. The native auth-state listener is registered
/// asynchronously just after, and on Android it fires straight away with the
/// real stored user.
///
/// So comparing "currentUser at init" against "currentUser a few seconds
/// later" separates the two possible faults cleanly:
///   - null at init, then NON-null later  -> the session WAS on disk; the Dart
///     side just started out blind (plugin constants were missed, e.g. because
///     `Firebase.initializeApp()` threw during the gather). The auth gate acted
///     on that first false `null`. This is an app-side bug.
///   - null at init and still null later  -> the native session store really is
///     empty; the session never persisted or was wiped server-side.
Future<void> _snapshotLater() async {
  for (final seconds in [3, 8]) {
    await Future<void>.delayed(Duration(seconds: seconds == 3 ? 3 : 5));
    final user = FirebaseAuth.instance.currentUser;
    debugPrint(
      '$_tag: currentUser at +${seconds}s = '
      '${user == null ? 'null' : 'uid ${user.uid}'}',
    );
  }
  final settled = FirebaseAuth.instance.currentUser;
  final String verdict;
  if (settled == null) {
    verdict = 'native session store is EMPTY. The session was never written '
        'to disk or was genuinely wiped server-side. This is NOT a routing '
        'bug — the app is correctly showing login.';
  } else if (_initialUserWasNull) {
    verdict = 'session EXISTS natively (uid ${settled.uid}) but was NOT '
        'available at startup. The auth gate acted on a false initial null '
        'and sent the user to /login. This is an app-side bug.';
  } else {
    verdict = 'session persisted correctly (uid ${settled.uid}) — it was '
        'available at startup AND still valid now. No logout bug reproduced '
        'on this launch.';
  }
  debugPrint('$_tag: VERDICT = $verdict');
}

/// Forces `getIdToken(true)`. If this is rejected with a fatal code, that is
/// precisely what signs the user out on the following launch.
Future<void> _probeTokenRefresh(User user) async {
  try {
    final token = await user.getIdToken(true);
    debugPrint(
      '$_tag: forced ID-token refresh SUCCEEDED (token len=${token?.length}). '
      'The refresh path is healthy — if the session still disappears, capture '
      'the idTokenChanges line below to see when it flips to null.',
    );
  } on FirebaseAuthException catch (e) {
    debugPrint(
      '$_tag: forced ID-token refresh was REJECTED. code=${e.code} '
      'message=${e.message}\n$_tag: >>> ${_hintForRejection(e.code, e.message)}',
    );
  } catch (e) {
    debugPrint('$_tag: forced ID-token refresh threw: $e');
  }
}

/// Reports whether an App Check token can be produced. If Auth enforcement is
/// on and this is false, the refresh above will be rejected.
Future<void> _probeAppCheck() async {
  try {
    final token = await FirebaseAppCheck.instance.getToken();
    debugPrint(
      '$_tag: App Check token available=${token != null}. '
      '(Only relevant if App Check enforcement is ON for Authentication.)',
    );
  } catch (e) {
    debugPrint(
      '$_tag: App Check getToken failed: $e. If App Check enforcement is ON '
      'for Authentication, token refresh will be rejected on every launch.',
    );
  }
}

/// Timestamps every auth transition so a mid-launch wipe (user -> null a beat
/// after start) is visible rather than inferred.
void _installIdTokenLogger() {
  _idTokenSub ??= FirebaseAuth.instance.idTokenChanges().listen((user) {
    debugPrint(
      '$_tag: idTokenChanges -> '
      '${user == null ? 'SIGNED OUT (null)' : 'user ${user.uid}'} '
      'at ${DateTime.now().toIso8601String()}',
    );
    // Re-read the on-disk store on every transition. Right after a successful
    // login this answers the decisive question: did Firebase Auth actually
    // write the session to disk at all?
    unawaited(
      dumpAuthStoreFiles(
        user == null ? 'after signed-out event' : 'after signed-in event',
      ),
    );
  });
}

String _hintForRejection(String code, String? message) {
  final m = (message ?? '').toLowerCase();
  final c = code.toLowerCase();
  if (c.contains('app-check') ||
      c.contains('appcheck') ||
      m.contains('app check') ||
      m.contains('appcheck') ||
      m.contains('attestation')) {
    return 'CAUSE = App Check. Enforcement is ON for Authentication but this '
        'build has no valid attestation. Fix: register this build\'s debug '
        'token (dev builds) or the Play Integrity SHA-256 of the signing key '
        '(release builds) in Firebase Console > App Check, OR turn OFF App '
        'Check enforcement for the Authentication product.';
  }
  if (m.contains('blocked') ||
      m.contains('api key') ||
      m.contains('api_key') ||
      c == 'permission-denied' ||
      m.contains('permission_denied') ||
      m.contains('forbidden') ||
      m.contains('requests from this android client')) {
    return 'CAUSE = API key restriction on the token-refresh endpoint. In '
        'Google Cloud Console > APIs & Services > Credentials, open the '
        'Android API key for this Firebase project and make sure: (1) API '
        'restrictions allow BOTH "Identity Toolkit API" and "Token Service '
        'API" (securetoken), and (2) the Android app restriction lists this '
        'build\'s package name + SHA-1 (release key SHA-1 for release builds; '
        'with Play App Signing use Google\'s app-signing SHA-1).';
  }
  if (c == 'network-request-failed') {
    return 'This is a transient network failure. It does NOT wipe the session, '
        'so it is not the cause of the logout. Retry on a stable connection.';
  }
  if (c == 'user-disabled' ||
      c == 'user-not-found' ||
      c == 'user-token-expired' ||
      c == 'invalid-user-token') {
    return 'The account/token is genuinely invalid (real sign-out). Check '
        'whether the user was disabled/deleted in the Authentication console.';
  }
  return 'Unmapped code. Compare code/message against the Firebase Auth error '
      'table; a definitive (non-network) rejection here is what clears the '
      'stored session on the next launch.';
}
