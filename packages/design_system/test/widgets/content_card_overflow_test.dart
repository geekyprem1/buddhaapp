import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ContentCard in a tight grid cell does not overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 220,
              child: ContentCard(
                thumbUrl: null,
                title:
                    'A very long wallpaper title that used to overflow the grid',
                overlay: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: null,
                        child: Text('Set wallpaper'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ContentCard), findsOneWidget);
  });

  testWidgets('teacher chip row fits a 48dp strip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: TeacherFilterChipRow(
            teachers: const [
              TeacherChipData(id: 't1', label: 'Gautam Buddha'),
              TeacherChipData(id: 't2', label: 'Dr. B. R. Ambedkar'),
            ],
            selectedTeacherId: null,
            onSelect: (_) {},
            onAddTeacher: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
