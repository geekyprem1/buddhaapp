import 'package:dhamma_path_admin/widgets/idle_timeout_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fires onTimeout after the idle window with no input', (
    tester,
  ) async {
    var fired = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: IdleTimeoutListener(
          timeout: const Duration(milliseconds: 40),
          onTimeout: () => fired++,
          child: const ColoredBox(
          color: Color(0xFF000000),
          child: SizedBox(width: 20, height: 20),
        ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(fired, 1);
  });

  testWidgets('pointer activity resets the idle window', (tester) async {
    var fired = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: IdleTimeoutListener(
          timeout: const Duration(milliseconds: 40),
          onTimeout: () => fired++,
          child: const ColoredBox(
            key: Key('idle-target'),
            color: Color(0xFF000000),
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 25));
    await tester.tap(find.byKey(const Key('idle-target')));
    await tester.pump(const Duration(milliseconds: 25));
    expect(fired, 0);
    await tester.pump(const Duration(milliseconds: 40));
    expect(fired, 1);
  });
}
