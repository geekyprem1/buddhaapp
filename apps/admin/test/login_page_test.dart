import 'package:dhamma_path_admin/app/admin_strings.dart';
import 'package:dhamma_path_admin/features/auth/presentation/login_page.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders email, password and Sign in; no social/phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.admin(),
          home: const LoginPage(),
        ),
      ),
    );

    expect(find.text(AdminStrings.signIn), findsOneWidget);
    expect(find.text(AdminStrings.emailLabel), findsOneWidget);
    expect(find.text(AdminStrings.passwordLabel), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Continue with OTP'), findsNothing);
    expect(find.text('+91'), findsNothing);
  });

  testWidgets('empty submit shows field errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.admin(),
          home: const LoginPage(),
        ),
      ),
    );

    await tester.tap(find.text(AdminStrings.signIn));
    await tester.pump();

    expect(find.text(AdminStrings.passwordRequired), findsOneWidget);
  });
}
