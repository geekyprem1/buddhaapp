import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/firestore_collections.dart';
import '../models/app_user.dart';
import '../models/category.dart';
import '../models/content_item.dart';
import '../models/teacher.dart';
import '../models/video.dart';
import '../models/wisdom.dart';
import '../repositories/admin_user_repository.dart';
import '../repositories/audit_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/config_repository.dart';
import '../repositories/contact_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/events_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/progress_repository.dart';
import '../repositories/static_page_repository.dart';
import '../repositories/teacher_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart';
import '../repositories/wisdom_repository.dart';
import '../services/admin_functions_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_functions_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

part 'core_providers.g.dart';

// --- Singletons ---

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService();

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepository();

@Riverpod(keepAlive: true)
ContactRepository contactRepository(Ref ref) => ContactRepository();

@Riverpod(keepAlive: true)
AuthFunctionsService authFunctionsService(Ref ref) => AuthFunctionsService();

@Riverpod(keepAlive: true)
EventsRepository eventsRepository(Ref ref) => EventsRepository();

@Riverpod(keepAlive: true)
TeacherRepository teacherRepository(Ref ref) => TeacherRepository();

@Riverpod(keepAlive: true)
WisdomRepository wisdomRepository(Ref ref) => WisdomRepository();

@Riverpod(keepAlive: true)
VideoRepository videoRepository(Ref ref) => VideoRepository();

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) => CategoryRepository();

@Riverpod(keepAlive: true)
ConfigRepository configRepository(Ref ref) => ConfigRepository();

@Riverpod(keepAlive: true)
StaticPageRepository staticPageRepository(Ref ref) => StaticPageRepository();

@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) => ProgressRepository();

@Riverpod(keepAlive: true)
AuditRepository auditRepository(Ref ref) => AuditRepository();

@Riverpod(keepAlive: true)
AdminUserRepository adminUserRepository(Ref ref) => AdminUserRepository();

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository();

@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) => StorageService();

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

@Riverpod(keepAlive: true)
AdminFunctionsService adminFunctionsService(Ref ref) => AdminFunctionsService();

/// One [ContentRepository] instance per collection name, cached for the
/// lifetime of the app (Architecture §11 generic content module).
@Riverpod(keepAlive: true)
ContentRepository contentRepository(Ref ref, String collectionName) {
  return ContentRepository(collectionName: collectionName);
}

// --- Auth state ---

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges();
}

/// The signed-in user's Firestore profile, kept live via a snapshot
/// listener. `null` while signed out or before the document exists.
@riverpod
Stream<AppUser?> currentAppUser(Ref ref) {
  final authValue = ref.watch(authStateProvider);
  final uid = authValue.valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid);
}

/// Active teachers for onboarding / filter chips (FR-5.3).
@riverpod
Stream<List<Teacher>> activeTeachers(Ref ref) {
  return ref.watch(teacherRepositoryProvider).watchActiveTeachers();
}

/// Active Today Wisdom cards ordered by `sortOrder`. The home hero picks
/// one per day from this list.
@riverpod
Stream<List<Wisdom>> activeWisdoms(Ref ref) {
  return ref.watch(wisdomRepositoryProvider).watchActiveWisdoms();
}

/// Active YouTube videos ordered by `sortOrder`, for the app's Videos screen.
@riverpod
Stream<List<Video>> activeVideos(Ref ref) {
  return ref.watch(videoRepositoryProvider).watchActiveVideos();
}

/// Active categories for one content module, ordered by `sortOrder`.
/// Powers the category chip row under the teacher row on every mobile
/// content list screen — admin-created categories appear here
/// automatically (PRD FR-7.10, FR-10.6).
@riverpod
Stream<List<Category>> activeCategories(Ref ref, String module) {
  return ref.watch(categoryRepositoryProvider).watchByModule(module);
}

/// Direct Firestore instance, exposed for edge cases (e.g. cursor-based
/// pagination controllers that need to hold a raw `DocumentSnapshot`).
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

/// Collection name constants re-exported for convenience so feature code
/// doesn't need a separate import just to pick which content repository to
/// request.
abstract class ContentCollections {
  ContentCollections._();
  static const wallpapers = FirestoreCollections.wallpapers;
  static const ringtones = FirestoreCollections.ringtones;
  static const songs = FirestoreCollections.songs;
  static const vandanas = FirestoreCollections.vandanas;
  static const meditations = FirestoreCollections.meditations;
  static const chantings = FirestoreCollections.chantings;
  static const statuses = FirestoreCollections.statuses;
  static const prarthanas = FirestoreCollections.prarthanas;

  /// Maps a [ContentType] value to its Firestore collection name. Returns
  /// `null` for an unknown type.
  static String? forType(String type) => switch (type) {
        ContentType.wallpaper => wallpapers,
        ContentType.ringtone => ringtones,
        ContentType.song => songs,
        ContentType.vandana => vandanas,
        ContentType.meditation => meditations,
        ContentType.chanting => chantings,
        ContentType.status => statuses,
        ContentType.prarthana => prarthanas,
        _ => null,
      };
}
