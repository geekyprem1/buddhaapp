import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/buddhist_place.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `places/{placeId}` (admin-curated Buddhist places).
class PlaceRepository with RepoGuard {
  PlaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _places =>
      _firestore.collection(FirestoreCollections.places);

  BuddhistPlace _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return BuddhistPlace.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Active places ordered by admin `sortOrder`, for the app's grid.
  Stream<List<BuddhistPlace>> watchActivePlaces() {
    return guardedStream(
      'places.watchActive',
      _places
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  /// Every place (admin list), ordered by `sortOrder`.
  Stream<List<BuddhistPlace>> watchAll() {
    return guardedStream(
      'places.watchAll',
      _places.orderBy('sortOrder').snapshots().map(
            (snap) => snap.docs.map(_fromDoc).toList(),
          ),
    );
  }

  Future<BuddhistPlace?> getById(String id) {
    return guardedRead('places.getById', () async {
      final snap = await _places.doc(id).get();
      if (!snap.exists) return null;
      return BuddhistPlace.fromJson({...snap.data()!, 'id': id});
    });
  }

  // --- Admin write operations ---

  Future<void> createWithId(BuddhistPlace place) {
    return guardedWrite(
      'places.createWithId',
      () => _places.doc(place.id).set(place.toJson()..remove('id')),
    );
  }

  Future<void> update(BuddhistPlace place) {
    return guardedWrite(
      'places.update',
      () => _places.doc(place.id).update(place.toJson()..remove('id')),
    );
  }

  Future<void> delete(String placeId) {
    return guardedWrite(
      'places.delete',
      () => _places.doc(placeId).delete(),
    );
  }
}
