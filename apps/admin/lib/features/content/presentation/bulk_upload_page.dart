import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../application/content_providers.dart';
import '../application/content_type_config.dart';

/// Bulk upload (T1.21, AR-3.5). Drops many files, creating one draft per file
/// with the title auto-filled from the filename. Each file:
///   1. a draft doc is created first (so `onMediaUpload`'s derivative patch
///      lands on an existing document),
///   2. the original is uploaded to `{collection}/{itemId}/original.{ext}`,
///   3. the `onMediaUpload` Function fills `mediaUrl` / `thumbUrl` / duration.
/// If an upload fails the draft is hard-deleted so no empty rows are left.
class BulkUploadPage extends ConsumerStatefulWidget {
  const BulkUploadPage({required this.config, super.key});

  final ContentTypeConfig config;

  @override
  ConsumerState<BulkUploadPage> createState() => _BulkUploadPageState();
}

enum _BulkStatus { queued, uploading, done, failed }

class _BulkFile {
  _BulkFile({required this.name, required this.bytes, required this.ext});

  final String name;
  final Uint8List bytes;
  final String ext;

  _BulkStatus status = _BulkStatus.queued;
  double progress = 0;
  String? error;
  String? createdId;
}

class _BulkUploadPageState extends ConsumerState<BulkUploadPage> {
  final _files = <_BulkFile>[];
  bool _running = false;

  ContentTypeConfig get config => widget.config;

  bool get _isAudio => config.media == ContentMediaKind.audio;

  List<String> get _allowedExtensions => _isAudio
      ? FieldValidators.allowedAudioExtensions
      : FieldValidators.allowedImageExtensions;

  int get _maxBytes =>
      _isAudio ? FieldValidators.maxAudioBytes : FieldValidators.maxImageBytes;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;
        final ext = file.name.split('.').last.toLowerCase();
        final entry = _BulkFile(name: file.name, bytes: bytes, ext: ext);
        if (!FieldValidators.hasAllowedExtension(file.name, _allowedExtensions)) {
          entry
            ..status = _BulkStatus.failed
            ..error = AdminStrings.bulkBadType;
        } else if (bytes.length > _maxBytes) {
          entry
            ..status = _BulkStatus.failed
            ..error = AdminStrings.bulkTooLarge;
        }
        _files.add(entry);
      }
    });
  }

  Future<void> _uploadAll() async {
    if (_running) return;
    setState(() => _running = true);
    final repo = ref.read(contentRepositoryProvider(config.collection));
    final storage = ref.read(storageServiceProvider);

    for (final file in _files) {
      if (file.status != _BulkStatus.queued) continue;
      setState(() {
        file.status = _BulkStatus.uploading;
        file.progress = 0;
      });

      final id = repo.newId();
      final path = StoragePaths.contentOriginal(config.collection, id, file.ext);
      try {
        // 1. Draft doc first — the media Function merges onto it.
        await repo.createWithId(
          ContentItem(
            id: id,
            type: config.type,
            title: LocalisedText(en: _titleFromFilename(file.name)),
            language: _isAudio ? 'en' : null,
            storagePath: path,
          ),
        );

        // 2. Upload the original.
        final upload = storage.uploadBytes(
          path: path,
          bytes: file.bytes,
          contentType: _contentType(file.ext),
        );
        final sub = upload.progress.listen((p) {
          if (mounted) setState(() => file.progress = p);
        });
        try {
          await upload.whenComplete();
        } finally {
          await sub.cancel();
        }

        if (!mounted) return;
        setState(() {
          file.status = _BulkStatus.done;
          file.createdId = id;
          file.progress = 1;
        });
      } catch (e) {
        // Roll back the empty draft so the list stays clean.
        await repo.hardDelete(id).catchError((_) {});
        if (!mounted) return;
        setState(() {
          file.status = _BulkStatus.failed;
          file.error = '$e';
        });
      }
    }

    ref.invalidate(adminContentListProvider(config.collection));
    if (mounted) setState(() => _running = false);
  }

  void _clearFinished() {
    setState(() {
      _files.removeWhere(
        (f) => f.status == _BulkStatus.done || f.status == _BulkStatus.failed,
      );
    });
  }

  int get _queuedCount =>
      _files.where((f) => f.status == _BulkStatus.queued).length;

  @override
  Widget build(BuildContext context) {
    final doneCount = _files.where((f) => f.status == _BulkStatus.done).length;

    return AdminPageFrame(
      title: '${AdminStrings.bulkUpload} — ${config.label}',
      onBack: _running ? null : () => Navigator.of(context).maybePop(),
      actions: [
        if (_files.any(
          (f) => f.status == _BulkStatus.done || f.status == _BulkStatus.failed,
        ))
          TextButton(
            onPressed: _running ? null : _clearFinished,
            child: const Text(AdminStrings.bulkClear),
          ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _running ? null : _pick,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(AdminStrings.bulkChooseFiles),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _running || _queuedCount == 0 ? null : _uploadAll,
          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
          label: Text('${AdminStrings.bulkUploadAll} ($_queuedCount)'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        children: [
          Text(
            AdminStrings.bulkHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (doneCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$doneCount ${AdminStrings.bulkDoneLabel.toLowerCase()}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          if (_files.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: EmptyState(message: AdminStrings.bulkEmpty),
            )
          else
            for (final file in _files) _BulkRow(file: file, running: _running),
        ],
      ),
    );
  }
}

class _BulkRow extends StatelessWidget {
  const _BulkRow({required this.file, required this.running});

  final _BulkFile file;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (file.status) {
      _BulkStatus.queued => (
        Icons.schedule,
        AppColors.textSecondary,
        AdminStrings.bulkQueued,
      ),
      _BulkStatus.uploading => (
        Icons.cloud_upload_outlined,
        AppColors.primary,
        '${AdminStrings.bulkUploadingLabel} ${(file.progress * 100).round()}%',
      ),
      _BulkStatus.done => (
        Icons.check_circle_outline,
        AppColors.success,
        AdminStrings.bulkDoneLabel,
      ),
      _BulkStatus.failed => (
        Icons.error_outline,
        AppColors.error,
        file.error ?? AdminStrings.bulkFailedLabel,
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(file.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color)),
              if (file.status == _BulkStatus.uploading) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(value: file.progress),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _titleFromFilename(String name) {
  var base = name;
  final dot = base.lastIndexOf('.');
  if (dot > 0) base = base.substring(0, dot);
  base = base
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (base.isEmpty) return 'Untitled';
  return base[0].toUpperCase() + base.substring(1);
}

String _contentType(String ext) {
  return switch (ext) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
    'mp3' => 'audio/mpeg',
    'm4a' => 'audio/mp4',
    'aac' => 'audio/aac',
    _ => 'application/octet-stream',
  };
}
