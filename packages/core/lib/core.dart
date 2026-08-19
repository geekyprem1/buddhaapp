/// Shared domain layer for Dhamma Path.
///
/// Contains models, constants, validators, repositories and services used
/// by both the mobile app (`apps/mobile`) and the admin panel (`apps/admin`).
/// See docs/ARCHITECTURE.md §2–§6.
library;

// Constants
export 'src/constants/app_constants.dart';
export 'src/constants/content_filter.dart';
export 'src/constants/firestore_collections.dart';

// Models
export 'src/models/admin_user.dart';
export 'src/models/alarm.dart';
export 'src/models/app_config.dart';
export 'src/models/app_user.dart';
export 'src/models/audit_log.dart';
export 'src/models/category.dart';
export 'src/models/content_counters.dart';
export 'src/models/content_item.dart';
export 'src/models/content_type_metas.dart';
export 'src/models/home_layout.dart';
export 'src/models/localised_text.dart';
export 'src/models/notification_campaign.dart';
export 'src/models/static_page.dart';
export 'src/models/teacher.dart';

// Utils
export 'src/utils/alarm_schedule.dart';
export 'src/utils/app_version.dart';
export 'src/utils/timestamp_converter.dart';

// Validators
export 'src/validators/field_validators.dart';

// Repositories
export 'src/repositories/admin_user_repository.dart';
export 'src/repositories/alarm_repository.dart';
export 'src/repositories/audit_repository.dart';
export 'src/repositories/category_repository.dart';
export 'src/repositories/config_repository.dart';
export 'src/repositories/contact_repository.dart';
export 'src/repositories/content_repository.dart';
export 'src/repositories/notification_repository.dart';
export 'src/repositories/static_page_repository.dart';
export 'src/repositories/teacher_repository.dart';
export 'src/repositories/user_repository.dart';

// Services
export 'src/services/admin_functions_service.dart';
export 'src/services/analytics_service.dart';
export 'src/services/auth_service.dart';
export 'src/services/storage_service.dart';

// Providers
export 'src/providers/core_providers.dart';
