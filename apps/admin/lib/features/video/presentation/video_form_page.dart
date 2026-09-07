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
import '../application/video_providers.dart';

class VideoFormPage extends ConsumerStatefulWidget {
  const VideoFormPage({this.videoId, super.key});

  final String? videoId;

  bool get isNew => videoId == null || videoId == 'new';

  @override
  ConsumerState<VideoFormPage> createState() => _VideoFormPageState();
}

class _VideoFormPageState extends ConsumerState<VideoFormPage> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _urlCtrl;

  var _title = const LocalisedText();
  bool _isActive = true;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl = TextEditingController();
    _sortCtrl = TextEditingController(text: '0');
    _urlCtrl = TextEditingController();
    if (widget.isNew) _loaded = true;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _sortCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _hydrate(Video v) {
    _idCtrl.text = v.id;
    _title = v.title;
    _sortCtrl.text = '${v.sortOrder}';
    _urlCtrl.text = v.youtubeUrl;
    _isActive = v.isActive;
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(AdminRoutes.videos);
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
    final videoId = extractYouTubeId(_urlCtrl.text);
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.videoUrlInvalid)),
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
    final video = Video(
      id: id,
      title: _title,
      youtubeUrl: _urlCtrl.text.trim(),
      videoId: videoId,
      sortOrder: int.tryParse(_sortCtrl.text) ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(videoRepositoryProvider);
    try {
      if (widget.isNew) {
        await repo.createWithId(video);
      } else {
        await repo.update(video);
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
      if (widget.isNew) context.go('${AdminRoutes.videos}/$id');
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
    await ref.read(videoRepositoryProvider).delete(widget.videoId!);
    if (!mounted) return;
    context.go(AdminRoutes.videos);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(adminVideoProvider(widget.videoId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (video) {
          if (video == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(video));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final previewId = extractYouTubeId(_urlCtrl.text);

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew ? 'New video' : _title.resolve('en'),
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
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: AdminStrings.videoUrlField,
                hintText: AdminStrings.videoUrlHint,
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (_) => _markDirty(),
            ),
            const SizedBox(height: 16),
            if (previewId != null) ...[
              Text(
                AdminStrings.videoPreview,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    youTubeThumbnail(previewId),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const ColoredBox(
                      color: Color(0xFFEEEEEE),
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
          ],
        ),
      ),
    );
  }
}
