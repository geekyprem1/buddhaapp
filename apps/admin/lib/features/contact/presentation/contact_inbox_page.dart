import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../../auth/application/admin_session.dart';
import '../application/contact_providers.dart';

enum _StatusFilter { all, open, resolved }

/// Contact messages inbox (T1.31, FR-14.5). List, read (expand), mark
/// resolved / reopen. Read/write is admin-only per Firestore rules — the
/// mobile app can only create (Architecture §7).
class ContactInboxPage extends ConsumerStatefulWidget {
  const ContactInboxPage({super.key});

  @override
  ConsumerState<ContactInboxPage> createState() => _ContactInboxPageState();
}

class _ContactInboxPageState extends ConsumerState<ContactInboxPage> {
  String _query = '';
  _StatusFilter _status = _StatusFilter.all;
  final _busy = <String>{};

  bool _matches(ContactMessage m) {
    switch (_status) {
      case _StatusFilter.open:
        if (m.status != ContactMessageStatus.open) return false;
      case _StatusFilter.resolved:
        if (m.status != ContactMessageStatus.resolved) return false;
      case _StatusFilter.all:
        break;
    }
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return m.subject.toLowerCase().contains(q) ||
        m.message.toLowerCase().contains(q) ||
        m.uid.toLowerCase().contains(q);
  }

  Future<void> _toggle(ContactMessage m) async {
    setState(() => _busy.add(m.id));
    try {
      final repo = ref.read(contactRepositoryProvider);
      if (m.status == ContactMessageStatus.open) {
        final uid = ref.read(adminAuthUserProvider)?.uid ?? '';
        await repo.markResolved(m.id, uid);
      } else {
        await repo.reopen(m.id);
      }
      ref.invalidate(adminContactMessagesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AdminStrings.contactActionFailed} $e')),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(m.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminContactMessagesProvider);
    return AdminPageFrame(
      title: AdminStrings.contact,
      actions: [
        IconButton(
          tooltip: AdminStrings.auditRefresh,
          onPressed: () => ref.invalidate(adminContactMessagesProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (messages) {
          final rows = messages.where(_matches).toList();
          return Column(
            children: [
              Padding(
                padding: AdminResponsive.pagePadding(
                  context,
                  top: 16,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: AdminStrings.contactSearchHint,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text(AdminStrings.contactAllStatus),
                          selected: _status == _StatusFilter.all,
                          onSelected: (_) =>
                              setState(() => _status = _StatusFilter.all),
                        ),
                        FilterChip(
                          label: const Text(AdminStrings.contactOpenOnly),
                          selected: _status == _StatusFilter.open,
                          onSelected: (_) =>
                              setState(() => _status = _StatusFilter.open),
                        ),
                        FilterChip(
                          label: const Text(AdminStrings.contactResolvedOnly),
                          selected: _status == _StatusFilter.resolved,
                          onSelected: (_) =>
                              setState(() => _status = _StatusFilter.resolved),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(message: AdminStrings.contactEmpty)
                    : ListView.separated(
                        padding: AdminResponsive.pagePadding(
                          context,
                          top: 8,
                          bottom: 32,
                        ),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _MessageTile(
                          message: rows[i],
                          busy: _busy.contains(rows[i].id),
                          onToggle: () => _toggle(rows[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.busy,
    required this.onToggle,
  });

  final ContactMessage message;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final resolved = message.status == ContactMessageStatus.resolved;
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: (resolved ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.15),
            child: Icon(
              resolved ? Icons.check : Icons.mail_outline,
              color: resolved ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            message.subject.isEmpty ? '(no subject)' : message.subject,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${AdminStrings.contactFrom} ${message.uid}${_when(message.createdAt)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(message.message),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : OutlinedButton(
                      onPressed: onToggle,
                      child: Text(
                        resolved
                            ? AdminStrings.contactReopen
                            : AdminStrings.contactMarkResolved,
                      ),
                    ),
            ),
          ],
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
