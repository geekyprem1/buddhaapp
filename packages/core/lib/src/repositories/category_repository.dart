import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/category.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `categories/{categoryId}` (PRD AR-3.x, FR-7.10).
class CategoryRepository with RepoGuard {
  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection(FirestoreCollections.categories);

  Category _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Category.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Categories for one module, ordered by `sortOrder`. Admins pass
  /// [activeOnly]: false to include retired rows.
  Stream<List<Category>> watchByModule(
    String module, {
    bool activeOnly = true,
  }) {
    Query<Map<String, dynamic>> query =
        _categories.where('module', isEqualTo: module).orderBy('sortOrder');
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    return guardedStream(
      'categories.watchByModule',
      query.snapshots().map((snap) => snap.docs.map(_fromDoc).toList()),
    );
  }

  Future<List<Category>> getByModule(
    String module, {
    bool activeOnly = true,
  }) {
    return guardedRead('categories.getByModule', () async {
      Query<Map<String, dynamic>> query =
          _categories.where('module', isEqualTo: module).orderBy('sortOrder');
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      final snap = await query.get();
      return snap.docs.map(_fromDoc).toList();
    });
  }

  Stream<List<Category>> watchAll() {
    return guardedStream(
      'categories.watchAll',
      _categories.snapshots().map((snap) {
        final list = snap.docs.map(_fromDoc).toList();
        list.sort((a, b) {
          final byModule = a.module.compareTo(b.module);
          if (byModule != 0) return byModule;
          return a.sortOrder.compareTo(b.sortOrder);
        });
        return list;
      }),
    );
  }

  Future<Category?> getById(String id) {
    return guardedRead('categories.getById', () async {
      final snap = await _categories.doc(id).get();
      if (!snap.exists) return null;
      return _fromDoc(snap);
    });
  }

  Future<void> createWithId(Category category) {
    return guardedWrite(
      'categories.createWithId',
      () => _categories.doc(category.id).set(category.toJson()..remove('id')),
    );
  }

  Future<String> create(Category category) {
    return guardedWrite('categories.create', () async {
      final doc = await _categories.add(category.toJson()..remove('id'));
      return doc.id;
    });
  }

  Future<void> update(Category category) {
    return guardedWrite(
      'categories.update',
      () =>
          _categories.doc(category.id).update(category.toJson()..remove('id')),
    );
  }

  Future<void> delete(String categoryId) {
    return guardedWrite(
      'categories.delete',
      () => _categories.doc(categoryId).delete(),
    );
  }
}
