import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/status_layout.dart';
import '../application/status_providers.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({required this.item, super.key});

  final ContentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final url = item.mediaUrl ?? item.thumbUrl;
    final meta = statusMetaOf(item);
    final name = ref.watch(statusDisplayNameProvider);
    final photo = ref.watch(statusAvatarProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 0.8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final photoRect = statusPhotoRect(meta.photoFrame, size);
                final nameRect = statusNameRect(meta.nameText, size);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: url == null
                          ? const ColoredBox(color: AppColors.disabled)
                          : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (_, __, ___) => const ColoredBox(
                                color: AppColors.disabled,
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                    ),
                    Positioned(
                      left: photoRect.left,
                      top: photoRect.top,
                      width: photoRect.width,
                      height: photoRect.height,
                      child: GestureDetector(
                        onTap: () => _pickPhoto(context, ref),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.disabled,
                                image: photo == null
                                    ? null
                                    : DecorationImage(
                                        image: FileImage(photo),
                                        fit: BoxFit.cover,
                                      ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: photo == null
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                    )
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CircleAvatar(
                                radius: photoRect.width * 0.16,
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: photoRect.width * 0.16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: nameRect.left,
                      top: nameRect.top,
                      width: nameRect.width,
                      child: GestureDetector(
                        onTap: () => _editName(context, ref, name),
                        child: Text(
                          name.isEmpty
                              ? (l10n?.statusTapName ?? 'Tap to add name')
                              : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: textAlignFrom(meta.nameText.align),
                          style: TextStyle(
                            color: colorFromHex(meta.nameText.color),
                            fontSize: statusNameFontSize(meta.nameText, size),
                            fontWeight: fontWeightFrom(meta.nameText.weight),
                            shadows: const [
                              Shadow(
                                color: Color(0xCC000000),
                                blurRadius: 8,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _run(context, ref, () async {
                      await ref.read(statusExportProvider).download(item);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.savedToGallery ?? 'Saved to gallery.',
                            ),
                          ),
                        );
                      }
                    }),
                    icon: const Icon(Icons.download),
                    label: Text(l10n?.download ?? 'Download'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.whatsappGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _run(
                      context,
                      ref,
                      () => ref.read(statusExportProvider).share(item),
                    ),
                    icon: const Icon(Icons.share),
                    label: Text(l10n?.share ?? 'Share'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.statusExportFailed ?? 'Could not export the status.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n?.statusPickGallery ?? 'Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n?.statusPickCamera ?? 'Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await ref.read(statusAvatarProvider.notifier).pick(source: source);
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: current);
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.statusEditName ?? 'Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n?.fullNameLabel ?? 'Full Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n?.continueButton ?? 'Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (next != null) {
      await ref.read(statusDisplayNameProvider.notifier).setName(next);
    }
  }
}
