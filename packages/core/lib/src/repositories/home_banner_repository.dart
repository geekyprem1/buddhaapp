import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/home_banner.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `homeBanners/{bannerId}` — the Home carousel slides shown
/// next to the Today's Wisdom card.
class HomeBannerRepository with RepoGuard {
  HomeBannerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _banners =>
      _firestore.collection(FirestoreCollections.homeBanners);

  HomeBanner _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return HomeBanner.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Active slides ordered by admin `sortOrder`, for the home carousel.
  Stream<List<HomeBanner>> watchActiveBanners() {
    return guardedStream(
      'homeBanners.watchActive',
      _banners
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  Stream<List<HomeBanner>> watchAll() {
    return guardedStream(
      'homeBanners.watchAll',
      _banners.orderBy('sortOrder').snapshots().map(
            (snap) => snap.docs.map(_fromDoc).toList(),
          ),
    );
  }

  Future<HomeBanner?> getById(String id) {
    return guardedRead('homeBanners.getById', () async {
      final snap = await _banners.doc(id).get();
      if (!snap.exists) return null;
      return HomeBanner.fromJson({...snap.data()!, 'id': id});
    });
  }

  // --- Admin write operations ---

  Future<void> createWithId(HomeBanner banner) {
    return guardedWrite(
      'homeBanners.createWithId',
      () => _banners.doc(banner.id).set(banner.toJson()..remove('id')),
    );
  }

  Future<void> update(HomeBanner banner) {
    return guardedWrite(
      'homeBanners.update',
      () => _banners.doc(banner.id).update(banner.toJson()..remove('id')),
    );
  }

  Future<void> delete(String bannerId) {
    return guardedWrite(
      'homeBanners.delete',
      () => _banners.doc(bannerId).delete(),
    );
  }
}
