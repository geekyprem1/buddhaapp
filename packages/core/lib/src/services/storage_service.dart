import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

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

  static String contentOriginal(String collection, String itemId, String ext) =>
      '$collection/$itemId/original.$ext';
  static String contentFull(String collection, String itemId) =>
      '$collection/$itemId/full.webp';
  static String contentThumb(String collection, String itemId) =>
      '$collection/$itemId/thumb.webp';
  static String contentAudio(String collection, String itemId) =>
      '$collection/$itemId/audio.mp3';

  static String userAvatar(String uid) => 'users/$uid/avatar.webp';

  static String notificationImage(String campaignId, [String ext = 'jpg']) =>
      'notifications/$campaignId/image.$ext';
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
class StorageService {
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
    return _storage.ref(path).getDownloadURL();
  }

  Future<void> delete(String path) async {
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      rethrow;
    }
  }
}
