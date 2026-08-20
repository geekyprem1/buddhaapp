import 'package:dhamma_path/features/auth/presentation/login_screen.dart';
import 'package:dhamma_path/l10n/generated/app_localizations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('phone field accepts 10 digits next to +91', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+91'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '9625460555');
    await tester.pump();

    expect(find.text('9625460555'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
  });
}
