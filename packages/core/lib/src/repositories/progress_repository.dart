import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../utils/repo_guard.dart';

/// A single "resume from where you left off" record for one audio item
/// (FR-10.5). Stored at `users/{uid}/progress/{itemId}`.
class PlaybackProgress {
  const PlaybackProgress({
    required this.itemId,
    required this.positionSec,
    this.durationSec,
    this.updatedAt,
  });

  factory PlaybackProgress.fromJson(String itemId, Map<String, dynamic> json) {
    final updated = json['updatedAt'];
    return PlaybackProgress(
      itemId: itemId,
      positionSec: (json['positionSec'] as num?)?.round() ?? 0,
      durationSec: (json['durationSec'] as num?)?.round(),
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }

  final String itemId;
  final int positionSec;
  final int? durationSec;
  final DateTime? updatedAt;

  Duration get position => Duration(seconds: positionSec);
}

/// Reads and writes per-user playback progress (Architecture §6.2, FR-10.5).
///
/// Rules allow the owner full read/write on `users/{uid}/progress/{itemId}`.
/// Writes are fire-and-forget from the audio handler — a failed save must
/// never interrupt playback.
class ProgressRepository with RepoGuard {
  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _progress(String uid) => _firestore
      .collection(FirestoreCollections.users)
      .doc(uid)
      .collection(FirestoreCollections.progress);

  /// Persists the current position. Fire-and-forget.
  Future<void> save({
    required String uid,
    required String itemId,
    required Duration position,
    Duration? duration,
  }) {
    return guardedWrite(
      'progress.save',
      () => _progress(uid).doc(itemId).set({
        'positionSec': position.inSeconds,
        if (duration != null) 'durationSec': duration.inSeconds,
        'updatedAt': DateTime.now(),
      }),
    );
  }

  /// The saved position for one item, or `null` if none exists.
  Future<PlaybackProgress?> get({
    required String uid,
    required String itemId,
  }) {
    return guardedRead('progress.get', () async {
      final snap = await _progress(uid).doc(itemId).get();
      if (!snap.exists) return null;
      return PlaybackProgress.fromJson(itemId, snap.data()!);
    });
  }

  /// Clears the saved position (called when an item finishes, so a completed
  /// track never shows a stale "resume" point).
  Future<void> clear({required String uid, required String itemId}) {
    return guardedWrite(
      'progress.clear',
      () => _progress(uid).doc(itemId).delete(),
    );
  }
}
