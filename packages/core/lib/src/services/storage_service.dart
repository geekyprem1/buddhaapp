import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../utils/repo_guard.dart';

/// Cloud Storage layout from Architecture §6.4. Keep path construction
/// here so admin uploads and Functions agree on every key.
abstract class StoragePaths {
  StoragePaths._();

  static String teacherPortrait(String teacherId, [String ext = 'webp']) =>
      'teachers/$teacherId/portrait.$ext';
  static String teacherThumb(String teacherId, [String ext = 'webp']) =>
      'teachers/$teacherId/thumb.$ext';
  static String teacherSignature(String teacherId, [String ext = 'webp']) =>
      'teachers/$teacherId/signature.$ext';

  static String wisdomImage(String wisdomId, [String ext = 'webp']) =>
      'wisdoms/$wisdomId/image.$ext';

  static String homeBannerImage(String bannerId, [String ext = 'webp']) =>
      'homeBanners/$bannerId/image.$ext';

  /// The promo mp4 shown on the premium page. Not named `original.*` so the
  /// image pipeline never tries to decode it.
  static String premiumVideo([String ext = 'mp4']) => 'premium/video.$ext';

  static String placeThumb(String placeId, [String ext = 'webp']) =>
      'places/$placeId/thumb.$ext';

  /// A gallery image for a place. [index] keeps each upload at a distinct key.
  static String placeImage(String placeId, int index, [String ext = 'webp']) =>
      'places/$placeId/image_$index.$ext';

  static String contentOriginal(String collection, String itemId, String ext) =>
      '$collection/$itemId/original.$ext';
  static String contentFull(String collection, String itemId) =>
      '$collection/$itemId/full.webp';
  static String contentThumb(String collection, String itemId) =>
      '$collection/$itemId/thumb.webp';
  static String contentAudio(String collection, String itemId) =>
      '$collection/$itemId/audio.mp3';

  /// Live-wallpaper video. Deliberately NOT named `original.*` so the
  /// `onMediaUpload` image pipeline (sharp) never tries to decode it.
  static String contentVideo(String collection, String itemId,
          [String ext = 'mp4']) =>
      '$collection/$itemId/video.$ext';

  static String userAvatar(String uid) => 'users/$uid/avatar.webp';

  static String notificationImage(String campaignId, [String ext = 'jpg']) =>
      'notifications/$campaignId/image.$ext';

  /// Recover `{collection}/{itemId}/{file}` from a Firebase download URL.
  /// Returns null when [url] is not a Storage download URL.
  static String? fromDownloadUrl(String url) {
    final match = RegExp(r'/o/([^?]+)').firstMatch(url);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1)!);
  }

  /// If [urlOrPath] is a download URL, return the object path; if it already
  /// looks like a storage path, return it unchanged.
  static String? coercePath(String? urlOrPath) {
    if (urlOrPath == null || urlOrPath.isEmpty) return null;
    if (!urlOrPath.startsWith('http')) return urlOrPath;
    return fromDownloadUrl(urlOrPath);
  }
}

/// A live resumable upload with progress and cancel (PRD AR-8.2).
class StorageUpload {
  StorageUpload(this._task);

  final UploadTask _task;

  /// 0.0–1.0. Emits 0 while the total size is still unknown.
  Stream<double> get progress => _task.snapshotEvents.map((snap) {
        final total = snap.totalBytes;
        if (total <= 0) return 0.0;
        return snap.bytesTransferred / total;
      });

  Future<String> whenComplete() async {
    final snap = await _task;
    return snap.ref.getDownloadURL();
  }

  Future<bool> cancel() => _task.cancel();
}

/// Resumable upload / delete / signed URL wrapper (TASKS T0.14).
class StorageService with RepoGuard {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  StorageUpload uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) {
    final ref = _storage.ref(path);
    final task = ref.putData(
      bytes,
      contentType == null ? null : SettableMetadata(contentType: contentType),
    );
    return StorageUpload(task);
  }

  Future<String> getDownloadUrl(String path) {
    return guardedRead(
      'storage.getDownloadUrl',
      () => _storage.ref(path).getDownloadURL(),
    );
  }

  Future<void> delete(String path) {
    return guardedWrite('storage.delete', () async {
      try {
        await _storage.ref(path).delete();
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') return;
        rethrow;
      }
    });
  }
}
