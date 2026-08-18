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
}
