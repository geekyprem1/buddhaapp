import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/localised_text_field.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../application/config_providers.dart';

final _semver = RegExp(r'^\d+\.\d+\.\d+$');

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  late final TextEditingController _minVersion;
  late final TextEditingController _latestVersion;
  late final TextEditingController _langCode;
  late final TextEditingController _langName;
  late final TextEditingController _langNative;

  var _message = const LocalisedText();
  var _languages = <LanguageOption>[];
  var _modules = <HomeModule>[];
  bool _forceUpdate = false;
  bool _maintenance = false;
  bool _ads = false;
  bool _idCard = false;
  bool _liveWallpaper = false;
  DateTime? _updatedAt;
  bool _loaded = false;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _minVersion = TextEditingController();
    _latestVersion = TextEditingController();
    _langCode = TextEditingController();
    _langName = TextEditingController();
    _langNative = TextEditingController();
  }

  @override
  void dispose() {
    _minVersion.dispose();
    _latestVersion.dispose();
    _langCode.dispose();
    _langName.dispose();
    _langNative.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_loaded && !_dirty) setState(() => _dirty = true);
  }

  void _hydrate(AppConfig config, HomeLayout layout) {
    _minVersion.text = config.minSupportedVersion;
    _latestVersion.text = config.latestVersion;
    _forceUpdate = config.forceUpdate;
    _maintenance = config.maintenanceMode;
    _message = config.maintenanceMessage;
    _languages = config.languages.isEmpty
        ? const [
            LanguageOption(code: 'en', name: 'English', native: 'English'),
            LanguageOption(code: 'hi', name: 'Hindi', native: 'हिन्दी'),
            LanguageOption(code: 'mr', name: 'Marathi', native: 'मराठी'),
          ]
        : List<LanguageOption>.from(config.languages);
    _ads = config.adsEnabled;
    _idCard = config.idCardEnabled;
    _liveWallpaper = config.liveWallpaperEnabled;
    _updatedAt = config.updatedAt;
    _modules = List<HomeModule>.from(layout.normalize().modules);
    _loaded = true;
    _dirty = false;
  }

  String? _validate() {
    if (!_semver.hasMatch(_minVersion.text.trim()) ||
        !_semver.hasMatch(_latestVersion.text.trim())) {
      return AdminStrings.configVersionInvalid;
    }
    if (_languages.isEmpty) return AdminStrings.configLanguageRequired;
    if (_maintenance && _message.isEmpty) {
      return AdminStrings.configMaintenanceMessageRequired;
    }
    return null;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleForce(bool value) async {
    if (value) {
      final ok = await ConfirmDialog.show(
        context,
        title: AdminStrings.configForceConfirmTitle,
        body: AdminStrings.configForceConfirmBody,
        confirmLabel: AdminStrings.confirm,
      );
      if (!ok) return;
    }
    setState(() {
      _forceUpdate = value;
      _dirty = true;
    });
  }

  Future<void> _toggleMaintenance(bool value) async {
    if (value) {
      final ok = await ConfirmDialog.show(
        context,
        title: AdminStrings.configMaintenanceConfirmTitle,
        body: AdminStrings.configMaintenanceConfirmBody,
        confirmLabel: AdminStrings.confirm,
      );
      if (!ok) return;
    }
    setState(() {
      _maintenance = value;
      _dirty = true;
    });
  }

  void _addLanguage() {
    final code = _langCode.text.trim().toLowerCase();
    final name = _langName.text.trim();
    final native = _langNative.text.trim();
    if (code.isEmpty || name.isEmpty || native.isEmpty) {
      _snack(AdminStrings.configLanguageFields);
      return;
    }
    if (_languages.any((l) => l.code == code)) {
      _snack(AdminStrings.configLanguageDuplicate);
      return;
    }
    setState(() {
      _languages = [
        ..._languages,
        LanguageOption(code: code, name: name, native: native),
      ];
      _dirty = true;
      _langCode.clear();
      _langName.clear();
      _langNative.clear();
    });
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      _snack(error);
      return;
    }
    setState(() => _saving = true);
    final config = AppConfig(
      minSupportedVersion: _minVersion.text.trim(),
      latestVersion: _latestVersion.text.trim(),
      forceUpdate: _forceUpdate,
      maintenanceMode: _maintenance,
      maintenanceMessage: _message,
      languages: _languages,
      adsEnabled: _ads,
      idCardEnabled: _idCard,
      liveWallpaperEnabled: _liveWallpaper,
    );
    final layout = HomeLayout(modules: _modules);
    try {
      final repo = ref.read(configRepositoryProvider);
      await Future.wait([
        repo.saveAppConfig(config),
        repo.saveHomeLayout(layout),
      ]);
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
      final configAsync = ref.watch(adminAppConfigProvider);
      final layoutAsync = ref.watch(adminHomeLayoutProvider);
      return configAsync.when(
        loading: () => const AdminPageFrame(
          title: AdminStrings.config,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => AdminPageFrame(
          title: AdminStrings.config,
          child: ErrorState(message: e.toString()),
        ),
        data: (config) => layoutAsync.when(
          loading: () => const AdminPageFrame(
            title: AdminStrings.config,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => AdminPageFrame(
            title: AdminStrings.config,
            child: ErrorState(message: e.toString()),
          ),
          data: (layout) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_loaded && mounted) setState(() => _hydrate(config, layout));
            });
            return const AdminPageFrame(
              title: AdminStrings.config,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: AdminStrings.config,
        actions: [
          FilledButton(
            onPressed: _saving || !_dirty ? null : _save,
            child: const Text(AdminStrings.save),
          ),
        ],
        child: ListView(
          padding: AdminResponsive.pagePadding(
            context,
            bottom: 48,
          ),
          children: [
            if (_forceUpdate || _maintenance)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _forceUpdate && _maintenance
                          ? AdminStrings.configBothGatesOn
                          : _forceUpdate
                              ? AdminStrings.configForceOnHint
                              : AdminStrings.configMaintenanceOnHint,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            _heading(AdminStrings.configVersions),
            ResponsiveFormRow(
              children: [
                TextField(
                  controller: _minVersion,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.configMinVersion,
                  ),
                  onChanged: (_) => _markDirty(),
                ),
                TextField(
                  controller: _latestVersion,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.configLatestVersion,
                  ),
                  onChanged: (_) => _markDirty(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.configGates),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.configForceUpdate),
              subtitle: const Text(AdminStrings.configForceUpdateHint),
              value: _forceUpdate,
              onChanged: _toggleForce,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.configMaintenance),
              subtitle: const Text(AdminStrings.configMaintenanceHint),
              value: _maintenance,
              onChanged: _toggleMaintenance,
            ),
            const SizedBox(height: 8),
            LocalisedTextField(
              label: AdminStrings.configMaintenanceMessage,
              value: _message,
              maxLines: 3,
              onChanged: (v) {
                _message = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.configLanguages),
            for (final lang in _languages)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${lang.name} (${lang.native})'),
                subtitle: Text(lang.code),
                trailing: IconButton(
                  tooltip: AdminStrings.removeFile,
                  onPressed: _languages.length <= 1
                      ? null
                      : () => setState(() {
                            _languages = [
                              for (final item in _languages)
                                if (item.code != lang.code) item,
                            ];
                            _dirty = true;
                          }),
                  icon: const Icon(Icons.close),
                ),
              ),
            ResponsiveFormRow(
              spacing: 8,
              children: [
                TextField(
                  controller: _langCode,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.configLangCode,
                  ),
                ),
                TextField(
                  controller: _langName,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.configLangName,
                  ),
                ),
                TextField(
                  controller: _langNative,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.configLangNative,
                  ),
                ),
                OutlinedButton(
                  onPressed: _addLanguage,
                  child: const Text(AdminStrings.addNew),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.configHomeModules),
            Text(
              AdminStrings.configHomeModulesHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _modules.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _modules.removeAt(oldIndex);
                  _modules.insert(newIndex, item);
                  _dirty = true;
                });
              },
              itemBuilder: (context, index) {
                final module = _modules[index];
                return Material(
                  key: ValueKey(module.id),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Text(HomeModuleIds.label(module.id)),
                    subtitle: Text(module.id),
                    trailing: Switch(
                      value: module.visible,
                      onChanged: (v) => setState(() {
                        _modules = [
                          for (var i = 0; i < _modules.length; i++)
                            if (i == index)
                              module.copyWith(visible: v)
                            else
                              _modules[i],
                        ];
                        _dirty = true;
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _heading(AdminStrings.configFlags),
            Text(
              AdminStrings.configFlagsHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.configAds),
              value: _ads,
              onChanged: (v) => setState(() {
                _ads = v;
                _dirty = true;
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.configIdCard),
              value: _idCard,
              onChanged: (v) => setState(() {
                _idCard = v;
                _dirty = true;
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AdminStrings.configLiveWallpaper),
              value: _liveWallpaper,
              onChanged: (v) => setState(() {
                _liveWallpaper = v;
                _dirty = true;
              }),
            ),
            if (_updatedAt != null) ...[
              const SizedBox(height: 16),
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
