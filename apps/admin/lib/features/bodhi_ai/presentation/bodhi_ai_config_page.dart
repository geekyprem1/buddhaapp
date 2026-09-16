import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/localised_text_field.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../application/bodhi_ai_providers.dart';

/// Super-admin settings for the "Ask Buddha" chat (`config/bodhi_ai`).
///
/// Cloned from `ConfigPage`: hydrate once from the stream, track dirty/saving
/// locally, validate manually, save through `ConfigRepository`. The model id,
/// quotas and token cap edited here are only ever acted on by the `bodhiChat`
/// Cloud Function — the client never trusts them — so this page is the single
/// authoritative place they change.
class BodhiAiConfigPage extends ConsumerStatefulWidget {
  const BodhiAiConfigPage({super.key});

  @override
  ConsumerState<BodhiAiConfigPage> createState() => _BodhiAiConfigPageState();
}

class _BodhiAiConfigPageState extends ConsumerState<BodhiAiConfigPage> {
  late final TextEditingController _model;
  late final TextEditingController _freeSeconds;
  late final TextEditingController _paidSeconds;
  late final TextEditingController _freeMessages;
  late final TextEditingController _paidMessages;
  late final TextEditingController _maxTokens;
  late final TextEditingController _temperature;

  bool _enabled = false;
  var _instruction = const LocalisedText();
  DateTime? _updatedAt;

  bool _loaded = false;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _model = TextEditingController();
    _freeSeconds = TextEditingController();
    _paidSeconds = TextEditingController();
    _freeMessages = TextEditingController();
    _paidMessages = TextEditingController();
    _maxTokens = TextEditingController();
    _temperature = TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    _freeSeconds.dispose();
    _paidSeconds.dispose();
    _freeMessages.dispose();
    _paidMessages.dispose();
    _maxTokens.dispose();
    _temperature.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_loaded && !_dirty) setState(() => _dirty = true);
  }

  void _hydrate(BodhiAiConfig c) {
    _model.text = c.model;
    _instruction = c.systemInstruction;
    _enabled = c.enabled;
    _freeSeconds.text = c.freeDailySeconds.toString();
    _paidSeconds.text = c.paidDailySeconds.toString();
    _freeMessages.text = c.freeDailyMessages.toString();
    _paidMessages.text = c.paidDailyMessages.toString();
    _maxTokens.text = c.maxTokens.toString();
    _temperature.text = c.temperature.toString();
    _updatedAt = c.updatedAt;
    _loaded = true;
    _dirty = false;
  }

  String? _validate() {
    if (_model.text.trim().isEmpty) return AdminStrings.bodhiAiModelRequired;
    if (_model.text.trim().startsWith('~')) {
      return AdminStrings.bodhiAiAliasWarning;
    }
    if (_instruction.isEmpty) return AdminStrings.bodhiAiInstructionRequired;

    final freeSec = int.tryParse(_freeSeconds.text.trim());
    final paidSec = int.tryParse(_paidSeconds.text.trim());
    if (freeSec == null || paidSec == null || freeSec <= 0 || paidSec <= 0 ||
        freeSec > paidSec) {
      return AdminStrings.bodhiAiSecondsInvalid;
    }

    final freeMsg = int.tryParse(_freeMessages.text.trim());
    final paidMsg = int.tryParse(_paidMessages.text.trim());
    if (freeMsg == null || paidMsg == null || freeMsg <= 0 || paidMsg <= 0 ||
        freeMsg > paidMsg) {
      return AdminStrings.bodhiAiMessagesInvalid;
    }

    final maxTokens = int.tryParse(_maxTokens.text.trim());
    if (maxTokens == null || maxTokens < 100 || maxTokens > 4000) {
      return AdminStrings.bodhiAiMaxTokensInvalid;
    }

    final temp = double.tryParse(_temperature.text.trim());
    if (temp == null || temp < 0 || temp > 2) {
      return AdminStrings.bodhiAiTemperatureInvalid;
    }
    return null;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }
    setState(() => _saving = true);
    final config = BodhiAiConfig(
      enabled: _enabled,
      model: _model.text.trim(),
      systemInstruction: _instruction,
      freeDailySeconds: int.parse(_freeSeconds.text.trim()),
      paidDailySeconds: int.parse(_paidSeconds.text.trim()),
      freeDailyMessages: int.parse(_freeMessages.text.trim()),
      paidDailyMessages: int.parse(_paidMessages.text.trim()),
      maxTokens: int.parse(_maxTokens.text.trim()),
      temperature: double.parse(_temperature.text.trim()),
    );
    try {
      await ref.read(configRepositoryProvider).saveBodhiAiConfig(config);
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
        _updatedAt = DateTime.now();
      });
      _snack(AdminStrings.saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('${AdminStrings.configSaveFailed} $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      final configAsync = ref.watch(adminBodhiAiConfigProvider);
      return configAsync.when(
        loading: () => const AdminPageFrame(
          title: AdminStrings.bodhiAi,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => AdminPageFrame(
          title: AdminStrings.bodhiAi,
          child: ErrorState(message: e.toString()),
        ),
        data: (config) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(config));
          });
          return const AdminPageFrame(
            title: AdminStrings.bodhiAi,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: AdminStrings.bodhiAi,
        actions: [
          FilledButton(
            onPressed: _saving || !_dirty ? null : _save,
            child: const Text(AdminStrings.save),
          ),
        ],
        child: ListView(
          padding: AdminResponsive.pagePadding(context, bottom: 48),
          children: [
            Text(
              AdminStrings.bodhiAiIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.bodhiAiEnabled),
              subtitle: const Text(AdminStrings.bodhiAiEnabledHint),
              value: _enabled,
              onChanged: (v) => setState(() {
                _enabled = v;
                _dirty = true;
              }),
            ),
            const SizedBox(height: 16),
            _heading(AdminStrings.bodhiAiModelSection),
            TextField(
              controller: _model,
              decoration: const InputDecoration(
                labelText: AdminStrings.bodhiAiModel,
                helperText: AdminStrings.bodhiAiModelHint,
                helperMaxLines: 3,
              ),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 20),
            LocalisedTextField(
              label: AdminStrings.bodhiAiInstruction,
              value: _instruction,
              maxLines: 6,
              onChanged: (v) {
                _instruction = v;
                _markDirty();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                AdminStrings.bodhiAiInstructionHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.bodhiAiQuotaSection),
            ResponsiveFormRow(
              children: [
                _intField(_freeSeconds, AdminStrings.bodhiAiFreeSeconds),
                _intField(_paidSeconds, AdminStrings.bodhiAiPaidSeconds),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFormRow(
              children: [
                _intField(_freeMessages, AdminStrings.bodhiAiFreeMessages),
                _intField(_paidMessages, AdminStrings.bodhiAiPaidMessages),
              ],
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.bodhiAiTuningSection),
            ResponsiveFormRow(
              children: [
                _intField(_maxTokens, AdminStrings.bodhiAiMaxTokens),
                TextField(
                  controller: _temperature,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.bodhiAiTemperature,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => _markDirty(),
                ),
              ],
            ),
            if (_updatedAt != null) ...[
              const SizedBox(height: 20),
              Text(
                '${AdminStrings.configUpdatedAt} ${_updatedAt!.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _intField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => _markDirty(),
    );
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
