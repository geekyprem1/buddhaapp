import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/prarthana_providers.dart';
import 'prarthana_song_picker.dart';

class PrarthanaSetupScreen extends ConsumerStatefulWidget {
  const PrarthanaSetupScreen({this.existing, super.key});

  final Alarm? existing;

  @override
  ConsumerState<PrarthanaSetupScreen> createState() =>
      _PrarthanaSetupScreenState();
}

class _PrarthanaSetupScreenState extends ConsumerState<PrarthanaSetupScreen> {
  late int _hour12;
  late int _minute;
  late bool _isPm;
  late bool _everyday;
  late Set<int> _days;
  String? _prarthanaId;
  String? _prarthanaTitle;
  String? _audioUrl;
  var _busy = false;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final display = toDisplayTime(
      existing?.timeHour ?? 6,
      existing?.timeMinute ?? 0,
    );
    _hour12 = display.hour12;
    _minute = display.minute;
    _isPm = display.isPm;
    _everyday = existing?.isEveryday ?? true;
    _days = {
      ...(existing == null || existing.isEveryday
          ? const [1, 2, 3, 4, 5, 6, 7]
          : existing.repeatDays),
    };
    _prarthanaId = existing?.prarthanaId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n?.homeDailyPrarthana ?? 'Daily Prarthana'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n?.prarthanaTimeLabel ?? 'Time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                _Wheel(
                  min: 1,
                  max: 12,
                  value: _hour12,
                  onChanged: (v) => setState(() => _hour12 = v),
                ),
                _Wheel(
                  min: 0,
                  max: 59,
                  value: _minute,
                  pad: true,
                  onChanged: (v) => setState(() => _minute = v),
                ),
                _AmPmWheel(
                  isPm: _isPm,
                  onChanged: (v) => setState(() => _isPm = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n?.prarthanaEveryday ?? 'Everyday'),
            value: _everyday,
            onChanged: (v) {
              setState(() {
                _everyday = v;
                _days = v
                    ? {1, 2, 3, 4, 5, 6, 7}
                    : {..._days};
              });
            },
          ),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < 7; i++)
                FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: _days.contains(i + 1),
                  onSelected: (on) {
                    setState(() {
                      if (on) {
                        _days.add(i + 1);
                      } else {
                        _days.remove(i + 1);
                      }
                      _everyday = _days.length == 7;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n?.prarthanaSongLabel ?? 'Prarthana Song'),
            subtitle: Text(
              _prarthanaTitle ??
                  l10n?.prarthanaNoSelection ??
                  'No Prarthana selected',
            ),
            trailing: const Text('Choose >'),
            onTap: _pickSong,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryPillButton(
            label: l10n?.prarthanaSetCta ?? 'Set Prarthana',
            icon: Icons.notifications_active,
            isLoading: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _pickSong() async {
    final item = await showPrarthanaSongPicker(context);
    if (item == null || !mounted) return;
    final language = Localizations.localeOf(context).languageCode;
    setState(() {
      _prarthanaId = item.id;
      _prarthanaTitle = item.title.resolve(language);
      _audioUrl = item.mediaUrl;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_prarthanaId == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.prarthanaNeedSong ?? 'Choose a prarthana first.',
          ),
        ),
      );
      return;
    }
    if (_days.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.prarthanaNeedDays ?? 'Pick at least one day.',
          ),
        ),
      );
      return;
    }
    var url = _audioUrl;
    if (url == null) {
      final repo = ref.read(
        contentRepositoryProvider(FirestoreCollections.prarthanas),
      );
      final page = await repo.fetchPublishedPage(pageSize: 50);
      url = page
          .where((e) => e.id == _prarthanaId)
          .map((e) => e.mediaUrl)
          .firstWhere((e) => e != null, orElse: () => null);
    }
    if (url == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.prarthanaNeedSong ?? 'Choose a prarthana first.',
          ),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final existing = widget.existing;
      final alarm = Alarm(
        id: existing?.id ?? 'pr_${DateTime.now().microsecondsSinceEpoch}',
        timeHour: toHour24(_hour12, _isPm),
        timeMinute: _minute,
        isEveryday: _everyday,
        repeatDays: _days.toList()..sort(),
        prarthanaId: _prarthanaId,
        prarthanaLocalPath: existing?.prarthanaLocalPath,
        isEnabled: true,
        label: existing?.label ?? 'Daily Prarthana',
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
      await ref.read(prarthanaActionsProvider).save(
            alarm: alarm,
            audioUrl: url,
          );
      if (!mounted) return;
      final service = ref.read(alarmServiceProvider);
      if (!await service.isIgnoringBatteryOptimizations()) {
        if (!mounted) return;
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              l10n?.prarthanaBatteryTitle ?? 'Keep the alarm reliable',
            ),
            content: Text(
              l10n?.prarthanaBatteryBody ??
                  'Some phones stop background alarms. Allow Dhamma Path to ignore battery optimisation.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.prarthanaHelpBattery ?? 'Open settings'),
              ),
            ],
          ),
        );
        if (open == true) {
          await service.openBatterySettings();
        }
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.prarthanaSetSuccess ?? 'Prarthana set.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.prarthanaSetFailed ?? 'Could not set the prarthana.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.pad = false,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final bool pad;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.value - widget.min,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [for (var i = widget.min; i <= widget.max; i++) i];
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        perspective: 0.003,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        controller: _controller,
        onSelectedItemChanged: (i) => widget.onChanged(items[i]),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, i) {
            final n = items[i];
            final text = widget.pad ? n.toString().padLeft(2, '0') : '$n';
            return Center(
              child: Text(text, style: Theme.of(context).textTheme.titleLarge),
            );
          },
        ),
      ),
    );
  }
}

class _AmPmWheel extends StatefulWidget {
  const _AmPmWheel({required this.isPm, required this.onChanged});

  final bool isPm;
  final ValueChanged<bool> onChanged;

  @override
  State<_AmPmWheel> createState() => _AmPmWheelState();
}

class _AmPmWheelState extends State<_AmPmWheel> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListWheelScrollView(
        itemExtent: 40,
        perspective: 0.003,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        controller: _controller,
        onSelectedItemChanged: (i) => widget.onChanged(i == 1),
        children: [
          Center(
            child: Text('AM', style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(
            child: Text('PM', style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}
