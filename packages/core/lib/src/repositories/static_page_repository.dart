import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/static_page.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `staticPages/{slug}` (PRD FR-14.4, AR-7.2).
class StaticPageRepository with RepoGuard {
  StaticPageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _pages =>
      _firestore.collection(FirestoreCollections.staticPages);

  StaticPage _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return StaticPage.fromJson({...doc.data()!, 'slug': doc.id});
  }

  Future<StaticPage?> get(String slug) {
    return guardedRead('staticPages.get', () async {
      final snap = await _pages.doc(slug).get();
      if (!snap.exists) return null;
      return _fromDoc(snap);
    });
  }

  Stream<StaticPage?> watch(String slug) {
    return guardedStream(
      'staticPages.watch',
      _pages.doc(slug).snapshots().map((snap) {
        if (!snap.exists) return null;
        return _fromDoc(snap);
      }),
    );
  }

  Stream<List<StaticPage>> watchAll() {
    return guardedStream(
      'staticPages.watchAll',
      _pages.snapshots().map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  Future<void> upsert(StaticPage page) {
    return guardedWrite('staticPages.upsert', () {
      final data = page.toJson()
        ..remove('slug')
        ..['updatedAt'] = DateTime.now();
      return _pages.doc(page.slug).set(data, SetOptions(merge: true));
    });
  }
}
