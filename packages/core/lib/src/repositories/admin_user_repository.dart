import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/admin_user.dart';

/// Reads/writes `adminUsers/{uid}` (Architecture §6.2). Role changes must
/// go through the `setAdminRole` Function so the Auth custom claim stays
/// in lockstep with this document.
class AdminUserRepository {
  AdminUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _admins =>
      _firestore.collection(FirestoreCollections.adminUsers);

  AdminUser _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AdminUser.fromJson({...doc.data()!, 'uid': doc.id});
  }

  Future<AdminUser?> get(String uid) async {
    final snap = await _admins.doc(uid).get();
    if (!snap.exists) return null;
    return _fromDoc(snap);
  }

  Stream<AdminUser?> watch(String uid) {
    return _admins.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromDoc(snap);
    });
  }

  Future<List<AdminUser>> listAll() async {
    final snap = await _admins.orderBy('email').get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<void> upsert(AdminUser user) {
    return _admins.doc(user.uid).set(user.toJson()..remove('uid'));
  }

  Future<void> touchLastLogin(String uid) {
    return _admins.doc(uid).set({
      'lastLoginAt': DateTime.now(),
    }, SetOptions(merge: true));
  }
}
