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
import '../../../widgets/upload_field.dart';
import '../application/teachers_providers.dart';

class TeacherFormPage extends ConsumerStatefulWidget {
  const TeacherFormPage({this.teacherId, super.key});

  final String? teacherId;

  bool get isNew => teacherId == null || teacherId == 'new';

  @override
  ConsumerState<TeacherFormPage> createState() => _TeacherFormPageState();
}

class _TeacherFormPageState extends ConsumerState<TeacherFormPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _prefixCtrl;
  late final TextEditingController _sortCtrl;

  var _name = const LocalisedText();
  var _bio = const LocalisedText();
  bool _isActive = true;
  String? _portrait;
  String? _thumb;
  String? _signature;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController();
    _prefixCtrl = TextEditingController();
    _sortCtrl = TextEditingController(text: '0');
    if (widget.isNew) _loaded = true;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _prefixCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  void _hydrate(Teacher t) {
    _idCtrl.text = t.id;
    _name = t.name;
    _bio = t.bio ?? const LocalisedText();
    _prefixCtrl.text = t.idCardPrefix ?? '';
    _sortCtrl.text = '${t.sortOrder}';
    _isActive = t.isActive;
    _portrait = t.portraitUrl;
    _thumb = t.thumbUrl;
    _signature = t.signatureUrl;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.teachers);
  }

  Future<void> _save() async {
    final titleError = FieldValidators.localisedTitleRequired(
      en: _name.en,
      hi: _name.hi,
      mr: _name.mr,
    );
    if (titleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    final rawId = _idCtrl.text.trim().isEmpty ? _name.en : _idCtrl.text;
    final id = slugify(rawId);
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set an English name or an id.')),
      );
      return;
    }
    setState(() => _saving = true);
    final teacher = Teacher(
      id: id,
      name: _name,
      bio: _bio,
      idCardPrefix: _prefixCtrl.text.trim().isEmpty
          ? null
          : _prefixCtrl.text.trim().toUpperCase(),
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
      portraitUrl: _portrait,
      thumbUrl: _thumb,
      signatureUrl: _signature,
    );
    final repo = ref.read(teacherRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(teacher);
      } else {
        await repo.update(teacher);
      }
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
        _idCtrl.text = id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.saved)),
      );
      if (widget.isNew) context.go('${AdminRoutes.teachers}/$id');
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
    await ref.read(teacherRepositoryProvider).delete(widget.teacherId!);
    if (!mounted) return;
    context.go(AdminRoutes.teachers);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminTeacherProvider(widget.teacherId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (teacher) {
          if (teacher == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(teacher));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final storageId = slugify(
      _idCtrl.text.trim().isEmpty ? _name.en : _idCtrl.text,
    );

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew ? 'New teacher' : _name.resolve('en'),
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
              decoration: const InputDecoration(
                labelText: 'Id (stable, e.g. buddha)',
              ),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            LocalisedTextField(
              label: AdminStrings.bioField,
              value: _bio,
              maxLines: 4,
              onChanged: (v) {
                _bio = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prefixCtrl,
                    decoration: const InputDecoration(
                      labelText: AdminStrings.idCardPrefix,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => _markDirty(),
                  ),
                ),
                const SizedBox(width: 16),
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
            const SizedBox(height: 24),
            if (storageId.isEmpty) ...[
              Text(
                AdminStrings.teacherUploadIdRequired,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            UploadField(
              label: AdminStrings.portrait,
              valueUrl: _portrait,
              enabled: storageId.isNotEmpty,
              storagePathBuilder: (ext) =>
                  StoragePaths.teacherPortrait(storageId, ext),
              onUploaded: (url) {
                setState(() {
                  _portrait = url;
                  _dirty = true;
                });
              },
            ),
            const SizedBox(height: 16),
            UploadField(
              label: AdminStrings.thumbnail,
              valueUrl: _thumb,
              enabled: storageId.isNotEmpty,
              storagePathBuilder: (ext) =>
                  StoragePaths.teacherThumb(storageId, ext),
              onUploaded: (url) {
                setState(() {
                  _thumb = url;
                  _dirty = true;
                });
              },
            ),
            const SizedBox(height: 16),
            UploadField(
              label: AdminStrings.signature,
              valueUrl: _signature,
              enabled: storageId.isNotEmpty,
              storagePathBuilder: (ext) =>
                  StoragePaths.teacherSignature(storageId, ext),
              onUploaded: (url) {
                setState(() {
                  _signature = url;
                  _dirty = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
