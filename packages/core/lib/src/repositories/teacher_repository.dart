import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/teacher.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `teachers/{teacherId}` (PRD FR-5.x, AR-3.x).
class TeacherRepository with RepoGuard {
  TeacherRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _teachers =>
      _firestore.collection(FirestoreCollections.teachers);

  /// Active teachers ordered by admin `sortOrder`, for the onboarding
  /// Teacher Selection screen and the ⊕ picker sheet (FR-5.3).
  Stream<List<Teacher>> watchActiveTeachers() {
    return guardedStream(
      'teachers.watchActive',
      _teachers
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((d) => Teacher.fromJson({...d.data(), 'id': d.id}))
                .toList(),
          ),
    );
  }

  Stream<List<Teacher>> watchAll() {
    return guardedStream(
      'teachers.watchAll',
      _teachers.orderBy('sortOrder').snapshots().map(
            (snap) => snap.docs
                .map((d) => Teacher.fromJson({...d.data(), 'id': d.id}))
                .toList(),
          ),
    );
  }

  Future<Teacher?> getById(String id) {
    return guardedRead('teachers.getById', () async {
      final snap = await _teachers.doc(id).get();
      if (!snap.exists) return null;
      return Teacher.fromJson({...snap.data()!, 'id': id});
    });
  }

  Future<void> createWithId(Teacher teacher) {
    return guardedWrite(
      'teachers.createWithId',
      () => _teachers.doc(teacher.id).set(teacher.toJson()..remove('id')),
    );
  }

  Future<List<Teacher>> getActiveTeachers() {
    return guardedRead('teachers.getActive', () async {
      final snap = await _teachers
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();
      return snap.docs
          .map((d) => Teacher.fromJson({...d.data(), 'id': d.id}))
          .toList();
    });
  }

  // --- Admin write operations ---

  Future<String> create(Teacher teacher) {
    return guardedWrite('teachers.create', () async {
      final doc = await _teachers.add(teacher.toJson()..remove('id'));
      return doc.id;
    });
  }

  Future<void> update(Teacher teacher) {
    return guardedWrite(
      'teachers.update',
      () => _teachers.doc(teacher.id).update(teacher.toJson()..remove('id')),
    );
  }

  Future<void> delete(String teacherId) {
    return guardedWrite(
      'teachers.delete',
      () => _teachers.doc(teacherId).delete(),
    );
  }
}
