import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// Reliable escape from non-home tab roots, where there is no route to pop
/// after the persistent navigation bar has been removed.
class HomeAppBarButton extends StatelessWidget {
  const HomeAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)?.navHome ?? 'Home';
    return IconButton(
      tooltip: label,
      onPressed: () {
        AppHaptics.selection();
        context.go(AppRoutes.home);
      },
      icon: const Icon(Icons.home_outlined),
    );
  }
}
