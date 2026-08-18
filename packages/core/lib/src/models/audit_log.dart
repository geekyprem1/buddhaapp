import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

/// `auditLogs/{logId}` — written only by Cloud Functions, never directly
/// by a client (Architecture §7). Records who changed what.
@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    required String actorUid,
    String? actorEmail,

    /// create | update | delete | publish | unpublish | block | unblock
    required String action,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    @TimestampConverter() DateTime? createdAt,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);
}
