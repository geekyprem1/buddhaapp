import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/notification_campaign.dart';

/// Reads/writes `notifications/{campaignId}` drafts. Send / schedule goes
/// through `sendNotification` so delivery stats stay Function-owned (AR-6).
class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _firestore.collection(FirestoreCollections.notifications);

  NotificationCampaign _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return NotificationCampaign.fromJson({...doc.data()!, 'id': doc.id});
  }

  String nextId() => _campaigns.doc().id;

  Stream<List<NotificationCampaign>> watchAll({int limit = 100}) {
    return _campaigns
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Future<NotificationCampaign?> getById(String id) async {
    final snap = await _campaigns.doc(id).get();
    if (!snap.exists) return null;
    return _fromDoc(snap);
  }

  Future<String> saveDraft({
    String? id,
    required String title,
    required String body,
    String? imageUrl,
    String? deepLink,
    required String audience,
    required String createdBy,
  }) async {
    final ref = id == null || id.isEmpty ? _campaigns.doc() : _campaigns.doc(id);
    final existing = await ref.get();
    await ref.set({
      'title': title.trim(),
      'body': body.trim(),
      'imageUrl': imageUrl,
      'deepLink': deepLink,
      'audience': audience,
      'status': NotificationCampaignStatus.draft,
      'deliveredCount': existing.data()?['deliveredCount'] ?? 0,
      'openedCount': existing.data()?['openedCount'] ?? 0,
      'createdBy': existing.data()?['createdBy'] ?? createdBy,
      'createdAt': existing.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
      'scheduledAt': FieldValue.delete(),
      'error': null,
    }, SetOptions(merge: true));
    return ref.id;
  }

  Future<void> cancelSchedule(String id) {
    return _campaigns.doc(id).update({
      'status': NotificationCampaignStatus.draft,
      'scheduledAt': FieldValue.delete(),
    });
  }
}
