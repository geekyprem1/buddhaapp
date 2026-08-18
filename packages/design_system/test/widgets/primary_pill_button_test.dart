import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));
  }

  group('PrimaryPillButton', () {
    testWidgets('renders label and responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          PrimaryPillButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null (FR-3.3 pattern)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const PrimaryPillButton(label: 'Continue', onPressed: null)),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('meets the 48dp minimum touch target', (tester) async {
      await tester.pumpWidget(
        wrap(PrimaryPillButton(label: 'Continue', onPressed: () {})),
      );

      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('TeacherFilterChipRow', () {
    testWidgets('shows All plus each teacher, and reports selection', (
      tester,
    ) async {
      String? selected = 'existing';
      await tester.pumpWidget(
        wrap(
          TeacherFilterChipRow(
            teachers: const [
              TeacherChipData(id: 'buddha', label: 'Gautam Buddha'),
              TeacherChipData(id: 'ambedkar', label: 'Dr. B. R. Ambedkar'),
            ],
            selectedTeacherId: selected,
            onSelect: (id) => selected = id,
            onAddTeacher: () {},
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Gautam Buddha'), findsOneWidget);
      expect(find.text('Dr. B. R. Ambedkar'), findsOneWidget);

      await tester.tap(find.text('All'));
      expect(selected, isNull);
    });
  });
}
