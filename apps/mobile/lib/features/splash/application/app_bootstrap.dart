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
      gate: _gate(config, installedVersion),
    );
  }

  static AppGate _gate(AppConfig config, String installed) {
    if (needsForceUpdate(
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
  final info = await PackageInfo.fromPlatform();
  final loader = AppBootstrapLoader(
    installedVersion: info.version,
    fetchFirestore: () => ref.read(configRepositoryProvider).getAppConfig(),
    fetchRemoteOverlay: _overlayRemoteConfig,
    readCache: _readCachedConfig,
    writeCache: _writeCachedConfig,
  );
  return loader.load();
}

const _cacheKey = 'app_config';

AppConfig? _readCachedConfig() {
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

Future<void> _writeCachedConfig(AppConfig config) {
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
