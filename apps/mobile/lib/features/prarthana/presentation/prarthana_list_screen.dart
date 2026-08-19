import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/prarthana_providers.dart';

class PrarthanaListScreen extends ConsumerWidget {
  const PrarthanaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alarms = ref.watch(userAlarmsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.homeDailyPrarthana ?? 'Daily Prarthana'),
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
          if (items.isNotEmpty) {
            unawaited(() async {
              final store = ref.read(alarmLocalStoreProvider);
              if (store.getAll().isEmpty) {
                await store.replaceAll(items);
                await ref.read(alarmServiceProvider).syncAlarms(items);
              }
            }());
          }
          if (items.isEmpty) {
            return EmptyState(
              message: l10n?.prarthanaEmpty ??
                  'No prarthana set yet. Tap Add to schedule one.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
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
        title: Text(time, style: Theme.of(context).textTheme.headlineSmall),
        subtitle: Text('$days · ${alarm.label}'),
        trailing: Row(
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
