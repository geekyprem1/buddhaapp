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

  /// First page of published content, optionally filtered by teacher and/or
  /// category (Architecture §5.1, §10 pagination). Pass [startAfter] (the
  /// last document of the previous page) to fetch subsequent pages.
  Future<List<ContentItem>> fetchPublishedPage({
    String? teacherId,
    String? categoryId,
    int pageSize = AppConstants.defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where('status', isEqualTo: 'published')
        .orderBy('sortOrder', descending: true);

    if (teacherId != null) {
      query = query.where('teacherIds', arrayContains: teacherId);
    }
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    query = query.limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
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
    Query<Map<String, dynamic>> query = _collection
        .where('status', isEqualTo: 'published')
        .orderBy('sortOrder', descending: true);

    if (teacherId != null) {
      query = query.where('teacherIds', arrayContains: teacherId);
    }
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    query = query.limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.get();
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

  Future<void> update(ContentItem item) {
    return _collection.doc(item.id).update(item.toJson()..remove('id'));
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
  Future<void> softDelete(String id) {
    return _collection.doc(id).update({
      'deletedAt': DateTime.now(),
      'status': ContentStatus.archived,
    });
  }

  Future<void> hardDelete(String id) {
    return _collection.doc(id).delete();
  }
}
