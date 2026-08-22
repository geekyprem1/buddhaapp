import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accessibility/application/zoom_controller.dart';
import '../widgets/pinch_zoom_area.dart';
import 'admin_strings.dart';
import 'router.dart';

class DhammaPathAdminApp extends ConsumerWidget {
  const DhammaPathAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    return MaterialApp.router(
      title: '${AdminStrings.appName} · ${AdminStrings.deskName}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.admin(),
      routerConfig: router,
      builder: (context, child) {
        // Accessibility text zoom (WCAG 1.4.4 resize text). Applies the
        // editor's chosen scale to every piece of text in the desk.
        final zoom = ref.watch(zoomControllerProvider);
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(zoom)),
          child: PinchZoomArea(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
