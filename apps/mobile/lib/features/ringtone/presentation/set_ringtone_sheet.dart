import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../platform/ringtone_service.dart';
import '../application/ringtone_providers.dart';

/// Ringtone / Alarm / Notification picker plus download & share (T2.40, T2.42).
Future<void> showSetRingtoneSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String audioUrl,
  required String itemId,
  required String title,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<void>(
    context: context,
    title: l10n?.setRingtoneTitle ?? 'Set as',
    child: Column(
      children: [
        _KindTile(
          icon: Icons.phone_in_talk_outlined,
          label: l10n?.setRingtoneKind ?? 'Ringtone',
          onTap: () => applyRingtoneKind(
            context: context,
            ref: ref,
            url: audioUrl,
            itemId: itemId,
            kind: RingtoneKind.ringtone,
          ),
        ),
        _KindTile(
          icon: Icons.alarm,
          label: l10n?.setAlarmKind ?? 'Alarm',
          onTap: () => applyRingtoneKind(
            context: context,
            ref: ref,
            url: audioUrl,
            itemId: itemId,
            kind: RingtoneKind.alarm,
          ),
        ),
        _KindTile(
          icon: Icons.notifications_outlined,
          label: l10n?.setNotificationKind ?? 'Notification',
          onTap: () => applyRingtoneKind(
            context: context,
            ref: ref,
            url: audioUrl,
            itemId: itemId,
            kind: RingtoneKind.notification,
          ),
        ),
        const Divider(),
        _KindTile(
          icon: Icons.download_outlined,
          label: l10n?.download ?? 'Download',
          onTap: () => _download(context, ref, audioUrl),
        ),
        _KindTile(
          icon: Icons.share_outlined,
          label: l10n?.share ?? 'Share',
          onTap: () => _share(context, ref, audioUrl, title),
        ),
      ],
    ),
  );
}

String ringtoneKindLabel(AppLocalizations? l10n, RingtoneKind kind) {
  switch (kind) {
    case RingtoneKind.alarm:
      return l10n?.setAlarmKind ?? 'Alarm';
    case RingtoneKind.notification:
      return l10n?.setNotificationKind ?? 'Notification';
    case RingtoneKind.ringtone:
      return l10n?.setRingtoneKind ?? 'Ringtone';
  }
}

Future<void> applyRingtoneKind({
  required BuildContext context,
  required WidgetRef ref,
  required String url,
  required String itemId,
  required RingtoneKind kind,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }

  final pending = PendingRingtoneSet(url: url, itemId: itemId, kind: kind);
  final service = ref.read(ringtoneServiceProvider);

  try {
    final allowed = await service.canWriteSettings();
    if (!allowed) {
      if (!context.mounted) return;
      final opened = await _showRationale(context, l10n);
      if (opened == true) {
        ref.read(pendingRingtoneProvider.notifier).hold(pending);
        await ref.read(analyticsServiceProvider).permissionPrompt(
              type: 'write_settings',
              result: 'opened',
            );
        await service.openWriteSettings();
      }
      return;
    }
    await _commitSet(ref, pending);
    await HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n?.ringtoneSetSuccess(ringtoneKindLabel(l10n, kind)) ??
              'Tone set.',
        ),
      ),
    );
  } on PlatformException catch (e) {
    if (e.code == 'write_settings_denied') {
      if (!context.mounted) return;
      final opened = await _showRationale(context, l10n);
      if (opened == true) {
        ref.read(pendingRingtoneProvider.notifier).hold(pending);
        await service.openWriteSettings();
      }
      return;
    }
    await ErrorReporter.instance
        .record(e, StackTrace.current, reason: 'ringtone.set');
    messenger.showSnackBar(
      SnackBar(content: Text(_setErrorMessage(e, l10n))),
    );
  } catch (e, st) {
    await ErrorReporter.instance.record(e, st, reason: 'ringtone.set');
    messenger.showSnackBar(
      SnackBar(content: Text(_setErrorMessage(e, l10n))),
    );
  }
}

Future<void> completePendingRingtoneSet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final pending = ref.read(pendingRingtoneProvider);
  if (pending == null) return;

  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(ringtoneServiceProvider);

  if (!await service.canWriteSettings()) {
    ref.read(pendingRingtoneProvider.notifier).clear();
    await ref.read(analyticsServiceProvider).permissionPrompt(
          type: 'write_settings',
          result: 'denied',
        );
    if (!context.mounted) return;
    await ErrorReporter.instance.record(
      StateError('write_settings_denied'),
      StackTrace.current,
      reason: 'ringtone.permission_denied',
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n?.ringtonePermissionDenied ??
              'Permission is still off. Open Help to turn it on.',
        ),
      ),
    );
    return;
  }

  try {
    await _commitSet(ref, pending);
    await HapticFeedback.mediumImpact();
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n?.ringtoneSetSuccess(
                ringtoneKindLabel(l10n, pending.kind),
              ) ??
              'Tone set.',
        ),
      ),
    );
  } catch (e, st) {
    ref.read(pendingRingtoneProvider.notifier).clear();
    await ErrorReporter.instance.record(e, st, reason: 'ringtone.set');
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(_setErrorMessage(e, l10n))),
    );
  }
}

Future<void> _commitSet(WidgetRef ref, PendingRingtoneSet pending) async {
  await ref.read(ringtoneServiceProvider).setTone(
        url: pending.url,
        kind: pending.kind,
      );
  ref.read(pendingRingtoneProvider.notifier).clear();
  await ref.read(analyticsServiceProvider).ringtoneSet(
        id: pending.itemId,
        target: pending.kind.channelValue,
      );
}

Future<bool?> _showRationale(BuildContext context, AppLocalizations? l10n) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n?.ringtonePermissionTitle ?? 'Allow system settings'),
      content: Text(
        l10n?.ringtonePermissionBody ??
            'To set a ringtone, alarm or notification sound, Android needs '
                'permission to change system settings. We only use this to set '
                'the sound you chose.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n?.ringtonePermissionAllow ?? 'Open settings'),
        ),
      ],
    ),
  );
}

Future<void> _download(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  try {
    await ref.read(ringtoneServiceProvider).saveToDevice(url: url);
    await HapticFeedback.lightImpact();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n?.ringtoneSaved ?? 'Saved to your device.')),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(_setErrorMessage(e, l10n))),
    );
  }
}

String _setErrorMessage(Object error, AppLocalizations? l10n) {
  if (error is MissingPluginException) {
    return 'Restart the app fully to enable ringtone set.';
  }
  final text = error.toString();
  if (text.contains('HttpException') ||
      text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Invalid statusCode') ||
      text.contains('Downloaded audio is empty') ||
      text.contains('Failed host lookup')) {
    return l10n?.ringtoneDownloadFailed ?? 'Could not download the audio.';
  }
  return l10n?.ringtoneSetFailed ?? 'Could not set the tone.';
}

Future<void> _share(
  BuildContext context,
  WidgetRef ref,
  String url,
  String title,
) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  await ref.read(ringtoneServiceProvider).share(url: url, title: title);
}

class _KindTile extends StatelessWidget {
  const _KindTile({
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
