import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/wisdom.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `wisdoms/{wisdomId}` (Today Wisdom cards).
class WisdomRepository with RepoGuard {
  WisdomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _wisdoms =>
      _firestore.collection(FirestoreCollections.wisdoms);

  Wisdom _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Wisdom.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Active cards ordered by admin `sortOrder`, for the home hero.
  Stream<List<Wisdom>> watchActiveWisdoms() {
    return guardedStream(
      'wisdoms.watchActive',
      _wisdoms
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  Stream<List<Wisdom>> watchAll() {
    return guardedStream(
      'wisdoms.watchAll',
      _wisdoms.orderBy('sortOrder').snapshots().map(
            (snap) => snap.docs.map(_fromDoc).toList(),
          ),
    );
  }

  Future<List<Wisdom>> getActiveWisdoms() {
    return guardedRead('wisdoms.getActive', () async {
      final snap = await _wisdoms
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();
      return snap.docs.map(_fromDoc).toList();
    });
  }

  Future<Wisdom?> getById(String id) {
    return guardedRead('wisdoms.getById', () async {
      final snap = await _wisdoms.doc(id).get();
      if (!snap.exists) return null;
      return Wisdom.fromJson({...snap.data()!, 'id': id});
    });
  }

  // --- Admin write operations ---

  Future<String> create(Wisdom wisdom) {
    return guardedWrite('wisdoms.create', () async {
      final doc = await _wisdoms.add(wisdom.toJson()..remove('id'));
      return doc.id;
    });
  }

  Future<void> createWithId(Wisdom wisdom) {
    return guardedWrite(
      'wisdoms.createWithId',
      () => _wisdoms.doc(wisdom.id).set(wisdom.toJson()..remove('id')),
    );
  }

  Future<void> update(Wisdom wisdom) {
    return guardedWrite(
      'wisdoms.update',
      () => _wisdoms.doc(wisdom.id).update(wisdom.toJson()..remove('id')),
    );
  }

  Future<void> delete(String wisdomId) {
    return guardedWrite(
      'wisdoms.delete',
      () => _wisdoms.doc(wisdomId).delete(),
    );
  }
}
