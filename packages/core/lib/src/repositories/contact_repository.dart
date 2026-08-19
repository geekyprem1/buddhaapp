import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/contact_message.dart';

/// Writes `contactMessages/{id}` from the in-app Contact Us form (FR-14.5);
/// reads/resolves for the admin inbox (T1.31). Only admins can read this
/// collection at all (Architecture §7) — the mobile app never lists messages.
class ContactRepository {
  ContactRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection(FirestoreCollections.contactMessages);

  Future<void> submit({
    required String uid,
    required String subject,
    required String message,
  }) {
    return _messages.add({
      'uid': uid,
      'subject': subject.trim(),
      'message': message.trim(),
      'status': ContactMessageStatus.open,
      'createdAt': DateTime.now(),
    });
  }

  /// Newest-first page for the admin inbox.
  Future<List<ContactMessage>> fetchAdminPage({int pageSize = 200}) async {
    final snap = await _messages
        .orderBy('createdAt', descending: true)
        .limit(pageSize)
        .get();
    return snap.docs
        .map((d) => ContactMessage.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<void> markResolved(String id, String adminUid) {
    return _messages.doc(id).update({
      'status': ContactMessageStatus.resolved,
      'resolvedAt': DateTime.now(),
      'resolvedBy': adminUid,
    });
  }

  Future<void> reopen(String id) {
    return _messages.doc(id).update({
      'status': ContactMessageStatus.open,
      'resolvedAt': null,
      'resolvedBy': null,
    });
  }
}
