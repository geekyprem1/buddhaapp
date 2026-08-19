import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/admin_strings.dart';

class UploadField extends ConsumerStatefulWidget {
  const UploadField({
    required this.label,
    required this.storagePathBuilder,
    required this.onUploaded,
    this.valueUrl,
    this.allowedExtensions = FieldValidators.allowedImageExtensions,
    this.maxBytes = FieldValidators.maxImageBytes,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? valueUrl;
  final String Function(String extension) storagePathBuilder;
  final ValueChanged<String> onUploaded;
  final List<String> allowedExtensions;
  final int maxBytes;
  final bool enabled;

  @override
  ConsumerState<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends ConsumerState<UploadField> {
  double? _progress;
  String? _error;
  StorageUpload? _upload;

  Future<void> _pick() async {
    if (!widget.enabled) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;

    if (bytes.length > widget.maxBytes) {
      setState(() => _error = 'File is larger than the allowed size.');
      return;
    }
    if (!FieldValidators.hasAllowedExtension(
      file.name,
      widget.allowedExtensions,
    )) {
      setState(() => _error = 'This file type is not allowed.');
      return;
    }

    final ext = file.name.split('.').last.toLowerCase();
    final path = widget.storagePathBuilder(ext);
    final contentType = _contentType(ext);
    setState(() {
      _error = null;
      _progress = 0;
    });

    final upload = ref.read(storageServiceProvider).uploadBytes(
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
    _upload = upload;
    final sub = upload.progress.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
    try {
      final url = await upload.whenComplete();
      if (!mounted) return;
      widget.onUploaded(url);
      setState(() => _progress = null);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _error = 'Upload failed. $e';
      });
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _cancel() async {
    await _upload?.cancel();
    if (mounted) setState(() => _progress = null);
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.valueUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (url != null && url.isNotEmpty) ...[
                  _Preview(url: url),
                  const SizedBox(height: 8),
                ],
                if (_progress != null) ...[
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cancel,
                    child: const Text('Cancel upload'),
                  ),
                ] else
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.enabled ? _pick : null,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text(AdminStrings.upload),
                      ),
                    ],
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.url});

  final String url;

  bool get _isImage {
    final lower = url.toLowerCase();
    return lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp') ||
        lower.contains('picsum') ||
        lower.contains('firebasestorage') && !lower.contains('.mp3');
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const SizedBox(
            height: 72,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          ),
        ),
      );
    }
    return Text(url, maxLines: 2, overflow: TextOverflow.ellipsis);
  }
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
