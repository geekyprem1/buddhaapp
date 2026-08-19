import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_collections.dart';
import '../models/audit_log.dart';

/// Reads `auditLogs/{logId}`. Clients can never write this collection —
/// Architecture §7 reserves writes for Cloud Functions.
class AuditRepository {
  AuditRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection(FirestoreCollections.auditLogs);

  AuditLog _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AuditLog.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Newest-first page, optionally filtered by entity type or actor.
  Future<List<AuditLog>> fetchPage({
    String? entityType,
    String? actorUid,
    int pageSize = AppConstants.defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _logs.orderBy(
      'createdAt',
      descending: true,
    );
    if (entityType != null) {
      query = query.where('entityType', isEqualTo: entityType);
    }
    if (actorUid != null) {
      query = query.where('actorUid', isEqualTo: actorUid);
    }
    query = query.limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snap = await query.get();
    return snap.docs.map(_fromDoc).toList();
  }
}
