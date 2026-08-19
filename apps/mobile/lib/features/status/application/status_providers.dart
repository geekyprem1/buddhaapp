import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../wallpaper/application/wallpaper_providers.dart';
import 'status_compositor.dart';

part 'status_providers.g.dart';

@Riverpod(keepAlive: true)
StatusCompositor statusCompositor(Ref ref) => StatusCompositor();

@Riverpod(keepAlive: true)
class StatusAvatar extends _$StatusAvatar {
  static const fileName = 'status_avatar.jpg';

  @override
  File? build() {
    Future<void>(() => load());
    return null;
  }

  Future<void> load() async {
    final file = await _file();
    if (await file.exists()) {
      state = file;
    }
  }

  Future<void> pick({required ImageSource source}) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (picked == null) return;
    final dest = await _file();
    await dest.parent.create(recursive: true);
    await File(picked.path).copy(dest.path);
    state = dest;
    await ref.read(analyticsServiceProvider).statusPhotoAdded();
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }
}

@Riverpod(keepAlive: true)
class StatusDisplayName extends _$StatusDisplayName {
  @override
  String build() {
    return ref.watch(currentAppUserProvider).valueOrNull?.name ?? '';
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      await ref.read(userRepositoryProvider).updateDisplayName(uid, trimmed);
    }
  }
}

class StatusExport {
  StatusExport(this._ref);

  final Ref _ref;

  Future<File> composeToTemp(ContentItem item) async {
    final url = item.mediaUrl ?? item.thumbUrl;
    if (url == null) throw StateError('Status image missing.');
    final bytes = await _ref.read(statusCompositorProvider).composePng(
          baseUrl: url,
          photoFile: _ref.read(statusAvatarProvider),
          name: _ref.read(statusDisplayNameProvider),
          meta: item.statusMeta ?? const StatusMeta(),
        );
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/status_${item.id}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> download(ContentItem item) async {
    final file = await composeToTemp(item);
    await _ref.read(wallpaperServiceProvider).saveFileToGallery(file.path);
    await _ref.read(analyticsServiceProvider).statusDownload(id: item.id);
    _recordEvent(item.id, ContentEventType.download);
  }

  Future<void> share(ContentItem item) async {
    final file = await composeToTemp(item);
    var channel = 'sheet';
    try {
      await _ref.read(wallpaperServiceProvider).shareWhatsApp(file.path);
      channel = 'whatsapp';
    } catch (_) {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: item.title.en,
      );
    }
    await _ref.read(analyticsServiceProvider).statusShare(
          id: item.id,
          channel: channel,
        );
    _recordEvent(item.id, ContentEventType.share);
  }

  /// Fire-and-forget counter event (FR-12.5/12.11) — `aggregateEvents` folds
  /// it into `statuses/{id}.counters`. Never blocks the export flow.
  void _recordEvent(String itemId, ContentEventType type) {
    unawaited(
      _ref
          .read(eventsRepositoryProvider)
          .record(
            collection: ContentCollections.statuses,
            itemId: itemId,
            type: type,
          )
          .catchError((_) {}),
    );
  }
}

@Riverpod(keepAlive: true)
StatusExport statusExport(Ref ref) => StatusExport(ref);
