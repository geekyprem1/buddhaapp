import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

enum WallpaperTarget { home, lock, both }

extension WallpaperTargetX on WallpaperTarget {
  String get channelValue => name;
}

/// Dart face of `WallpaperPlugin.kt` (Architecture §1 — platform work
/// behind an interface).
class WallpaperService {
  WallpaperService({
    MethodChannel? channel,
    BaseCacheManager? cache,
  })  : _channel = channel ?? const MethodChannel('app.dhammapath/wallpaper'),
        _cache = cache ?? DefaultCacheManager();

  final MethodChannel _channel;
  final BaseCacheManager _cache;

  Future<String> cacheRemoteFile(String url) async {
    final file = await _cache.getSingleFile(url);
    return file.path;
  }

  Future<void> setWallpaper({
    required String url,
    required WallpaperTarget target,
  }) async {
    final path = await cacheRemoteFile(url);
    await _channel.invokeMethod<void>('setWallpaper', {
      'path': path,
      'target': target.channelValue,
    });
  }

  Future<String> saveToGallery(String url) async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    final path = await cacheRemoteFile(url);
    final saved = await _channel.invokeMethod<String>('saveToGallery', {
      'path': path,
    });
    return saved ?? path;
  }

  Future<void> share({required String url, required String title}) async {
    final path = await cacheRemoteFile(url);
    await Share.shareXFiles([XFile(path)], text: title);
  }

  Future<String> saveFileToGallery(String path) async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    final saved = await _channel.invokeMethod<String>('saveToGallery', {
      'path': path,
    });
    return saved ?? path;
  }

  Future<void> shareWhatsApp(String path) {
    return _channel.invokeMethod<void>('shareWhatsApp', {'path': path});
  }
}
