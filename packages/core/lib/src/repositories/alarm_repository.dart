import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/alarm.dart';

/// `users/{uid}/alarms/{id}` (Architecture §9.3). Hive on the device is
/// still the fire-time source of truth; this repo is the cloud mirror.
class AlarmRepository {
  AlarmRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore
      .collection(FirestoreCollections.users)
      .doc(uid)
      .collection(FirestoreCollections.alarms);

  Stream<List<Alarm>> watch(String uid) {
    return _col(uid).snapshots().map((snap) {
      final items = snap.docs
          .map((d) => Alarm.fromJson({...d.data(), 'id': d.id}))
          .toList()
        ..sort((a, b) {
          final h = a.timeHour.compareTo(b.timeHour);
          return h != 0 ? h : a.timeMinute.compareTo(b.timeMinute);
        });
      return items;
    });
  }

  Future<void> upsert(String uid, Alarm alarm) {
    final data = Map<String, dynamic>.from(alarm.toJson())..remove('id');
    return _col(uid).doc(alarm.id).set(data);
  }

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
