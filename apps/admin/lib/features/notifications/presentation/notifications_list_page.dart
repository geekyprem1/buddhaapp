import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/notifications_providers.dart';

class NotificationsListPage extends ConsumerStatefulWidget {
  const NotificationsListPage({super.key});

  @override
  ConsumerState<NotificationsListPage> createState() =>
      _NotificationsListPageState();
}

class _NotificationsListPageState extends ConsumerState<NotificationsListPage> {
  String? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminNotificationCampaignsProvider);
    return AdminPageFrame(
      title: AdminStrings.notifications,
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('${AdminRoutes.notifications}/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.composeNotification),
        ),
      ],
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (campaigns) {
          final rows = campaigns.where((c) {
            if (_status != null && c.status != _status) return false;
            if (_query.isEmpty) return true;
            final q = _query.toLowerCase();
            return c.title.toLowerCase().contains(q) ||
                c.body.toLowerCase().contains(q) ||
                c.id.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: AdminStrings.search,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final status in [
                          null,
                          NotificationCampaignStatus.draft,
                          NotificationCampaignStatus.scheduled,
                          NotificationCampaignStatus.sent,
                          NotificationCampaignStatus.failed,
                        ])
                          FilterChip(
                            label: Text(
                              status == null
                                  ? 'All'
                                  : _statusLabel(status),
                            ),
                            selected: _status == status,
                            onSelected: (_) =>
                                setState(() => _status = status),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(message: AdminStrings.emptyList)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final campaign = rows[i];
                          return _CampaignRow(
                            campaign: campaign,
                            onTap: () => context.go(
                              '${AdminRoutes.notifications}/${campaign.id}',
                            ),
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

class _CampaignRow extends StatelessWidget {
  const _CampaignRow({required this.campaign, required this.onTap});

  final NotificationCampaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.disabled,
                child: Icon(
                  Icons.campaign_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${NotificationAudience.label(campaign.audience)}'
                      '${_when(campaign)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (campaign.status == NotificationCampaignStatus.sent)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    campaign.deliveredCount == 0
                        ? AdminStrings.topicAccepted
                        : '${campaign.deliveredCount} delivered',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              _StatusChip(status: campaign.status),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  String _when(NotificationCampaign c) {
    final stamp = c.sentAt ?? c.scheduledAt ?? c.createdAt;
    if (stamp == null) return '';
    final local = stamp.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return ' · $y-$m-$d $hh:$mm';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      NotificationCampaignStatus.sent => AppColors.success,
      NotificationCampaignStatus.failed => AppColors.error,
      NotificationCampaignStatus.scheduled => AppColors.accent,
      NotificationCampaignStatus.sending => AppColors.accent,
      _ => AppColors.textSecondary,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          _statusLabel(status),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

String _statusLabel(String status) => switch (status) {
  NotificationCampaignStatus.draft => 'Draft',
  NotificationCampaignStatus.scheduled => 'Scheduled',
  NotificationCampaignStatus.sending => 'Sending',
  NotificationCampaignStatus.sent => 'Sent',
  NotificationCampaignStatus.failed => 'Failed',
  _ => status,
};
