import 'dart:convert';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/prarthana_providers.dart';

class PrarthanaListScreen extends ConsumerStatefulWidget {
  const PrarthanaListScreen({super.key});

  @override
  ConsumerState<PrarthanaListScreen> createState() =>
      _PrarthanaListScreenState();
}

class _PrarthanaListScreenState extends ConsumerState<PrarthanaListScreen> {
  /// One-shot seed guards (B11): the restore below must run at most once per
  /// mount and never inside `build` — the old fire-and-forget in the builder
  /// re-fired on every rebuild and raced native sync.
  bool _restoreInFlight = false;
  bool _restoreDone = false;

  /// Seeds the on-device mirror and confirms it to the native scheduler
  /// (B11). Runs post-frame, at most once per mount, and only when needed:
  /// ids differ (first run / healed edits) or a previous native sync never
  /// confirmed (its failure used to be skipped forever once the store was
  /// nonempty). Any failure resets the done-flag so a later visit retries.
  void _maybeSeedLocal(List<Alarm> items) {
    if (_restoreDone || _restoreInFlight || items.isEmpty) return;
    _restoreDone = true;
    _restoreInFlight = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;
        final store = ref.read(alarmLocalStoreProvider);
        final remoteIds = {for (final a in items) a.id};
        final localIds = {
          for (final a in store.getAll()) a.id,
        };
        final fingerprint = jsonEncode((remoteIds.toList()..sort()));
        if (!setEquals(localIds, remoteIds)) {
          await store.replaceAll(items);
        }
        if (!mounted) return;
        if (store.getNativeSyncedIds() != fingerprint) {
          await ref.read(alarmServiceProvider).syncAlarms(items);
          await store.setNativeSyncedIds(remoteIds);
        }
      } catch (_) {
        _restoreDone = false;
      } finally {
        _restoreInFlight = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(userAlarmsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.homeDailyPrarthana ?? 'Daily Practice',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.prarthanaHelp),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(l10n?.help ?? 'Help'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.prarthanaEdit),
        icon: const Icon(Icons.add),
        label: Text(l10n?.prarthanaAdd ?? 'Add'),
      ),
      body: alarms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(
          message: l10n?.prarthanaLoadFailed ?? 'Could not load alarms.',
        ),
        data: (items) {
          _maybeSeedLocal(items);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _MeditationTimerCard(l10n: l10n),
              const SizedBox(height: AppSpacing.md),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: EmptyState(
                    message: l10n?.prarthanaEmpty ??
                        'No prarthana set yet. Tap Add to schedule one.',
                  ),
                ),
              for (final alarm in items)
                _AlarmCard(alarm: alarm),
              if (kDebugMode && items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(prarthanaActionsProvider)
                          .testIn60s(items.first);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.prarthanaTestArmed ??
                                  'Test alarm in 60 seconds.',
                            ),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.prarthanaSetFailed ??
                                  'Could not arm the test alarm.',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    l10n?.prarthanaTest60 ?? 'Test alarm in 60 seconds',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Entry point to the guided meditation timer (pick a track + duration, then
/// play with a countdown). Sits at the top of the Daily Practice list.
class _MeditationTimerCard extends StatelessWidget {
  const _MeditationTimerCard({required this.l10n});

  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          AppHaptics.tap();
          context.push(AppRoutes.meditationTimer);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.14),
                      AppColors.accent.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n?.meditationTimerTitle ?? 'Start Meditation',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n?.meditationTimerSubtitle ??
                          'Pick a track and meditate for a set time',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlarmCard extends ConsumerWidget {
  const _AlarmCard({required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final display = toDisplayTime(alarm.timeHour, alarm.timeMinute);
    final time =
        '${display.hour12}:${display.minute.toString().padLeft(2, '0')} ${display.isPm ? 'PM' : 'AM'}';
    final days = alarm.isEveryday
        ? (l10n?.prarthanaEveryday ?? 'Everyday')
        : alarm.repeatDays.map(_shortDay).join(' ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(
          time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        subtitle: Text(
          '$days · ${alarm.label}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: alarm.isEnabled,
                onChanged: (v) =>
                    ref.read(prarthanaActionsProvider).toggle(alarm, v),
              ),
              IconButton(
                tooltip: l10n?.prarthanaDelete ?? 'Delete',
                onPressed: () =>
                    ref.read(prarthanaActionsProvider).delete(alarm),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        onTap: () => context.push(AppRoutes.prarthanaEdit, extra: alarm),
      ),
    );
  }

  String _shortDay(int iso) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    if (iso < 1 || iso > 7) return '';
    return labels[iso - 1];
  }
}
