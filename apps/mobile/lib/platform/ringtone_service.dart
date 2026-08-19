import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

enum RingtoneKind { ringtone, alarm, notification }

extension RingtoneKindX on RingtoneKind {
  String get channelValue => name;
}

/// Dart face of `RingtonePlugin.kt` (Architecture §9.2).
class RingtoneService {
  RingtoneService({
    MethodChannel? channel,
    BaseCacheManager? cache,
  })  : _channel = channel ?? const MethodChannel('app.dhammapath/ringtone'),
        _cache = cache ?? DefaultCacheManager();

  final MethodChannel _channel;
  final BaseCacheManager _cache;

  Future<bool> canWriteSettings() async {
    return await _channel.invokeMethod<bool>('canWriteSettings') ?? false;
  }

  Future<void> openWriteSettings() {
    return _channel.invokeMethod<void>('openWriteSettings');
  }

  Future<String> cacheRemoteFile(String url) async {
    final file = await _cache.getSingleFile(url);
    if (!await file.exists() || await file.length() < 64) {
      throw StateError('Downloaded audio is empty');
    }
    final lower = file.path.toLowerCase();
    if (lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.aac')) {
      return file.path;
    }
    // Cache hashes often have no extension; MediaStore wants a real audio name.
    final dest = File('${Directory.systemTemp.path}/dhamma_${file.hashCode}.mp3');
    await file.copy(dest.path);
    return dest.path;
  }

  Future<void> setTone({
    required String url,
    required RingtoneKind kind,
  }) async {
    await _maybeRequestLegacyStorage();
    final path = await cacheRemoteFile(url);
    await _channel.invokeMethod<void>('setTone', {
      'path': path,
      'kind': kind.channelValue,
    });
  }

  /// Inserts into MediaStore without changing the default tone (T2.42).
  Future<String> saveToDevice({
    required String url,
    RingtoneKind kind = RingtoneKind.ringtone,
  }) async {
    await _maybeRequestLegacyStorage();
    final path = await cacheRemoteFile(url);
    final uri = await _channel.invokeMethod<String>('saveTone', {
      'path': path,
      'kind': kind.channelValue,
    });
    return uri ?? path;
  }

  Future<void> share({required String url, required String title}) async {
    final path = await cacheRemoteFile(url);
    await Share.shareXFiles([XFile(path)], text: title);
  }

  Future<void> _maybeRequestLegacyStorage() async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }
}

class PendingRingtoneSet {
  const PendingRingtoneSet({
    required this.url,
    required this.itemId,
    required this.kind,
  });

  final String url;
  final String itemId;
  final RingtoneKind kind;
}
