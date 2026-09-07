import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/video.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `videos/{videoId}` (admin-curated YouTube videos).
class VideoRepository with RepoGuard {
  VideoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _videos =>
      _firestore.collection(FirestoreCollections.videos);

  Video _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Video.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Active videos ordered by admin `sortOrder`, for the app's video list.
  Stream<List<Video>> watchActiveVideos() {
    return guardedStream(
      'videos.watchActive',
      _videos
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  /// Every video (admin list), ordered by `sortOrder`.
  Stream<List<Video>> watchAll() {
    return guardedStream(
      'videos.watchAll',
      _videos.orderBy('sortOrder').snapshots().map(
            (snap) => snap.docs.map(_fromDoc).toList(),
          ),
    );
  }

  Future<Video?> getById(String id) {
    return guardedRead('videos.getById', () async {
      final snap = await _videos.doc(id).get();
      if (!snap.exists) return null;
      return Video.fromJson({...snap.data()!, 'id': id});
    });
  }

  // --- Admin write operations ---

  Future<void> createWithId(Video video) {
    return guardedWrite(
      'videos.createWithId',
      () => _videos.doc(video.id).set(video.toJson()..remove('id')),
    );
  }

  Future<void> update(Video video) {
    return guardedWrite(
      'videos.update',
      () => _videos.doc(video.id).update(video.toJson()..remove('id')),
    );
  }

  Future<void> delete(String videoId) {
    return guardedWrite(
      'videos.delete',
      () => _videos.doc(videoId).delete(),
    );
  }
}
