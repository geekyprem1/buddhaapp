import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/static_page.dart';

/// Reads/writes `staticPages/{slug}` (PRD FR-14.4, AR-7.2).
class StaticPageRepository {
  StaticPageRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _pages =>
      _firestore.collection(FirestoreCollections.staticPages);

  StaticPage _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return StaticPage.fromJson({...doc.data()!, 'slug': doc.id});
  }

  Future<StaticPage?> get(String slug) async {
    final snap = await _pages.doc(slug).get();
    if (!snap.exists) return null;
    return _fromDoc(snap);
  }

  Stream<StaticPage?> watch(String slug) {
    return _pages.doc(slug).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromDoc(snap);
    });
  }

  Stream<List<StaticPage>> watchAll() {
    return _pages.snapshots().map(
      (snap) => snap.docs.map(_fromDoc).toList(),
    );
  }

  Future<void> upsert(StaticPage page) {
    final data = page.toJson()
      ..remove('slug')
      ..['updatedAt'] = DateTime.now();
    return _pages.doc(page.slug).set(data, SetOptions(merge: true));
  }
}
