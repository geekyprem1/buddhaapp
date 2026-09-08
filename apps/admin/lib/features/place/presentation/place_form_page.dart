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
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../../../widgets/upload_field.dart';
import '../application/place_providers.dart';

class PlaceFormPage extends ConsumerStatefulWidget {
  const PlaceFormPage({this.placeId, super.key});

  final String? placeId;

  bool get isNew => placeId == null || placeId == 'new';

  @override
  ConsumerState<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends ConsumerState<PlaceFormPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _sortCtrl;

  String? _thumbUrl;
  final List<String> _images = [];
  // Monotonic counter so each gallery slot uploads to a distinct storage key
  // even after removals.
  int _nextImageIndex = 0;
  bool _isActive = true;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _sortCtrl = TextEditingController(text: '0');
    if (widget.isNew) _loaded = true;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  void _hydrate(BuddhistPlace p) {
    _idCtrl.text = p.id;
    _titleCtrl.text = p.title;
    _descCtrl.text = p.description;
    _sortCtrl.text = '${p.sortOrder}';
    _thumbUrl = p.thumbUrl;
    _images
      ..clear()
      ..addAll(p.imageUrls);
    _nextImageIndex = p.imageUrls.length;
    _isActive = p.isActive;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  String get _storageId => slugify(
        _idCtrl.text.trim().isEmpty ? _titleCtrl.text : _idCtrl.text,
      );

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.places);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    final id = slugify(_idCtrl.text.trim().isEmpty ? title : _idCtrl.text);
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a title or an id.')),
      );
      return;
    }
    setState(() => _saving = true);
    final place = BuddhistPlace(
      id: id,
      title: title,
      description: _descCtrl.text.trim(),
      thumbUrl: _thumbUrl,
      imageUrls: List<String>.from(_images),
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(placeRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(place);
      } else {
        await repo.update(place);
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
      if (widget.isNew) context.go('${AdminRoutes.places}/$id');
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
    await ref.read(placeRepositoryProvider).delete(widget.placeId!);
    if (!mounted) return;
    context.go(AdminRoutes.places);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminPlaceProvider(widget.placeId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (place) {
          if (place == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(place));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final storageId = _storageId;
    final canUpload = storageId.isNotEmpty;

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew
            ? 'New place'
            : (_titleCtrl.text.isEmpty ? 'Place' : _titleCtrl.text),
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
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: AdminStrings.placeDescription,
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: widget.isNew,
              controller: _idCtrl,
              decoration: const InputDecoration(labelText: 'Id'),
              onChanged: (_) => setState(() => _dirty = true),
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
            if (!canUpload) ...[
              Text(
                AdminStrings.placeUploadIdRequired,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            UploadField(
              label: AdminStrings.placeThumbnail,
              valueUrl: _thumbUrl,
              enabled: canUpload,
              storagePathBuilder: (ext) =>
                  StoragePaths.placeThumb(storageId, ext),
              onUploaded: (url) => setState(() {
                _thumbUrl = url;
                _dirty = true;
              }),
            ),
            const SizedBox(height: 24),
            Text(
              AdminStrings.placeGallery,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _images.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _images[i],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 80,
                            child: Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AdminStrings.delete,
                      onPressed: () => setState(() {
                        _images.removeAt(i);
                        _dirty = true;
                      }),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            // A fresh uploader slot: each successful upload appends to the
            // gallery and advances the storage index.
            UploadField(
              key: ValueKey('place-img-$_nextImageIndex'),
              label: AdminStrings.placeAddImage,
              enabled: canUpload,
              storagePathBuilder: (ext) =>
                  StoragePaths.placeImage(storageId, _nextImageIndex, ext),
              onUploaded: (url) => setState(() {
                _images.add(url);
                _nextImageIndex++;
                _dirty = true;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
