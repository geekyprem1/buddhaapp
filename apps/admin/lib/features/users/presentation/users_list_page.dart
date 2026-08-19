import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../auth/application/admin_session.dart';
import '../application/users_providers.dart';

enum _StatusFilter { all, active, blocked }

/// Users table (T1.23, AR-5.1–5.3). Search + language/status filters over a
/// newest-first page; block/unblock is Super Admin only — the UI hides the
/// action for other roles but the real lock is the Firestore rule that lets
/// only an admin flip `isBlocked` (Architecture §7).
class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  String _query = '';
  String? _language;
  _StatusFilter _status = _StatusFilter.all;
  final _busy = <String>{};

  bool _matches(AppUser user) {
    if (_language != null && user.language != _language) return false;
    switch (_status) {
      case _StatusFilter.active:
        if (user.isBlocked) return false;
      case _StatusFilter.blocked:
        if (!user.isBlocked) return false;
      case _StatusFilter.all:
        break;
    }
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return user.name.toLowerCase().contains(q) ||
        (user.phone ?? '').toLowerCase().contains(q) ||
        (user.email ?? '').toLowerCase().contains(q) ||
        user.uid.toLowerCase().contains(q);
  }

  bool _exporting = false;

  Future<void> _exportCsv() async {
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.usersExportCsv,
      body: AdminStrings.usersExportPiiWarning,
      confirmLabel: AdminStrings.usersExportConfirm,
    );
    if (!ok) return;

    setState(() => _exporting = true);
    try {
      final csv = await ref.read(adminFunctionsServiceProvider).exportUsersCsv();
      if (!mounted) return;
      setState(() => _exporting = false);
      await showDialog<void>(
        context: context,
        builder: (context) => _CsvPreviewDialog(csv: csv),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.usersExportFailed} $e')),
      );
    }
  }

  Future<void> _toggleBlock(AppUser user) async {
    final blocking = !user.isBlocked;
    final ok = await ConfirmDialog.show(
      context,
      title: blocking
          ? AdminStrings.usersConfirmBlockTitle
          : AdminStrings.usersConfirmUnblockTitle,
      body: blocking
          ? AdminStrings.usersConfirmBlockBody
          : AdminStrings.usersConfirmUnblockBody,
      confirmLabel: blocking ? AdminStrings.usersBlock : AdminStrings.usersUnblock,
    );
    if (!ok) return;

    setState(() => _busy.add(user.uid));
    try {
      await ref.read(userRepositoryProvider).setBlocked(user.uid, blocking);
      ref.invalidate(adminUsersProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.usersBlockFailed} $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminUsersProvider);
    final canManage = AdminRole.canManageUsers(
      ref.watch(adminRoleProvider).valueOrNull,
    );

    return AdminPageFrame(
      title: AdminStrings.users,
      actions: [
        if (canManage)
          _exporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text(AdminStrings.usersExportCsv),
                ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: AdminStrings.auditRefresh,
          onPressed: () => ref.invalidate(adminUsersProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (users) {
          final languages = users.map((u) => u.language).toSet().toList()
            ..sort();
          final rows = users.where(_matches).toList()
            ..sort((a, b) {
              final ac = a.createdAt ?? DateTime(1970);
              final bc = b.createdAt ?? DateTime(1970);
              return bc.compareTo(ac);
            });

          return Column(
            children: [
              if (canManage) const _DeletionQueueSection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: AdminStrings.usersSearchHint,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: _language,
                            decoration: const InputDecoration(
                              labelText: AdminStrings.usersLanguage,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(AdminStrings.usersAllLanguages),
                              ),
                              for (final l in languages)
                                DropdownMenuItem(value: l, child: Text(l)),
                            ],
                            onChanged: (v) => setState(() => _language = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<_StatusFilter>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: AdminStrings.usersStatus,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: _StatusFilter.all,
                                child: Text(AdminStrings.usersAllStatus),
                              ),
                              DropdownMenuItem(
                                value: _StatusFilter.active,
                                child: Text(AdminStrings.usersActiveOnly),
                              ),
                              DropdownMenuItem(
                                value: _StatusFilter.blocked,
                                child: Text(AdminStrings.usersBlockedOnly),
                              ),
                            ],
                            onChanged: (v) => setState(
                              () => _status = v ?? _StatusFilter.all,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(message: AdminStrings.usersEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final user = rows[i];
                          return _UserRow(
                            user: user,
                            canManage: canManage,
                            busy: _busy.contains(user.uid),
                            onToggleBlock: () => _toggleBlock(user),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.canManage,
    required this.busy,
    required this.onToggleBlock,
  });

  final AppUser user;
  final bool canManage;
  final bool busy;
  final VoidCallback onToggleBlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.disabled,
              backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? const Icon(Icons.person_outline, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name.isEmpty ? AdminStrings.usersNoName : user.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (user.isBlocked) ...[
                        const SizedBox(width: 8),
                        const _BlockedBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if ((user.phone ?? '').isNotEmpty) user.phone,
                      if ((user.email ?? '').isNotEmpty) user.email,
                      user.uid,
                    ].join(' · '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaChip(label: user.language.toUpperCase()),
                      _MetaChip(label: user.platform),
                      _MetaChip(
                        label:
                            '${AdminStrings.usersTeachers}: ${user.selectedTeachers.length}',
                      ),
                      _MetaChip(
                        label:
                            '${AdminStrings.usersJoined} ${_fmt(user.createdAt)}',
                      ),
                      _MetaChip(
                        label:
                            '${AdminStrings.usersLastActive} ${_fmt(user.lastActiveAt)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canManage)
              busy
                  ? const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: onToggleBlock,
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            user.isBlocked ? AppColors.success : AppColors.error,
                        side: BorderSide(
                          color: user.isBlocked
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      child: Text(
                        user.isBlocked
                            ? AdminStrings.usersUnblock
                            : AdminStrings.usersBlock,
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime? stamp) {
    if (stamp == null) return AdminStrings.usersNever;
    final l = stamp.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }
}

class _BlockedBadge extends StatelessWidget {
  const _BlockedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          AdminStrings.usersBlockedBadge,
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// DPDP/GDPR-style deletion queue (T1.24, AR-5.5, FR-2.8). Reviewed-then-
/// executed by a Super Admin — see `processDeletionRequest.ts` for why this
/// isn't an unattended trigger.
class _DeletionQueueSection extends ConsumerWidget {
  const _DeletionQueueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDeletionRequestsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      child: async.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (requests) {
          final pending =
              requests.where((r) => r['status'] != 'completed').toList();
          if (pending.isEmpty) return const SizedBox.shrink();
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AdminStrings.usersDeletionQueue} (${pending.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final req in pending)
                    _DeletionRow(
                      uid: req['uid'] as String,
                      requestedAt: _toDate(req['requestedAt']),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static DateTime? _toDate(Object? value) {
    if (value is DateTime) return value;
    return null;
  }
}

class _DeletionRow extends ConsumerStatefulWidget {
  const _DeletionRow({required this.uid, required this.requestedAt});

  final String uid;
  final DateTime? requestedAt;

  @override
  ConsumerState<_DeletionRow> createState() => _DeletionRowState();
}

class _DeletionRowState extends ConsumerState<_DeletionRow> {
  bool _busy = false;

  Future<void> _execute() async {
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.usersDeletionConfirmTitle,
      body: AdminStrings.usersDeletionConfirmBody,
      confirmLabel: AdminStrings.usersDeletionExecute,
    );
    if (!ok) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(adminFunctionsServiceProvider)
          .processDeletionRequest(widget.uid);
      ref.invalidate(adminDeletionRequestsProvider);
      ref.invalidate(adminUsersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.usersDeletionDone)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.usersDeletionFailed} $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.requestedAt == null
                  ? widget.uid
                  : '${widget.uid} · ${AdminStrings.usersDeletionRequestedAt} ${widget.requestedAt}',
            ),
          ),
          _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : OutlinedButton(
                  onPressed: _execute,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text(AdminStrings.usersDeletionExecute),
                ),
        ],
      ),
    );
  }
}

class _CsvPreviewDialog extends StatelessWidget {
  const _CsvPreviewDialog({required this.csv});

  final String csv;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AdminStrings.usersExportCsv),
      content: SizedBox(
        width: 640,
        height: 400,
        child: SingleChildScrollView(
          child: SelectableText(csv, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AdminStrings.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: csv));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard.')),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy'),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.disabled.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
