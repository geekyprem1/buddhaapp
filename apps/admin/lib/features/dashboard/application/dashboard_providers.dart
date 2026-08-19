import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/application/content_type_config.dart';

/// Aggregated KPI snapshot for the dashboard (T1.30, AR-2.1–2.3). Computed
/// client-side over the same admin-page reads every other list screen uses
/// (launch volumes — a few hundred rows per collection) rather than a
/// separate Function, so there is nothing new to keep in sync.
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.totalUsers,
    required this.dau,
    required this.newUsersToday,
    required this.itemCountByType,
    required this.totalDownloads,
    required this.totalShares,
    required this.totalPlays,
    required this.recentActivity,
  });

  final int totalUsers;
  final int dau;
  final int newUsersToday;
  final Map<String, int> itemCountByType;
  final int totalDownloads;
  final int totalShares;
  final int totalPlays;
  final List<AuditLog> recentActivity;

  int get totalPublishedItems =>
      itemCountByType.values.fold(0, (a, b) => a + b);
}

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  final auditRepo = ref.watch(auditRepositoryProvider);

  final users = await userRepo.fetchAdminPage(pageSize: 500);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  var dau = 0;
  var newToday = 0;
  for (final u in users) {
    if (u.lastActiveAt != null && u.lastActiveAt!.isAfter(startOfDay)) dau++;
    if (u.createdAt != null && u.createdAt!.isAfter(startOfDay)) newToday++;
  }

  final itemCounts = <String, int>{};
  var downloads = 0;
  var shares = 0;
  var plays = 0;
  for (final config in contentTypeConfigs) {
    final repo = ref.watch(contentRepositoryProvider(config.collection));
    final items = await repo.fetchAdminPage(pageSize: 500);
    itemCounts[config.label] =
        items.where((i) => i.status == ContentStatus.published).length;
    for (final item in items) {
      downloads += item.counters.downloads;
      shares += item.counters.shares;
      plays += item.counters.plays;
    }
  }

  final recent = await auditRepo.fetchPage(pageSize: 10);

  return DashboardSnapshot(
    totalUsers: users.length,
    dau: dau,
    newUsersToday: newToday,
    itemCountByType: itemCounts,
    totalDownloads: downloads,
    totalShares: shares,
    totalPlays: plays,
    recentActivity: recent,
  );
});
