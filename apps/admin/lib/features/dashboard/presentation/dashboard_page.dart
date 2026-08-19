import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../auth/application/admin_session.dart';
import '../application/dashboard_providers.dart';

/// Landing desk with KPI cards, per-type published counts, engagement totals
/// and a recent-activity feed sourced from the audit log (T1.30, AR-2.1–2.3).
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(adminRoleProvider).valueOrNull ?? '';
    final email = ref.watch(adminAuthUserProvider)?.email ?? '';
    final async = ref.watch(dashboardSnapshotProvider);

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            AdminStrings.dashboard.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 2.2,
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email.isEmpty ? 'Welcome.' : 'Welcome, $email',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role.isEmpty ? '' : AdminRole.label(role),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => ErrorState(message: e.toString()),
            data: (snap) => _DashboardBody(snap: snap),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snap});

  final DashboardSnapshot snap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _KpiCard(label: 'Users', value: '${snap.totalUsers}'),
            _KpiCard(label: 'DAU', value: '${snap.dau}'),
            _KpiCard(label: 'New today', value: '${snap.newUsersToday}'),
            _KpiCard(
              label: 'Published items',
              value: '${snap.totalPublishedItems}',
            ),
            _KpiCard(label: 'Downloads', value: '${snap.totalDownloads}'),
            _KpiCard(label: 'Shares', value: '${snap.totalShares}'),
            _KpiCard(label: 'Plays', value: '${snap.totalPlays}'),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Published items by type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final entry in snap.itemCountByType.entries)
              _MiniStat(label: entry.key, value: '${entry.value}'),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Recent activity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (snap.recentActivity.isEmpty)
          const Text(AdminStrings.kpiPending)
        else
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                for (final log in snap.recentActivity)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 18),
                    title: Text('${log.action} · ${log.entityType}/${log.entityId}'),
                    subtitle: Text(
                      log.actorEmail ?? (log.actorUid.isEmpty ? 'system' : log.actorUid),
                    ),
                    trailing: Text(_when(log.createdAt)),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _when(DateTime? stamp) {
    if (stamp == null) return '';
    final l = stamp.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text('$label: $value'),
      ),
    );
  }
}
