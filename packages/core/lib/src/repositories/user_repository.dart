import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../constants/firestore_collections.dart';
import '../models/app_user.dart';

/// Reads and writes `users/{uid}` (Architecture §6.2).
///
/// Kept as a thin wrapper over Firestore so both the mobile app and the
/// admin panel talk to the same shape and the same collection name.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  /// Streams the user document, or `null` if it doesn't exist yet.
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromJson({...snap.data()!, 'uid': uid});
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromJson({...snap.data()!, 'uid': uid});
  }

  /// Creates the user document on first sign-in (FR-2.4). No-ops if a
  /// document already exists for this uid — the Cloud Function
  /// `onUserCreate` normally does the seeding, but the client creates it
  /// too as a safety net so onboarding never blocks on Function latency.
  Future<void> ensureUserDocument({
    required String uid,
    required String authMethod,
    String? phone,
    String? email,
    String? name,
  }) async {
    final doc = _users.doc(uid);
    final existing = await doc.get();
    if (existing.exists) return;

    final user = AppUser(
      uid: uid,
      name: name ?? '',
      phone: phone,
      email: email,
      authMethod: authMethod,
      onboardingStep: AppConstants.onboardingStepLanguage,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    await doc.set(user.toJson()..remove('uid'));
  }

  Future<void> updateLanguage(String uid, String languageCode) {
    return _users.doc(uid).update({
      'language': languageCode,
      'onboardingStep': AppConstants.onboardingStepPersonInfo,
    });
  }

  Future<void> updatePersonInfo(
    String uid, {
    required String name,
    required String phone,
    String? email,
  }) {
    return _users.doc(uid).update({
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'onboardingStep': AppConstants.onboardingStepTeacher,
    });
  }

  Future<void> updateSelectedTeachers(String uid, List<String> teacherIds) {
    return _users.doc(uid).update({
      'selectedTeachers': teacherIds,
      'onboardingStep': AppConstants.onboardingStepComplete,
    });
  }

  /// Adds a single teacher to the existing selection without touching
  /// onboarding step — used by the ⊕ chip on content screens (FR-5.7).
  Future<void> addSelectedTeacher(String uid, String teacherId) {
    return _users.doc(uid).update({
      'selectedTeachers': FieldValue.arrayUnion([teacherId]),
    });
  }

  Future<void> touchLastActive(String uid) {
    return _users.doc(uid).update({'lastActiveAt': DateTime.now()});
  }

  Future<void> updateDisplayName(String uid, String name) {
    return _users.doc(uid).update({'name': name});
  }

  Future<void> updatePhotoUrl(String uid, String photoUrl) {
    return _users.doc(uid).update({'photoUrl': photoUrl});
  }

  /// Profile language change — does **not** rewind onboarding.
  Future<void> setPreferredLanguage(String uid, String languageCode) {
    return _users.doc(uid).update({'language': languageCode});
  }

  Future<void> updateProfile(
    String uid, {
    String? name,
    String? email,
  }) {
    return _users.doc(uid).update({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });
  }

  Future<void> setNotificationPrefs(String uid, NotificationPrefs prefs) {
    return _users.doc(uid).update({'notificationPrefs': prefs.toJson()});
  }

  Future<void> addFcmToken(String uid, String token) {
    return _users.doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> removeFcmToken(String uid, String token) {
    return _users.doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  Future<void> submitDeletionRequest(String uid) {
    return _firestore
        .collection(FirestoreCollections.deletionRequests)
        .doc(uid)
        .set({
      'uid': uid,
      'requestedAt': DateTime.now(),
      'status': 'pending',
    });
  }

  /// Admin deletion-request queue (T1.24, AR-5.5). Each doc id is the
  /// requesting user's uid.
  Future<List<Map<String, dynamic>>> fetchDeletionRequests() async {
    final snap = await _firestore
        .collection(FirestoreCollections.deletionRequests)
        .orderBy('requestedAt', descending: true)
        .get();
    return snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
  }

  // --- Admin panel (AR-5.1–5.3, T1.23) ---

  /// Newest-first page for the admin users table. Cursor pagination via
  /// [startAfter] (the last document of the previous page).
  Future<List<AppUser>> fetchAdminPage({
    int pageSize = 100,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    var query = _users.orderBy('createdAt', descending: true).limit(pageSize);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snap = await query.get();
    return snap.docs
        .map((d) => AppUser.fromJson({...d.data(), 'uid': d.id}))
        .toList();
  }

  /// Block or unblock a user (AR-5.3). Security rules restrict flipping
  /// `isBlocked` to admin roles — the owner's own writes are rejected if they
  /// touch this field (Architecture §7).
  Future<void> setBlocked(String uid, bool blocked) {
    return _users.doc(uid).update({'isBlocked': blocked});
  }
}
