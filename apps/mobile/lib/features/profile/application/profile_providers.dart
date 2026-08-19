import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'static_page_fallbacks.dart';

part 'profile_providers.g.dart';

const playStoreUrl =
    'https://play.google.com/store/apps/details?id=app.dhammapath';

// contactRepositoryProvider now lives in `core` (shared with the admin
// inbox, T1.31) — no local duplicate needed.

@riverpod
Future<PackageInfo> packageInfo(Ref ref) => PackageInfo.fromPlatform();

@riverpod
Future<StaticPage?> staticPage(Ref ref, String slug) async {
  final remote = await ref.watch(staticPageRepositoryProvider).get(slug);
  if (remote != null) {
    final box = Hive.box<String>('static_pages');
    final map = Map<String, dynamic>.from(remote.toJson());
    map['updatedAt'] = remote.updatedAt?.toIso8601String();
    await box.put(slug, jsonEncode(map));
    return remote;
  }
  final cached = Hive.box<String>('static_pages').get(slug);
  if (cached != null) {
    try {
      return StaticPage.fromJson(
        Map<String, dynamic>.from(jsonDecode(cached) as Map),
      );
    } catch (_) {}
  }
  return fallbackStaticPage(slug);
}

Future<void> shareApp() {
  return Share.share(
    'Dhamma Path — Power in Every Voice\n$playStoreUrl',
  );
}

Future<void> openPlayStore() {
  return launchUrl(
    Uri.parse(playStoreUrl),
    mode: LaunchMode.externalApplication,
  );
}
