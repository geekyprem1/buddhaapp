import 'package:flutter/material.dart';

import '../app/admin_strings.dart';
import 'responsive_layout.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.body,
    this.confirmLabel = AdminStrings.confirm,
    super.key,
  });

  final String title;
  final String body;
  final String confirmLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = AdminStrings.confirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AdminResponsive.isCompact(context) ? 16 : 40,
        vertical: 24,
      ),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AdminStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
