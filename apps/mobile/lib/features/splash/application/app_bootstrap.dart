import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_bootstrap.g.dart';

enum AppGate { ready, forceUpdate, maintenance }

class AppBootstrap {
  const AppBootstrap({
    required this.config,
    required this.installedVersion,
    required this.gate,
  });

  final AppConfig config;
  final String installedVersion;
  final AppGate gate;
}

/// Loads Firestore `config/app_config` (cached fallback) and overlays
/// Remote Config kill-switches. Caps wait at 2s (FR-1.1, T2.3).
class AppBootstrapLoader {
  AppBootstrapLoader({
    required this.fetchFirestore,
    required this.installedVersion,
    this.versionKnown = true,
    this.fetchRemoteOverlay,
    this.readCache,
    this.writeCache,
    this.now,
    this.maxWait = const Duration(seconds: 2),
    this.minWait = const Duration(milliseconds: 400),
  });

  final Future<AppConfig> Function() fetchFirestore;
  final Future<AppConfig> Function(AppConfig current)? fetchRemoteOverlay;
  final AppConfig? Function()? readCache;
  final Future<void> Function(AppConfig config)? writeCache;
  final String installedVersion;

  /// False when the installed version could not be read (B10): the
  /// force-update gate must fail open rather than lock the user on `/update`
  /// over a placeholder version.
  final bool versionKnown;
  final DateTime Function()? now;
  final Duration maxWait;
  final Duration minWait;

  Future<AppBootstrap> load() async {
    final started = (now ?? DateTime.now)();
    var config = readCache?.call() ?? const AppConfig();

    try {
      config = await fetchFirestore().timeout(maxWait);
      await writeCache?.call(config);
    } catch (_) {
      config = readCache?.call() ?? config;
    }

    if (fetchRemoteOverlay != null) {
      final remaining = maxWait - (now ?? DateTime.now)().difference(started);
      if (remaining > Duration.zero) {
        try {
          config = await fetchRemoteOverlay!(config).timeout(remaining);
        } catch (_) {}
      }
    }

    final elapsed = (now ?? DateTime.now)().difference(started);
    if (elapsed < minWait) {
      await Future<void>.delayed(minWait - elapsed);
    }

    return AppBootstrap(
      config: config,
      installedVersion: installedVersion,
      gate: _gate(config, installedVersion, versionKnown: versionKnown),
    );
  }

  static AppGate _gate(
    AppConfig config,
    String installed, {
    required bool versionKnown,
  }) {
    // Unknown install must never trigger force-update (B10): any comparison
    // against a placeholder like 0.0.0 is meaningless. Maintenance still
    // applies — it doesn't depend on the version.
    if (versionKnown &&
        needsForceUpdate(
          forceUpdate: config.forceUpdate,
          minSupportedVersion: config.minSupportedVersion,
          installedVersion: installed,
        )) {
      return AppGate.forceUpdate;
    }
    if (config.maintenanceMode) return AppGate.maintenance;
    return AppGate.ready;
  }
}

@Riverpod(keepAlive: true)
Future<AppBootstrap> appBootstrap(Ref ref) async {
  // Never let a hanging platform channel block the splash forever — fall
  // back to a placeholder version AND mark it unknown so the force-update
  // gate fails open instead of locking on `/update` (B10).
  var version = '0.0.0';
  var versionKnown = false;
  try {
    final info = await PackageInfo.fromPlatform()
        .timeout(const Duration(seconds: 3));
    version = info.version;
    versionKnown = true;
  } catch (_) {
    // keep the placeholder as unknown
  }
  final loader = AppBootstrapLoader(
    installedVersion: version,
    versionKnown: versionKnown,
    fetchFirestore: () => ref.read(configRepositoryProvider).getAppConfig(),
    fetchRemoteOverlay: _overlayRemoteConfig,
    readCache: _readCachedConfig,
    writeCache: _writeCachedConfig,
  );
  return loader.load();
}

const _cacheKey = 'app_config';

AppConfig? _readCachedConfig() {
  // Best-effort startup may have left the box unopened (B9) — cached config
  // is optional, so degrade to "no cache" instead of throwing.
  if (!Hive.isBoxOpen('app_prefs')) return null;
  final raw = Hive.box('app_prefs').get(_cacheKey);
  if (raw is! String || raw.isEmpty) return null;
  try {
    return AppConfig.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  } catch (_) {
    return null;
  }
}

Future<void> _writeCachedConfig(AppConfig config) async {
  // Recover the box when startup init was skipped/failed (B9); a cache write
  // is never worth crashing over.
  if (!Hive.isBoxOpen('app_prefs')) {
    try {
      await Hive.openBox('app_prefs');
    } catch (_) {
      return;
    }
  }
  final map = <String, dynamic>{
    'minSupportedVersion': config.minSupportedVersion,
    'latestVersion': config.latestVersion,
    'forceUpdate': config.forceUpdate,
    'maintenanceMode': config.maintenanceMode,
    'maintenanceMessage': config.maintenanceMessage.toJson(),
    'languages': config.languages.map((e) => e.toJson()).toList(),
    'adsEnabled': config.adsEnabled,
    'idCardEnabled': config.idCardEnabled,
    'liveWallpaperEnabled': config.liveWallpaperEnabled,
    'updatedAt': config.updatedAt?.toIso8601String(),
  };
  return Hive.box('app_prefs').put(_cacheKey, jsonEncode(map));
}

Future<AppConfig> _overlayRemoteConfig(AppConfig current) async {
  final rc = FirebaseRemoteConfig.instance;
  await rc.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 2),
      minimumFetchInterval: const Duration(hours: 1),
    ),
  );
  await rc.setDefaults(const {
    'force_update': false,
    'maintenance_mode': false,
    'min_supported_version': '',
  });
  await rc.fetchAndActivate();
  var next = current;
  if (rc.getBool('force_update')) {
    next = next.copyWith(forceUpdate: true);
  }
  if (rc.getBool('maintenance_mode')) {
    next = next.copyWith(maintenanceMode: true);
  }
  final min = rc.getString('min_supported_version').trim();
  if (min.isNotEmpty) {
    next = next.copyWith(minSupportedVersion: min);
  }
  return next;
}
