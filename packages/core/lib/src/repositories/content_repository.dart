import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../models/content_item.dart';

/// Generic, type-parameterised repository over any of the six content
/// collections (wallpapers, ringtones, songs, meditations, statuses,
/// prarthanas) — they share one document shape, so they share one
/// repository implementation (Architecture §6.2, §11 generic content module).
class ContentRepository {
  ContentRepository({
    required String collectionName,
    FirebaseFirestore? firestore,
  }) : _collectionName = collectionName,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collectionName;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  ContentItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ContentItem.fromJson({...doc.data()!, 'id': doc.id});
  }

  Query<Map<String, dynamic>> _publishedQuery({
    String? teacherId,
    String? categoryId,
    bool orderBySort = true,
  }) {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: 'published');
    if (orderBySort) {
      query = query.orderBy('sortOrder', descending: true);
    }
    if (teacherId != null) {
      query = query.where('teacherIds', arrayContains: teacherId);
    }
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query;
  }

  /// First page of published content, optionally filtered by teacher and/or
  /// category (Architecture §5.1, §10 pagination). Pass [startAfter] (the
  /// last document of the previous page) to fetch subsequent pages.
  Future<List<ContentItem>> fetchPublishedPage({
    String? teacherId,
    String? categoryId,
    int pageSize = AppConstants.defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final snap = await fetchPublishedPageRaw(
      teacherId: teacherId,
      categoryId: categoryId,
      pageSize: pageSize,
      startAfter: startAfter,
    );
    return snap.docs.map(_fromDoc).toList();
  }

  /// Raw query builder access for callers (e.g. Riverpod controllers) that
  /// need the last [DocumentSnapshot] for cursor pagination rather than
  /// just the decoded models.
  Future<QuerySnapshot<Map<String, dynamic>>> fetchPublishedPageRaw({
    String? teacherId,
    String? categoryId,
    int pageSize = AppConstants.defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _publishedQuery(
      teacherId: teacherId,
      categoryId: categoryId,
    ).limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    try {
      return await query.get();
    } on FirebaseException catch (e) {
      // Missing composite index (statuses originally had no
      // status+sortOrder index). Equality-only still works.
      if (e.code != 'failed-precondition' || startAfter != null) rethrow;
      return _publishedQuery(
        teacherId: teacherId,
        categoryId: categoryId,
        orderBySort: false,
      ).limit(pageSize).get();
    }
  }

  String newId() => _collection.doc().id;

  /// Admin list — every status, newest sort first. Status filter is applied
  /// client-side so we never wait on a missing composite index.
  Future<List<ContentItem>> fetchAdminPage({
    int pageSize = 100,
  }) async {
    final snap = await _collection
        .orderBy('sortOrder', descending: true)
        .limit(pageSize)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<ContentItem?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  // --- Admin write operations ---

  Future<String> create(ContentItem item) async {
    final doc = await _collection.add(item.toJson()..remove('id'));
    return doc.id;
  }

  Future<void> createWithId(ContentItem item) {
    final data = item.toJson()
      ..remove('id')
      ..['createdAt'] = DateTime.now()
      ..['updatedAt'] = DateTime.now();
    return _collection.doc(item.id).set(data);
  }

  Future<void> update(ContentItem item) {
    final data = item.toJson()
      ..remove('id')
      ..remove('counters')
      ..['updatedAt'] = DateTime.now();
    return _collection.doc(item.id).update(data);
  }

  Future<void> setStatus(String id, String status) {
    return _collection.doc(id).update({
      'status': status,
      'updatedAt': DateTime.now(),
    });
  }

  /// Soft delete: records the timestamp AND flips status to `archived` so
  /// the item leaves all published list queries (the security read rule is
  /// status-only — see firestore.rules `contentCanRead`).
  Future<void> restore(String id) {
    return _collection.doc(id).update({
      'deletedAt': null,
      'status': ContentStatus.draft,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> softDelete(String id) {
    return _collection.doc(id).update({
      'deletedAt': DateTime.now(),
      'status': ContentStatus.archived,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> hardDelete(String id) {
    return _collection.doc(id).delete();
  }
}
