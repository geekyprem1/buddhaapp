import 'package:flutter/material.dart';

import '../app/admin_strings.dart';
import 'confirm_dialog.dart';

/// Blocks in-app back navigation while a form is dirty (AR-8.3).
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    required this.dirty,
    required this.child,
    super.key,
  });

  final bool dirty;
  final Widget child;

  static Future<bool> confirmLeave(BuildContext context) {
    return ConfirmDialog.show(
      context,
      title: AdminStrings.unsavedTitle,
      body: AdminStrings.unsavedBody,
      confirmLabel: AdminStrings.discard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !dirty) return;
        final leave = await confirmLeave(context);
        if (leave && context.mounted) Navigator.of(context).maybePop();
      },
      child: child,
    );
  }
}
