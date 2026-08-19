import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Newest audit entries, optionally narrowed to one `entityType` server-side
/// (that filter has a composite index — `entityType ASC, createdAt DESC`).
/// Actor / date / text narrowing is done client-side on this page to avoid
/// needing an index per filter combination (AR-1.5, T1.29).
final adminAuditLogsProvider =
    FutureProvider.family<List<AuditLog>, String?>((ref, entityType) {
  return ref.watch(auditRepositoryProvider).fetchPage(
        entityType: entityType,
        pageSize: 200,
      );
});
