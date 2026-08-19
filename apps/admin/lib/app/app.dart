import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}
