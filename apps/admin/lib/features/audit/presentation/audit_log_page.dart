import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/audit_providers.dart';

/// Audit log viewer (T1.29, AR-1.5). Lists `auditLogs` newest-first with an
/// entity-type filter (server-side, indexed) plus client-side actor/action/id
/// search and a time-range narrowing. Each row expands to a before/after diff.
class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

/// Entity types that Functions / callables actually write audit entries for.
const _entityTypes = <String>[
  'wallpapers',
  'ringtones',
  'songs',
  'meditations',
  'statuses',
  'prarthanas',
  'adminUsers',
  'notifications',
];

enum _Range { all, h24, d7, d30 }

class _AuditLogPageState extends ConsumerState<AuditLogPage> {
  String? _entityType;
  String _query = '';
  _Range _range = _Range.all;

  DateTime? get _since {
    final now = DateTime.now();
    return switch (_range) {
      _Range.all => null,
      _Range.h24 => now.subtract(const Duration(hours: 24)),
      _Range.d7 => now.subtract(const Duration(days: 7)),
      _Range.d30 => now.subtract(const Duration(days: 30)),
    };
  }

  bool _matches(AuditLog log) {
    final since = _since;
    if (since != null && (log.createdAt == null || log.createdAt!.isBefore(since))) {
      return false;
    }
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return (log.actorEmail ?? '').toLowerCase().contains(q) ||
        log.actorUid.toLowerCase().contains(q) ||
        log.entityId.toLowerCase().contains(q) ||
        log.action.toLowerCase().contains(q) ||
        log.entityType.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminAuditLogsProvider(_entityType));
    return AdminPageFrame(
      title: AdminStrings.audit,
      actions: [
        IconButton(
          tooltip: AdminStrings.auditRefresh,
          onPressed: () => ref.invalidate(adminAuditLogsProvider(_entityType)),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: AdminStrings.auditSearchHint,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _entityType,
                        decoration: const InputDecoration(
                          labelText: AdminStrings.auditEntity,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(AdminStrings.auditAllEntities),
                          ),
                          for (final t in _entityTypes)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setState(() => _entityType = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<_Range>(
                        initialValue: _range,
                        decoration: const InputDecoration(
                          labelText: AdminStrings.auditRange,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: _Range.all,
                            child: Text(AdminStrings.auditRangeAll),
                          ),
                          DropdownMenuItem(
                            value: _Range.h24,
                            child: Text(AdminStrings.auditRange24h),
                          ),
                          DropdownMenuItem(
                            value: _Range.d7,
                            child: Text(AdminStrings.auditRange7d),
                          ),
                          DropdownMenuItem(
                            value: _Range.d30,
                            child: Text(AdminStrings.auditRange30d),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _range = v ?? _Range.all),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (logs) {
                final rows = logs.where(_matches).toList();
                if (rows.isEmpty) {
                  return const EmptyState(message: AdminStrings.auditEmpty);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _AuditRow(log: rows[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Theme(
        // Remove the default divider lines on the ExpansionTile.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: _ActionBadge(action: log.action),
          title: Text(
            '${log.action} · ${log.entityType}/${log.entityId}',
            style: theme.textTheme.titleSmall,
          ),
          subtitle: Text(
            '${AdminStrings.auditBy} ${log.actorEmail ?? (log.actorUid.isEmpty ? AdminStrings.auditSystem : log.actorUid)}'
            '${_when(log.createdAt)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          children: [_DiffView(log: log)],
        ),
      ),
    );
  }

  String _when(DateTime? stamp) {
    if (stamp == null) return '';
    final l = stamp.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return ' · ${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

class _DiffView extends StatelessWidget {
  const _DiffView({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final before = log.before ?? const {};
    final after = log.after ?? const {};
    if (before.isEmpty && after.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(AdminStrings.auditNoChange),
      );
    }
    final keys = {...before.keys, ...after.keys}.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            SizedBox(width: 140, child: Text('Field')),
            Expanded(child: Text(AdminStrings.auditBefore)),
            Expanded(child: Text(AdminStrings.auditAfter)),
          ],
        ),
        const Divider(),
        for (final key in keys)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    key,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(child: Text(_fmt(before[key]))),
                Expanded(child: Text(_fmt(after[key]))),
              ],
            ),
          ),
      ],
    );
  }

  String _fmt(Object? v) {
    if (v == null) return '—';
    if (v is Map || v is List) return v.toString();
    return '$v';
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (action) {
      'create' => (AppColors.success, Icons.add),
      'update' || 'set_role' => (AppColors.accent, Icons.edit_outlined),
      'delete' || 'revoke_role' => (AppColors.error, Icons.delete_outline),
      _ when action.startsWith('notification') => (
          AppColors.primary,
          Icons.campaign_outlined,
        ),
      _ => (AppColors.textSecondary, Icons.history),
    };
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
