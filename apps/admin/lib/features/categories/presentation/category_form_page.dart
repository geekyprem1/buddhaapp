import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../util/slug.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/localised_text_field.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../application/categories_providers.dart';

const _modules = [
  ContentType.wallpaper,
  ContentType.ringtone,
  ContentType.song,
  ContentType.meditation,
  ContentType.status,
  ContentType.prarthana,
];

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({this.categoryId, super.key});

  final String? categoryId;

  bool get isNew => categoryId == null || categoryId == 'new';

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _sortCtrl;
  var _name = const LocalisedText();
  String _module = ContentType.wallpaper;
  bool _isActive = true;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController();
    _sortCtrl = TextEditingController(text: '0');
    if (widget.isNew) _loaded = true;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  void _hydrate(Category c) {
    _idCtrl.text = c.id;
    _name = c.name;
    _module = c.module;
    _sortCtrl.text = '${c.sortOrder}';
    _isActive = c.isActive;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.categories);
  }

  Future<void> _save() async {
    if (FieldValidators.localisedTitleRequired(
          en: _name.en,
          hi: _name.hi,
          mr: _name.mr,
        ) !=
        null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    final id = slugify(
      _idCtrl.text.trim().isEmpty ? '${_module}_${_name.en}' : _idCtrl.text,
    );
    setState(() => _saving = true);
    final category = Category(
      id: id,
      module: _module,
      name: _name,
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(categoryRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(category);
      } else {
        await repo.update(category);
      }
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.saved)),
      );
      if (widget.isNew) context.go('${AdminRoutes.categories}/$id');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save. $e')),
      );
    }
  }

  Future<void> _delete() async {
    if (widget.isNew) return;
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.confirmDeleteTitle,
      body: AdminStrings.confirmDeleteBody,
      confirmLabel: AdminStrings.delete,
    );
    if (!ok) return;
    await ref.read(categoryRepositoryProvider).delete(widget.categoryId!);
    if (!mounted) return;
    context.go(AdminRoutes.categories);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminCategoryProvider(widget.categoryId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (category) {
          if (category == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(category));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew ? 'New category' : _name.resolve('en'),
        onBack: _back,
        actions: [
          if (!widget.isNew)
            TextButton(
              onPressed: _delete,
              child: const Text(AdminStrings.delete),
            ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(widget.isNew ? AdminStrings.create : AdminStrings.save),
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(_module),
              initialValue: _module,
              decoration: const InputDecoration(
                labelText: AdminStrings.moduleField,
              ),
              items: [
                for (final m in _modules)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: widget.isNew
                  ? (v) {
                      if (v == null) return;
                      setState(() {
                        _module = v;
                        _dirty = true;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            LocalisedTextField(
              label: AdminStrings.nameField,
              value: _name,
              onChanged: (v) {
                _name = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: widget.isNew,
              controller: _idCtrl,
              decoration: const InputDecoration(labelText: 'Id'),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _sortCtrl,
                    decoration: const InputDecoration(
                      labelText: AdminStrings.sortOrder,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _markDirty(),
                  ),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text(AdminStrings.active),
                  selected: _isActive,
                  onSelected: (v) {
                    _isActive = v;
                    _markDirty();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
