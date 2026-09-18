import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// One-time repair for devices carrying an *undecryptable* Firebase Auth
/// session on disk.
///
/// Firebase Auth on Android stores the signed-in user as two paired files in
/// `shared_prefs`:
///   * the session itself  — `com.google.firebase.auth.api.Store.<key>.xml`
///   * its encryption key   — `com.google.firebase.auth.api.crypto.<key>.xml`
///
/// Android Auto Backup / device-transfer can carry the encrypted Store file to
/// another install *without* its device-bound crypto key (the key legitimately
/// does not travel). The Store then cannot be decrypted: `currentUser` stays
/// null on every cold start, yet the file is present and full-sized, so
/// Firebase never rewrites it and the user is stuck on the login screen.
///
/// The distinctive, safe-to-act-on signature is therefore a **mismatched
/// pair**: a Store without its crypto key, or a crypto key without its Store.
/// A matched pair (both present) is left completely alone even when
/// `currentUser` is null, because that can be a perfectly valid session the SDK
/// simply has not surfaced yet — we must never delete that.
///
/// The backup-exclusion rules stop this happening going forward; this routine
/// repairs devices that already hold the broken state, so their next sign-in
/// can write a clean, decryptable pair.
///
/// Safety: only ever runs when there is no current user, only deletes an
/// orphaned (unpaired) file, re-checks after a settle delay, never touches a
/// file written during that delay, and never reads or logs token values.
const String _tag = 'AUTH_SELF_HEAL';

const String _authStorePrefix = 'com.google.firebase.auth.api.Store.';
const String _authCryptoPrefix = 'com.google.firebase.auth.api.crypto.';

/// Runs the repair. Call once during bootstrap, after Firebase is initialised.
///
/// [settleDelay] gives the native SDK time to publish a genuinely restored
/// user before we conclude the on-disk session is dead.
Future<void> healUnusableAuthStore({
  Duration settleDelay = const Duration(seconds: 3),
}) async {
  try {
    // Fast exit: a signed-in user means persistence is working. Do nothing.
    if (FirebaseAuth.instance.currentUser != null) return;

    final prefsDir = await _findSharedPrefsDir();
    if (prefsDir == null) return;

    // Only an ORPHANED store or crypto file is the undecryptable-restore
    // signature. A matched pair is a normal (possibly still-loading) session
    // and must never be deleted.
    if (_orphanedAuthFiles(prefsDir).isEmpty) return;

    // Note when we first saw the broken state. Anything written after this
    // (e.g. a sign-in during the settle window) is a real new session and is
    // left untouched.
    final observedAt = DateTime.now();

    // Re-check after a delay in case a valid restore was merely slow.
    await Future<void>.delayed(settleDelay);
    if (FirebaseAuth.instance.currentUser != null) return;

    final orphans = _orphanedAuthFiles(prefsDir);
    if (orphans.isEmpty) return; // the pair completed itself; leave it alone.

    final removed = <String>[];
    for (final file in orphans) {
      try {
        if (file.lastModifiedSync().isAfter(observedAt)) continue;
        file.deleteSync();
        removed.add(_baseName(file.path));
      } catch (error) {
        debugPrint('$_tag: could not delete ${_baseName(file.path)}: $error');
      }
    }

    if (removed.isNotEmpty) {
      debugPrint(
        '$_tag: removed an orphaned, undecryptable Firebase Auth session so '
        'the next sign-in can persist cleanly. Removed: $removed',
      );
    }
  } catch (error) {
    // Never let repair break launch — a failure here just leaves the user on
    // the login screen, which is the same state they were already in.
    debugPrint('$_tag: self-heal skipped due to error: $error');
  }
}

/// Returns auth store/crypto files whose partner is missing.
///
/// Each session is keyed by the suffix after the prefix (the persistence key).
/// A store with no matching crypto — or a crypto with no matching store — is
/// orphaned and cannot yield a usable session.
List<File> _orphanedAuthFiles(Directory prefsDir) {
  final files = prefsDir.listSync().whereType<File>().toList();
  final storeKeys = <String>{};
  final cryptoKeys = <String>{};

  for (final f in files) {
    final name = _baseName(f.path);
    if (name.startsWith(_authStorePrefix)) {
      storeKeys.add(_key(name, _authStorePrefix));
    } else if (name.startsWith(_authCryptoPrefix)) {
      cryptoKeys.add(_key(name, _authCryptoPrefix));
    }
  }

  return files.where((f) {
    final name = _baseName(f.path);
    if (name.startsWith(_authStorePrefix)) {
      return !cryptoKeys.contains(_key(name, _authStorePrefix));
    }
    if (name.startsWith(_authCryptoPrefix)) {
      return !storeKeys.contains(_key(name, _authCryptoPrefix));
    }
    return false;
  }).toList();
}

/// Persistence key = filename without the prefix and the trailing `.xml`.
String _key(String fileName, String prefix) {
  var rest = fileName.substring(prefix.length);
  if (rest.endsWith('.xml')) rest = rest.substring(0, rest.length - 4);
  return rest;
}

String _baseName(String path) => path.split(Platform.pathSeparator).last;

/// `getApplicationSupportDirectory()` lives inside the app data dir
/// (e.g. `<data>/files`); walk up until the sibling `shared_prefs` appears.
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
