import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

/// `adminUsers/{uid}` — the role is duplicated onto an Auth custom claim
/// so security rules can check it without an extra document read
/// (Architecture §6.2).
@freezed
class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String uid,
    required String email,
    @Default('') String name,

    /// super_admin | content_manager | moderator
    required String role,
    @Default(true) bool isActive,
    String? createdBy,
    @TimestampConverter() DateTime? lastLoginAt,
    @TimestampConverter() DateTime? createdAt,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

abstract class AdminRole {
  AdminRole._();

  static const superAdmin = 'super_admin';
  static const contentManager = 'content_manager';
  static const moderator = 'moderator';

  static const all = <String>[superAdmin, contentManager, moderator];

  /// Reads `role` out of an ID-token claims map. Web interop sometimes
  /// yields a non-Dart [String], so this never uses a hard cast.
  static String? fromClaims(Map<String, dynamic>? claims) {
    final raw = claims?['role'];
    if (raw == null) return null;
    return raw.toString();
  }

  static bool isValid(String? role) => all.contains(role);

  static bool isAdmin(String? role) => isValid(role);

  static bool isSuperAdmin(String? role) => role == superAdmin;

  /// User table, CSV export, admin-role changes, hard-delete.
  static bool canManageUsers(String? role) => role == superAdmin;

  /// `config/*` and static pages (Architecture §7).
  static bool canEditConfig(String? role) => role == superAdmin;

  /// Full content / teacher / category CRUD.
  static bool canEditContent(String? role) =>
      role == superAdmin || role == contentManager;

  /// Publish / unpublish / metadata — every admin role.
  static bool canModerate(String? role) => isAdmin(role);

  static bool canSendNotifications(String? role) => canEditContent(role);

  static String label(String role) => switch (role) {
    superAdmin => 'Super Admin',
    contentManager => 'Content Manager',
    moderator => 'Moderator',
    _ => role,
  };
}
