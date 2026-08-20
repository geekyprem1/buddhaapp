/// Cross-cutting literal values referenced by both the mobile app and the
/// admin panel. Keeping them here means a rename (e.g. app id, storage
/// bucket path prefix) never needs a find-and-replace across two apps.
abstract class AppConstants {
  AppConstants._();

  static const appName = 'Dhamma Path';
  static const tagline = 'Power in Every Voice';

  static const defaultLanguageCode = 'en';
  static const supportedLanguageCodes = <String>['en', 'hi', 'mr'];

  /// Onboarding step markers stored on `users/{uid}.onboardingStep`.
  static const onboardingStepLanguage = 'language';
  static const onboardingStepPersonInfo = 'person_info';
  static const onboardingStepTeacher = 'teacher';
  static const onboardingStepComplete = 'complete';

  static const contentStatusDraft = 'draft';
  static const contentStatusPublished = 'published';
  static const contentStatusUnpublished = 'unpublished';
  static const contentStatusArchived = 'archived';

  static const adminRoleSuperAdmin = 'super_admin';
  static const adminRoleContentManager = 'content_manager';
  static const adminRoleModerator = 'moderator';

  /// All Cloud Functions are pinned here (Architecture §8).
  static const functionsRegion = 'asia-south1';

  /// Callable Function names.
  static const fnSetAdminRole = 'setAdminRole';
  static const fnSendNotification = 'sendNotification';
  static const fnExportUsersCsv = 'exportUsersCsv';
  static const fnProcessDeletionRequest = 'processDeletionRequest';
  static const fnGuardOtpAbuse = 'guardOtpAbuse';

  /// Firestore disk cache cap (Architecture §10 / T2.1 — 40 MB).
  static const firestoreCacheSizeBytes = 40 * 1024 * 1024;

  /// Default page size for paginated content queries (Architecture §10).
  static const defaultPageSize = 20;

  /// Firestore `arrayContainsAny` hard cap.
  static const maxArrayContainsAnyValues = 30;

  static const galleryAlbumName = 'Dhamma Path';
}
