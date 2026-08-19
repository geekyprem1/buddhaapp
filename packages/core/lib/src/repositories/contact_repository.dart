import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';

/// Writes `contactMessages/{id}` from the in-app Contact Us form (FR-14.5).
class ContactRepository {
  ContactRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submit({
    required String uid,
    required String subject,
    required String message,
  }) {
    return _firestore.collection(FirestoreCollections.contactMessages).add({
      'uid': uid,
      'subject': subject.trim(),
      'message': message.trim(),
      'createdAt': DateTime.now(),
    });
  }
}
