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
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../../../widgets/upload_field.dart';
import '../application/wisdom_providers.dart';

class WisdomFormPage extends ConsumerStatefulWidget {
  const WisdomFormPage({this.wisdomId, super.key});

  final String? wisdomId;

  bool get isNew => wisdomId == null || wisdomId == 'new';

  @override
  ConsumerState<WisdomFormPage> createState() => _WisdomFormPageState();
}

class _WisdomFormPageState extends ConsumerState<WisdomFormPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _sortCtrl;

  var _title = const LocalisedText();
  var _body = const LocalisedText();
  bool _isActive = true;
  String? _imageUrl;
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

  void _hydrate(Wisdom w) {
    _idCtrl.text = w.id;
    _title = w.title;
    _body = w.body;
    _sortCtrl.text = '${w.sortOrder}';
    _isActive = w.isActive;
    _imageUrl = w.imageUrl;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.wisdom);
  }

  Future<void> _save() async {
    final titleError = FieldValidators.localisedTitleRequired(
      en: _title.en,
      hi: _title.hi,
      mr: _title.mr,
    );
    if (titleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    final rawId = _idCtrl.text.trim().isEmpty ? _title.en : _idCtrl.text;
    final id = slugify(rawId);
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set an English title or an id.')),
      );
      return;
    }
    setState(() => _saving = true);
    final wisdom = Wisdom(
      id: id,
      title: _title,
      body: _body,
      imageUrl: _imageUrl,
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(wisdomRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(wisdom);
      } else {
        await repo.update(wisdom);
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
      if (widget.isNew) context.go('${AdminRoutes.wisdom}/$id');
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
    await ref.read(wisdomRepositoryProvider).delete(widget.wisdomId!);
    if (!mounted) return;
    context.go(AdminRoutes.wisdom);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminWisdomProvider(widget.wisdomId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (wisdom) {
          if (wisdom == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(wisdom));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final storageId = slugify(
      _idCtrl.text.trim().isEmpty ? _title.en : _idCtrl.text,
    );

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew ? 'New wisdom' : _title.resolve('en'),
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
          padding: AdminResponsive.pagePadding(context, top: 24, bottom: 48),
          children: [
            LocalisedTextField(
              label: 'Title',
              value: _title,
              onChanged: (v) {
                _title = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 16),
            LocalisedTextField(
              label: AdminStrings.wisdomBodyField,
              value: _body,
              maxLines: 8,
              onChanged: (v) {
                _body = v;
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
            ResponsiveFormRow(
              children: [
                TextField(
                  controller: _sortCtrl,
                  decoration: const InputDecoration(
                    labelText: AdminStrings.sortOrder,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _markDirty(),
                ),
                Wrap(
                  children: [
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
            const SizedBox(height: 24),
            if (storageId.isEmpty) ...[
              Text(
                AdminStrings.wisdomUploadIdRequired,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            UploadField(
              label: AdminStrings.wisdomImage,
              valueUrl: _imageUrl,
              enabled: storageId.isNotEmpty,
              storagePathBuilder: (ext) =>
                  StoragePaths.wisdomImage(storageId, ext),
              onUploaded: (url) {
                setState(() {
                  _imageUrl = url;
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
