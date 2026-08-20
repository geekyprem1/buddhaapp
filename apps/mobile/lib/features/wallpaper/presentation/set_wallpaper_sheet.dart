import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../platform/wallpaper_service.dart';
import '../application/wallpaper_providers.dart';

/// Home / Lock / Both picker (T2.26).
Future<void> showSetWallpaperSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String imageUrl,
  required String itemId,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<void>(
    context: context,
    title: l10n?.setWallpaperTitle ?? 'Set wallpaper',
    child: Column(
      children: [
        _TargetTile(
          icon: Icons.home_outlined,
          label: l10n?.setWallpaperHome ?? 'Home screen',
          onTap: () =>
              _set(context, ref, imageUrl, itemId, WallpaperTarget.home),
        ),
        _TargetTile(
          icon: Icons.lock_outline,
          label: l10n?.setWallpaperLock ?? 'Lock screen',
          onTap: () =>
              _set(context, ref, imageUrl, itemId, WallpaperTarget.lock),
        ),
        _TargetTile(
          icon: Icons.phone_android,
          label: l10n?.setWallpaperBoth ?? 'Home and lock',
          onTap: () =>
              _set(context, ref, imageUrl, itemId, WallpaperTarget.both),
        ),
      ],
    ),
  );
}

Future<void> _set(
  BuildContext context,
  WidgetRef ref,
  String url,
  String itemId,
  WallpaperTarget target,
) async {
  Navigator.of(context).pop();
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(wallpaperServiceProvider).setWallpaper(
          url: url,
          target: target,
        );
    await HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n?.wallpaperSetSuccess ?? 'Wallpaper set.')),
    );
    await ref.read(analyticsServiceProvider).wallpaperSet(
          id: itemId,
          target: target.channelValue,
        );
  } catch (e, st) {
    await ErrorReporter.instance.record(e, st, reason: 'wallpaper.set');
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n?.wallpaperSetFailed ?? 'Could not set wallpaper.'),
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
