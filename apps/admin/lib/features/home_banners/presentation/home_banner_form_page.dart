import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_access.dart';
import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../../../widgets/upload_field.dart';
import '../application/home_banner_providers.dart';

/// Selectable tap destinations for a banner slide — the home modules the
/// grid already routes to. Coming-soon modules are excluded. An empty id
/// means "decorative" (tapping does nothing).
final _moduleOptions = <String>[
  '',
  for (final id in HomeModuleIds.all)
    if (!HomeModuleIds.isComingSoon(id)) id,
];

class HomeBannerFormPage extends ConsumerStatefulWidget {
  const HomeBannerFormPage({this.bannerId, super.key});

  final String? bannerId;

  bool get isNew => bannerId == null || bannerId == 'new';

  @override
  ConsumerState<HomeBannerFormPage> createState() => _HomeBannerFormPageState();
}

class _HomeBannerFormPageState extends ConsumerState<HomeBannerFormPage> {
  late final TextEditingController _sortCtrl;
  late final String _id;

  String _moduleId = '';
  bool _isActive = true;
  String? _imageUrl;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _sortCtrl = TextEditingController(text: '0');
    // Storage upload needs an id up front, so new banners get a stable one now.
    _id = widget.isNew
        ? 'banner_${DateTime.now().millisecondsSinceEpoch}'
        : widget.bannerId!;
    if (widget.isNew) _loaded = true;
  }

  @override
  void dispose() {
    _sortCtrl.dispose();
    super.dispose();
  }

  void _hydrate(HomeBanner b) {
    _moduleId = b.moduleId;
    _sortCtrl.text = '${b.sortOrder}';
    _isActive = b.isActive;
    _imageUrl = b.imageUrl;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.homeBanners);
  }

  Future<void> _save() async {
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.homeBannerImageRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    final banner = HomeBanner(
      id: _id,
      imageUrl: _imageUrl,
      moduleId: _moduleId,
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(homeBannerRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(banner);
      } else {
        await repo.update(banner);
      }
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.saved)),
      );
      if (widget.isNew) context.go('${AdminRoutes.homeBanners}/$_id');
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
    await ref.read(homeBannerRepositoryProvider).delete(widget.bannerId!);
    if (!mounted) return;
    context.go(AdminRoutes.homeBanners);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminHomeBannerProvider(widget.bannerId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (banner) {
          if (banner == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(banner));
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
        title: widget.isNew
            ? AdminStrings.homeBannerNew
            : AdminStrings.homeBannerEdit,
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
            DropdownButtonFormField<String>(
              initialValue: _moduleId,
              decoration: const InputDecoration(
                labelText: AdminStrings.homeBannerOpens,
              ),
              items: [
                for (final id in _moduleOptions)
                  DropdownMenuItem(
                    value: id,
                    child: Text(
                      id.isEmpty
                          ? AdminStrings.homeBannerNoAction
                          : HomeModuleIds.label(id),
                    ),
                  ),
              ],
              onChanged: (v) {
                setState(() {
                  _moduleId = v ?? '';
                  _dirty = true;
                });
              },
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
                        setState(() {
                          _isActive = v;
                          _dirty = true;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            UploadField(
              label: AdminStrings.homeBannerImage,
              valueUrl: _imageUrl,
              storagePathBuilder: (ext) =>
                  StoragePaths.homeBannerImage(_id, ext),
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
