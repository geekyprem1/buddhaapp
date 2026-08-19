import 'package:core/core.dart';
import 'package:dhamma_path_admin/app/admin_strings.dart';
import 'package:dhamma_path_admin/widgets/localised_text_field.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('localised field shows language tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.admin(),
        home: Scaffold(
          body: LocalisedTextField(
            label: 'Title',
            value: const LocalisedText(en: 'Hello'),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(AdminStrings.english), findsOneWidget);
    expect(find.text(AdminStrings.hindi), findsOneWidget);
    expect(find.text(AdminStrings.marathi), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}
