import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../models/content_counters.dart';
import '../models/content_item.dart';
import '../utils/repo_guard.dart';

/// Generic, type-parameterised repository over any content collection
/// (wallpapers, ringtones, songs, vandanas, meditations, chantings,
/// statuses, prarthanas) — they share one document shape, so they share one
/// repository implementation (Architecture §6.2, §11 generic content module).
class ContentRepository with RepoGuard {
  ContentRepository({
    required String collectionName,
    FirebaseFirestore? firestore,
  })  : _collectionName = collectionName,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// How many documents the admin desk loads per content collection. The old
  /// 100 cap silently hid items once a collection grew past it (wallpapers is
  /// at 146 in production), which read as "my upload disappeared".
  static const adminPageSize = 1000;

  /// Fields the admin content form never edits. A form-built [ContentItem]
  /// leaves them null/empty, so writing them back would erase the stored
  /// value — this is what wiped `createdAt` off most production content.
  static const _preserveWhenEmpty = <String>{
    'createdAt',
    'createdBy',
    'publishAt',
    'expireAt',
    'deletedAt',
    'teacherIds',
  };

  final String _collectionName;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  ContentItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ContentItem.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Tolerant decode for admin listings. A half-written document — e.g. a
  /// `onMediaUpload` patch that landed on an item deleted mid-upload, leaving
  /// only `mediaUrl`/`thumbUrl` and no `type`/`title` — cannot be decoded.
  /// Skipping it keeps one bad row from failing the entire list.
  ContentItem? _tryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() == null) return null;
    try {
      return _fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  /// Admin ordering, applied in Dart rather than by Firestore.
  ///
  /// A Firestore `orderBy('sortOrder')` silently DROPS documents that have no
  /// `sortOrder` field, and combined with a page limit it also pushed every
  /// newly created item (which starts at the bottom of the order) outside the
  /// window — so a freshly uploaded wallpaper looked like it had vanished.
  /// Sorting client-side means every fetched document is always listed.
  List<ContentItem> _sortedForAdmin(List<ContentItem> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final bySort = b.sortOrder.compareTo(a.sortOrder);
      if (bySort != 0) return bySort;
      // Tie-break newest-touched first so items sharing a sortOrder (e.g. the
      // default 0) still surface the most recent work at the top.
      final at = a.updatedAt ?? a.createdAt;
      final bt = b.updatedAt ?? b.createdAt;
      if (at != null && bt != null) return bt.compareTo(at);
      if (bt != null) return 1;
      if (at != null) return -1;
      return a.id.compareTo(b.id);
    });
    return sorted;
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
  }) {
    return guardedRead('content.fetchPublishedPage', () async {
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
    });
  }

  String newId() => _collection.doc().id;

  /// `sortOrder` to give a brand-new item so it lands at the TOP of every
  /// list (admin + app both order `sortOrder` DESCENDING). Without this a new
  /// item defaults to 0 and sinks below everything already ordered.
  Future<int> nextSortOrder() {
    return guardedRead('content.nextSortOrder', () async {
      final snap = await _collection
          .orderBy('sortOrder', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return 1;
      final raw = snap.docs.first.data()['sortOrder'];
      final top = raw is num ? raw.toInt() : 0;
      return top + 1;
    });
  }

  /// Admin list — every status, highest `sortOrder` first.
  ///
  /// The query itself is unordered on purpose (see [_sortedForAdmin]); status
  /// filtering and ordering both happen client-side so nothing is hidden by a
  /// missing field or a missing composite index.
  Future<List<ContentItem>> fetchAdminPage({
    int pageSize = adminPageSize,
  }) {
    return guardedRead('content.fetchAdminPage', () async {
      final snap = await _collection.limit(pageSize).get();
      return _sortedForAdmin(
        snap.docs.map(_tryFromDoc).whereType<ContentItem>().toList(),
      );
    });
  }

  /// Live admin list. Used so `onMediaUpload`'s `thumbUrl` / `mediaUrl` patch
  /// shows up without a manual refresh.
  Stream<List<ContentItem>> watchAdminPage({int pageSize = adminPageSize}) {
    return guardedStream(
      'content.watchAdminPage',
      _collection.limit(pageSize).snapshots().map(
            (snap) => _sortedForAdmin(
              snap.docs.map(_tryFromDoc).whereType<ContentItem>().toList(),
            ),
          ),
    );
  }

  Future<ContentItem?> getById(String id) {
    return guardedRead('content.getById', () async {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  // --- Admin write operations ---

  Future<String> create(ContentItem item) {
    return guardedWrite('content.create', () async {
      final doc = await _collection.add(item.toJson()..remove('id'));
      return doc.id;
    });
  }

  Future<void> createWithId(ContentItem item) {
    final data = item.toJson()
      ..remove('id')
      ..remove('counters')
      ..['createdAt'] = DateTime.now()
      ..['updatedAt'] = DateTime.now();
    return guardedWrite(
      'content.createWithId',
      () => _collection.doc(item.id).set(data, SetOptions(merge: true)),
    );
  }

  Future<void> update(
    ContentItem item, {
    Iterable<String> unchangedKeys = const [],
  }) {
    final data = item.toJson()
      ..remove('id')
      ..remove('counters')
      ..['updatedAt'] = DateTime.now();
    for (final key in unchangedKeys) {
      data.remove(key);
    }
    // Drop create-time / lifecycle fields the form does not own rather than
    // overwriting them with the null (or empty list) a form-built item carries.
    for (final key in _preserveWhenEmpty) {
      final value = data[key];
      if (value == null || (value is List && value.isEmpty)) {
        data.remove(key);
      }
    }
    return guardedWrite(
      'content.update',
      () => _collection.doc(item.id).update(data),
    );
  }

  /// Duplicates an item as a new draft (T1.22, AR-3.8). Copies every field
  /// except identity/state — the clone always starts as an unpublished
  /// draft with fresh counters and no scheduling, so cloning can never
  /// accidentally publish or double-count engagement.
  Future<String> clone(ContentItem source) {
    return guardedWrite('content.clone', () async {
      final newId = _collection.doc().id;
      final cloned = source.copyWith(
        id: newId,
        status: ContentStatus.draft,
        counters: const ContentCounters(),
        publishAt: null,
        expireAt: null,
        deletedAt: null,
      );
      final data = cloned.toJson()
        ..remove('id')
        ..['createdAt'] = DateTime.now()
        ..['updatedAt'] = DateTime.now();
      await _collection.doc(newId).set(data);
      return newId;
    });
  }

  /// Reorders items within a category/list by rewriting `sortOrder` to each
  /// item's index in [orderedIds] (T1.22, AR-3.9), highest first (matches the
  /// existing `sortOrder DESCENDING` list query).
  Future<void> reorder(List<String> orderedIds) {
    return guardedWrite('content.reorder', () async {
      final batch = _collection.firestore.batch();
      final n = orderedIds.length;
      for (var i = 0; i < n; i++) {
        batch.update(_collection.doc(orderedIds[i]), {
          'sortOrder': n - i,
          'updatedAt': DateTime.now(),
        });
      }
      await batch.commit();
    });
  }

  Future<void> setStatus(String id, String status) {
    return guardedWrite(
      'content.setStatus',
      () => _collection.doc(id).update({
        'status': status,
        'updatedAt': DateTime.now(),
      }),
    );
  }

  /// Soft delete: records the timestamp AND flips status to `archived` so
  /// the item leaves all published list queries (the security read rule is
  /// status-only — see firestore.rules `contentCanRead`).
  Future<void> restore(String id) {
    return guardedWrite(
      'content.restore',
      () => _collection.doc(id).update({
        'deletedAt': null,
        'status': ContentStatus.draft,
        'updatedAt': DateTime.now(),
      }),
    );
  }

  Future<void> softDelete(String id) {
    return guardedWrite(
      'content.softDelete',
      () => _collection.doc(id).update({
        'deletedAt': DateTime.now(),
        'status': ContentStatus.archived,
        'updatedAt': DateTime.now(),
      }),
    );
  }

  Future<void> hardDelete(String id) {
    return guardedWrite(
      'content.hardDelete',
      () => _collection.doc(id).delete(),
    );
  }
}
