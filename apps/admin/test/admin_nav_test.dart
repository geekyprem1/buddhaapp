import 'package:core/core.dart';
import 'package:dhamma_path_admin/app/admin_access.dart';
import 'package:dhamma_path_admin/app/admin_shell.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setTallSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('side nav hides Users for a content manager', (tester) async {
    await setTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.admin(),
        home: Scaffold(
          body: AdminSideNav(
            destinations: visibleFor(AdminRole.contentManager),
            currentPath: AdminRoutes.dashboard,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Teachers'), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(find.text('App config'), findsNothing);
  });

  testWidgets('side nav shows Users for a super admin', (tester) async {
    await setTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.admin(),
        home: Scaffold(
          body: AdminSideNav(
            destinations: visibleFor(AdminRole.superAdmin),
            currentPath: AdminRoutes.dashboard,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Teachers'), findsOneWidget);
  });
}
