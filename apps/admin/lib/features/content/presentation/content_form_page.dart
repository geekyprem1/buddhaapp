import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/localised_text_field.dart';
import '../../../widgets/unsaved_changes_guard.dart';
import '../../../widgets/upload_field.dart';
import '../../auth/application/admin_session.dart';
import '../../categories/application/categories_providers.dart';
import '../../teachers/application/teachers_providers.dart';
import '../application/content_providers.dart';
import '../application/content_type_config.dart';

class ContentFormPage extends ConsumerStatefulWidget {
  const ContentFormPage({
    required this.config,
    this.itemId,
    super.key,
  });

  final ContentTypeConfig config;
  final String? itemId;

  bool get isNew => itemId == null || itemId == 'new';

  @override
  ConsumerState<ContentFormPage> createState() => _ContentFormPageState();
}

class _ContentFormPageState extends ConsumerState<ContentFormPage> {
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _source;
  late final TextEditingController _licence;
  late final TextEditingController _tags;
  late final TextEditingController _sort;
  late final TextEditingController _duration;
  late final TextEditingController _series;
  late final TextEditingController _part;
  late final TextEditingController _level;
  late final TextEditingController _orientation;
  late final TextEditingController _recommended;
  late final TextEditingController _frameX;
  late final TextEditingController _frameY;
  late final TextEditingController _frameW;
  late final TextEditingController _frameH;
  late final TextEditingController _nameX;
  late final TextEditingController _nameY;

  var _title = const LocalisedText();
  var _lyrics = const LocalisedText();
  var _description = const LocalisedText();
  final _teacherIds = <String>{};
  String? _categoryId;
  String _status = ContentStatus.draft;
  bool _featured = false;
  bool _premium = false;
  bool _watermark = true;
  String? _mediaUrl;
  String? _thumbUrl;
  String? _docId;
  bool _dirty = false;
  bool _loaded = false;
  bool _saving = false;

  ContentTypeConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _artist = TextEditingController();
    _album = TextEditingController();
    _source = TextEditingController();
    _licence = TextEditingController();
    _tags = TextEditingController();
    _sort = TextEditingController(text: '0');
    _duration = TextEditingController();
    _series = TextEditingController();
    _part = TextEditingController();
    _level = TextEditingController();
    _orientation = TextEditingController(text: 'portrait');
    _recommended = TextEditingController();
    _frameX = TextEditingController(text: '0.62');
    _frameY = TextEditingController(text: '0.70');
    _frameW = TextEditingController(text: '0.22');
    _frameH = TextEditingController(text: '0.22');
    _nameX = TextEditingController(text: '0.06');
    _nameY = TextEditingController(text: '0.92');
    if (widget.isNew) {
      _loaded = true;
      _docId = null;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _artist,
      _album,
      _source,
      _licence,
      _tags,
      _sort,
      _duration,
      _series,
      _part,
      _level,
      _orientation,
      _recommended,
      _frameX,
      _frameY,
      _frameW,
      _frameH,
      _nameX,
      _nameY,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(ContentItem item) {
    _docId = item.id;
    _title = item.title;
    _artist.text = item.artist ?? '';
    _source.text = item.source ?? '';
    _licence.text = item.licence ?? '';
    _tags.text = item.tags.join(', ');
    _sort.text = '${item.sortOrder}';
    _status = item.status;
    _featured = item.isFeatured;
    _premium = item.isPremium;
    _categoryId = item.categoryId;
    _teacherIds
      ..clear()
      ..addAll(item.teacherIds);
    _mediaUrl = item.mediaUrl;
    _thumbUrl = item.thumbUrl;
    final audio = item.audio;
    if (audio != null) {
      _duration.text = audio.durationSec?.toString() ?? '';
      _series.text = audio.seriesId ?? '';
      _part.text = audio.partNumber?.toString() ?? '';
      _level.text = audio.level ?? '';
      _album.text = audio.album ?? '';
      _lyrics = audio.lyrics ?? const LocalisedText();
      _recommended.text = audio.recommendedTime ?? '';
      _description = audio.description ?? const LocalisedText();
    }
    if (item.wallpaper != null) {
      _orientation.text = item.wallpaper!.orientation;
    }
    final status = item.statusMeta;
    if (status != null) {
      _frameX.text = '${status.photoFrame.x}';
      _frameY.text = '${status.photoFrame.y}';
      _frameW.text = '${status.photoFrame.w}';
      _frameH.text = '${status.photoFrame.h}';
      _nameX.text = '${status.nameText.x}';
      _nameY.text = '${status.nameText.y}';
      _watermark = status.watermark;
    }
    _loaded = true;
  }

  void _markDirty() => setState(() => _dirty = true);

  String _ensureId() {
    if (_docId != null && _docId!.isNotEmpty) return _docId!;
    final id = ref.read(contentRepositoryProvider(config.collection)).newId();
    _docId = id;
    return id;
  }

  ContentItem _buildItem() {
    final id = _ensureId();
    AudioMeta? audio;
    if (config.hasAudioMeta) {
      audio = AudioMeta(
        durationSec: int.tryParse(_duration.text),
        seriesId: _series.text.trim().isEmpty ? null : _series.text.trim(),
        partNumber: int.tryParse(_part.text),
        level: _level.text.trim().isEmpty ? null : _level.text.trim(),
        album: _album.text.trim().isEmpty ? null : _album.text.trim(),
        lyrics: _lyrics.isEmpty ? null : _lyrics,
        recommendedTime: _recommended.text.trim().isEmpty
            ? null
            : _recommended.text.trim(),
        description: _description.isEmpty ? null : _description,
        trimStartSec: config.hasTrim ? 0 : null,
        trimEndSec: config.hasTrim ? int.tryParse(_duration.text) : null,
      );
    }
    return ContentItem(
      id: id,
      type: config.type,
      title: _title,
      artist: _artist.text.trim().isEmpty ? null : _artist.text.trim(),
      teacherIds: _teacherIds.toList(),
      categoryId: _categoryId,
      mediaUrl: _mediaUrl,
      thumbUrl: _thumbUrl ?? _mediaUrl,
      storagePath: _mediaUrl,
      language: config.media == ContentMediaKind.audio ? 'en' : null,
      status: _status,
      sortOrder: int.tryParse(_sort.text) ?? 0,
      isFeatured: _featured,
      isPremium: _premium,
      tags: _tags.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      source: _source.text.trim().isEmpty ? null : _source.text.trim(),
      licence: _licence.text.trim().isEmpty ? null : _licence.text.trim(),
      wallpaper: config.hasWallpaperMeta
          ? WallpaperMeta(
              kind: 'static',
              orientation: _orientation.text.trim().isEmpty
                  ? 'portrait'
                  : _orientation.text.trim(),
            )
          : null,
      audio: audio,
      statusMeta: config.hasStatusMeta
          ? StatusMeta(
              photoFrame: LayoutRect(
                x: double.tryParse(_frameX.text) ?? 0,
                y: double.tryParse(_frameY.text) ?? 0,
                w: double.tryParse(_frameW.text) ?? 0,
                h: double.tryParse(_frameH.text) ?? 0,
              ),
              nameText: StatusTextStyle(
                x: double.tryParse(_nameX.text) ?? 0,
                y: double.tryParse(_nameY.text) ?? 0,
              ),
              watermark: _watermark,
            )
          : null,
    );
  }

  Future<void> _back() async {
    if (_dirty && !await UnsavedChangesGuard.confirmLeave(context)) return;
    if (mounted) context.go(config.route);
  }

  Future<void> _save() async {
    if (FieldValidators.localisedTitleRequired(
          en: _title.en,
          hi: _title.hi,
          mr: _title.mr,
        ) !=
        null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.titleRequired)),
      );
      return;
    }
    if (FieldValidators.licenceRequired(_licence.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.licenceHint)),
      );
      return;
    }
    setState(() => _saving = true);
    final item = _buildItem();
    final repo = ref.read(contentRepositoryProvider(config.collection));
    try {
      if (widget.isNew) {
        await repo.createWithId(item);
      } else {
        await repo.update(item);
      }
      ref.invalidate(adminContentListProvider(config.collection));
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AdminStrings.saved)),
      );
      if (widget.isNew) context.go('${config.route}/${item.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save. $e')),
      );
    }
  }

  Future<void> _archive() async {
    if (widget.isNew) return;
    final ok = await ConfirmDialog.show(
      context,
      title: AdminStrings.confirmArchiveTitle,
      body: AdminStrings.confirmArchiveBody,
      confirmLabel: AdminStrings.archive,
    );
    if (!ok) return;
    await ref
        .read(contentRepositoryProvider(config.collection))
        .softDelete(widget.itemId!);
    ref.invalidate(adminContentListProvider(config.collection));
    if (mounted) context.go(config.route);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew && !_loaded) {
      final async = ref.watch(
        adminContentItemProvider((config.collection, widget.itemId!)),
      );
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        data: (item) {
          if (item == null) {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_loaded && mounted) setState(() => _hydrate(item));
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final teachers = ref.watch(adminTeachersProvider).valueOrNull ?? [];
    final categories = (ref.watch(adminCategoriesProvider).valueOrNull ?? [])
        .where((c) => c.module == config.type)
        .toList();
    final role = ref.watch(adminRoleProvider).valueOrNull;
    final canEdit = AdminRole.canEditContent(role);
    final id = _docId ?? 'pending';

    return UnsavedChangesGuard(
      dirty: _dirty,
      child: AdminPageFrame(
        title: widget.isNew ? 'New ${config.label}' : _title.resolve('en'),
        onBack: _back,
        actions: [
          if (!widget.isNew)
            TextButton(
              onPressed: _archive,
              child: const Text(AdminStrings.archive),
            ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _saving || !canEdit ? null : _save,
            child: Text(widget.isNew ? AdminStrings.create : AdminStrings.save),
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
          children: [
            LocalisedTextField(
              label: 'Title',
              value: _title,
              enabled: canEdit,
              onChanged: (v) {
                _title = v;
                _markDirty();
              },
            ),
            const SizedBox(height: 16),
            if (config.artistLabel != null) ...[
              TextField(
                controller: _artist,
                enabled: canEdit,
                decoration: InputDecoration(labelText: config.artistLabel),
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: 16),
            ],
            const Text(AdminStrings.teachersField),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final t in teachers)
                  FilterChip(
                    label: Text(t.name.resolve('en')),
                    selected: _teacherIds.contains(t.id),
                    onSelected: canEdit
                        ? (selected) {
                            setState(() {
                              if (selected) {
                                _teacherIds.add(t.id);
                              } else {
                                _teacherIds.remove(t.id);
                              }
                              _dirty = true;
                            });
                          }
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              key: ValueKey(_categoryId),
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: AdminStrings.categoryField,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                for (final c in categories)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name.resolve('en')),
                  ),
              ],
              onChanged: canEdit
                  ? (v) {
                      setState(() {
                        _categoryId = v;
                        _dirty = true;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            UploadField(
              label: AdminStrings.media,
              valueUrl: _mediaUrl,
              allowedExtensions: config.media == ContentMediaKind.audio
                  ? FieldValidators.allowedAudioExtensions
                  : FieldValidators.allowedImageExtensions,
              maxBytes: config.media == ContentMediaKind.audio
                  ? FieldValidators.maxAudioBytes
                  : FieldValidators.maxImageBytes,
              enabled: canEdit,
              storagePathBuilder: (ext) => StoragePaths.contentOriginal(
                config.collection,
                _ensureId(),
                ext,
              ),
              onUploaded: (url) {
                setState(() {
                  _mediaUrl = url;
                  _thumbUrl ??= url;
                  _dirty = true;
                });
              },
            ),
            if (config.media == ContentMediaKind.audio) ...[
              const SizedBox(height: 16),
              UploadField(
                label: AdminStrings.thumbnail,
                valueUrl: _thumbUrl,
                enabled: canEdit,
                storagePathBuilder: (ext) =>
                    StoragePaths.contentThumb(config.collection, _ensureId()),
                onUploaded: (url) {
                  setState(() {
                    _thumbUrl = url;
                    _dirty = true;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _source,
                    enabled: canEdit,
                    decoration: const InputDecoration(
                      labelText: AdminStrings.source,
                    ),
                    onChanged: (_) => _markDirty(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _licence,
                    enabled: canEdit,
                    decoration: const InputDecoration(
                      labelText: AdminStrings.licence,
                    ),
                    onChanged: (_) => _markDirty(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_status),
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: AdminStrings.statusField,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ContentStatus.draft,
                        child: Text('draft'),
                      ),
                      DropdownMenuItem(
                        value: ContentStatus.published,
                        child: Text('published'),
                      ),
                      DropdownMenuItem(
                        value: ContentStatus.unpublished,
                        child: Text('unpublished'),
                      ),
                      DropdownMenuItem(
                        value: ContentStatus.archived,
                        child: Text('archived'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _status = v;
                        _dirty = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _sort,
                    enabled: canEdit,
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
                  label: const Text(AdminStrings.featured),
                  selected: _featured,
                  onSelected: canEdit
                      ? (v) {
                          _featured = v;
                          _markDirty();
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text(AdminStrings.premium),
                  selected: _premium,
                  onSelected: canEdit
                      ? (v) {
                          _premium = v;
                          _markDirty();
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tags,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: AdminStrings.tagsField,
              ),
              onChanged: (_) => _markDirty(),
            ),
            if (config.hasAlbum) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _album,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText: AdminStrings.albumField,
                ),
                onChanged: (_) => _markDirty(),
              ),
            ],
            if (config.hasLyrics) ...[
              const SizedBox(height: 16),
              LocalisedTextField(
                label: AdminStrings.lyricsField,
                value: _lyrics,
                maxLines: 6,
                enabled: canEdit,
                onChanged: (v) {
                  _lyrics = v;
                  _markDirty();
                },
              ),
            ],
            if (config.hasAudioMeta) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _duration,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText: AdminStrings.durationField,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _markDirty(),
              ),
            ],
            if (config.hasSeries) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _series,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: AdminStrings.seriesField,
                      ),
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _part,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: AdminStrings.partField,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _level,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: AdminStrings.levelField,
                      ),
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                ],
              ),
            ],
            if (config.hasWallpaperMeta) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _orientation,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText: AdminStrings.orientationField,
                ),
                onChanged: (_) => _markDirty(),
              ),
            ],
            if (config.hasPrarthanaExtras) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _recommended,
                enabled: canEdit,
                decoration: const InputDecoration(
                  labelText: AdminStrings.recommendedTimeField,
                ),
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: 16),
              LocalisedTextField(
                label: AdminStrings.descriptionField,
                value: _description,
                maxLines: 3,
                enabled: canEdit,
                onChanged: (v) {
                  _description = v;
                  _markDirty();
                },
              ),
            ],
            if (config.hasStatusMeta) ...[
              const SizedBox(height: 16),
              Text(
                'Status layout (0–1 normalised)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (widget.isNew)
                const Text(AdminStrings.statusLayoutSaveFirst)
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(
                      '${config.route}/${_docId ?? widget.itemId}/layout',
                    ),
                    icon: const Icon(Icons.open_in_full, size: 18),
                    label: const Text(AdminStrings.statusLayoutOpen),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _numField(_frameX, 'Frame X'),
                  _numField(_frameY, 'Frame Y'),
                  _numField(_frameW, 'Frame W'),
                  _numField(_frameH, 'Frame H'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _numField(_nameX, 'Name X'),
                  _numField(_nameY, 'Name Y'),
                  FilterChip(
                    label: const Text('Watermark'),
                    selected: _watermark,
                    onSelected: canEdit
                        ? (v) {
                            _watermark = v;
                            _markDirty();
                          }
                        : null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Id: $id',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController controller, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _markDirty(),
        ),
      ),
    );
  }
}
