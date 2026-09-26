import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/responsive_layout.dart';
import '../../auth/application/admin_session.dart';
import '../application/users_providers.dart';

enum _StatusFilter { all, active, blocked }

enum _PremiumFilter { all, pro, free }

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
  _PremiumFilter _premium = _PremiumFilter.all;
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
    switch (_premium) {
      case _PremiumFilter.pro:
        if (!user.isPremium) return false;
      case _PremiumFilter.free:
        if (user.isPremium) return false;
      case _PremiumFilter.all:
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
      final csv =
          await ref.read(adminFunctionsServiceProvider).exportUsersCsv();
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
      confirmLabel:
          blocking ? AdminStrings.usersBlock : AdminStrings.usersUnblock,
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

  Future<void> _grantPremium(AppUser user) async {
    final days = await showDialog<int>(
      context: context,
      builder: (context) => const _GrantPremiumDialog(),
    );
    if (days == null) return;

    setState(() => _busy.add(user.uid));
    try {
      await ref
          .read(adminFunctionsServiceProvider)
          .grantPremium(uid: user.uid, days: days);
      ref.invalidate(adminUsersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.usersGrantPremiumDone)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.usersGrantPremiumFailed} $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(user.uid));
    }
  }

  Future<void> _revokePremium(AppUser user) async {
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.usersRevokePremiumTitle,
      body: AdminStrings.usersRevokePremiumBody,
      confirmLabel: AdminStrings.usersRevokePremiumConfirm,
    );
    if (!ok) return;

    setState(() => _busy.add(user.uid));
    try {
      await ref.read(adminFunctionsServiceProvider).revokePremium(user.uid);
      ref.invalidate(adminUsersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.usersRevokePremiumDone)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.usersRevokePremiumFailed} $e')),
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

          final listPadding = AdminResponsive.pagePadding(context, top: 8);
          // One scroll view for the whole page so the header, filters and the
          // list all scroll together — critical on phones and at high text
          // zoom, where a fixed filter block used to leave no room (and no
          // scroll) for the list below it.
          return CustomScrollView(
            slivers: [
              if (canManage)
                const SliverToBoxAdapter(child: _DeletionQueueSection()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AdminResponsive.pagePadding(context, bottom: 8),
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
                      ResponsiveFormRow(
                        children: [
                          DropdownButtonFormField<String?>(
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
                          DropdownButtonFormField<_StatusFilter>(
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
                          DropdownButtonFormField<_PremiumFilter>(
                            initialValue: _premium,
                            decoration: const InputDecoration(
                              labelText: AdminStrings.usersPremiumFilter,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: _PremiumFilter.all,
                                child: Text(AdminStrings.usersAllStatus),
                              ),
                              DropdownMenuItem(
                                value: _PremiumFilter.pro,
                                child: Text(AdminStrings.usersProOnly),
                              ),
                              DropdownMenuItem(
                                value: _PremiumFilter.free,
                                child: Text(AdminStrings.usersFreeOnly),
                              ),
                            ],
                            onChanged: (v) => setState(
                              () => _premium = v ?? _PremiumFilter.all,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (rows.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(message: AdminStrings.usersEmpty),
                )
              else
                SliverPadding(
                  padding: listPadding,
                  sliver: SliverList.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final user = rows[i];
                      return _UserRow(
                        user: user,
                        canManage: canManage,
                        busy: _busy.contains(user.uid),
                        onToggleBlock: () => _toggleBlock(user),
                        onGrantPremium: () => _grantPremium(user),
                        onRevokePremium: () => _revokePremium(user),
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
    required this.onGrantPremium,
    required this.onRevokePremium,
  });

  final AppUser user;
  final bool canManage;
  final bool busy;
  final VoidCallback onToggleBlock;
  final VoidCallback onGrantPremium;
  final VoidCallback onRevokePremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = user.isPremium;
    final Widget? action = !canManage
        ? null
        : busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed:
                        isPremium ? onRevokePremium : onGrantPremium,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPremium
                          ? AppColors.error
                          : AppColors.primary,
                      side: BorderSide(
                        color: isPremium
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                    child: Text(
                      isPremium
                          ? AdminStrings.usersRevokePremium
                          : AdminStrings.usersGrantPremium,
                    ),
                  ),
                  OutlinedButton(
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
              );
    final profile = Row(
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
              Text(
                user.name.isEmpty ? AdminStrings.usersNoName : user.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (user.isBlocked || isPremium) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (user.isBlocked) const _BlockedBadge(),
                    if (isPremium) const _ProBadge(),
                  ],
                ),
              ],
              const SizedBox(height: 2),
              Text(
                [
                  if ((user.phone ?? '').isNotEmpty) user.phone,
                  if ((user.email ?? '').isNotEmpty) user.email,
                  user.uid,
                ].join(' · '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
                        '${AdminStrings.usersJoined} ${_fmt(user.createdAt)}',
                  ),
                  _MetaChip(
                    label:
                        '${AdminStrings.usersLastActive} ${_fmt(user.lastActiveAt)}',
                  ),
                  if (isPremium)
                    _MetaChip(
                      label:
                          '${AdminStrings.usersPremiumUntil} ${_fmt(user.premiumUntil)}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AdminResponsive.isCompact(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  profile,
                  if (action != null) ...[
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: action),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: profile),
                  if (action != null) ...[
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: action,
                    ),
                  ],
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

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          AdminStrings.usersPremiumBadge,
          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Duration picker for a manual Pro grant. Returns the chosen number of days,
/// or null on cancel.
class _GrantPremiumDialog extends StatefulWidget {
  const _GrantPremiumDialog();

  @override
  State<_GrantPremiumDialog> createState() => _GrantPremiumDialogState();
}

class _GrantPremiumDialogState extends State<_GrantPremiumDialog> {
  // label → days
  static const _options = <String, int>{
    '1 month': 30,
    '3 months': 90,
    '6 months': 180,
    '1 year': 365,
    'Lifetime (10 years)': 3650,
  };

  int _days = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AdminStrings.usersGrantPremiumTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AdminStrings.usersGrantPremiumBody),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _days,
            decoration: const InputDecoration(
              labelText: AdminStrings.usersGrantPremiumDuration,
            ),
            items: [
              for (final entry in _options.entries)
                DropdownMenuItem(value: entry.value, child: Text(entry.key)),
            ],
            onChanged: (v) => setState(() => _days = v ?? _days),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AdminStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: const Text(AdminStrings.usersGrantPremiumConfirm),
        ),
      ],
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
    // Reuse the already-loaded users page to resolve a uid to a name/phone/
    // email — no extra Firestore reads. A requester outside the loaded page
    // (or already erased) simply has no match and shows the uid alone.
    final usersById = <String, AppUser>{
      for (final u in ref.watch(adminUsersProvider).valueOrNull ?? const [])
        u.uid: u,
    };
    return Padding(
      padding: AdminResponsive.pagePadding(context, bottom: 0),
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
                      user: usersById[req['uid'] as String],
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
  const _DeletionRow({
    required this.uid,
    required this.requestedAt,
    this.user,
  });

  final String uid;
  final DateTime? requestedAt;

  /// Matched account for this request, if it's within the loaded users page.
  final AppUser? user;

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
    final action = _busy
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
          );
    final theme = Theme.of(context);
    final user = widget.user;
    final name = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : AdminStrings.usersNoName;
    // Contact/identity line: whatever we know, else fall back to the uid.
    final contactBits = <String>[
      if ((user?.phone ?? '').isNotEmpty) user!.phone!,
      if ((user?.email ?? '').isNotEmpty) user!.email!,
      widget.uid,
    ];
    final requested = widget.requestedAt == null
        ? null
        : '${AdminStrings.usersDeletionRequestedAt} ${_fmtDate(widget.requestedAt!)}';

    final description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          contactBits.join(' · '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        if (requested != null) ...[
          const SizedBox(height: 2),
          Text(
            requested,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AdminResponsive.isCompact(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                description,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            )
          : Row(
              children: [
                Expanded(child: description),
                const SizedBox(width: 16),
                action,
              ],
            ),
    );
  }

  String _fmtDate(DateTime stamp) {
    final l = stamp.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }
}

class _CsvPreviewDialog extends StatelessWidget {
  const _CsvPreviewDialog({required this.csv});

  final String csv;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = media.size.height - media.viewInsets.bottom;
    final previewHeight =
        (availableHeight * 0.55).clamp(80.0, 400.0).toDouble();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      scrollable: true,
      title: const Text(AdminStrings.usersExportCsv),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: previewHeight),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
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
