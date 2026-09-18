import 'package:dhamma_path/features/bodhi_ai/application/bodhi_chat_store.dart';
import 'package:dhamma_path/features/bodhi_ai/presentation/widgets/bodhi_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  BodhiMessage message, {
  bool animateReveal = false,
  VoidCallback? onCopy,
  VoidCallback? onReport,
  VoidCallback? onRevealComplete,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(800, 600),
        disableAnimations: disableAnimations,
      ),
      child: Scaffold(
        body: BodhiMessageBubble(
          message: message,
          animateReveal: animateReveal,
          onCopy: onCopy,
          onReport: onReport,
          onRevealComplete: onRevealComplete,
        ),
      ),
    ),
  );
}

void main() {
  const reply = BodhiMessage(
    role: 'assistant',
    text: 'A calm and complete response about the Dhamma.',
  );

  testWidgets('settled assistant reply exposes copy and report actions',
      (tester) async {
    var copies = 0;
    var reports = 0;
    await tester.pumpWidget(
      _host(
        reply,
        onCopy: () => copies++,
        onReport: () => reports++,
      ),
    );

    expect(find.text(reply.text), findsOneWidget);
    await tester.tap(find.byTooltip('Copy response'));
    await tester.tap(find.byTooltip('Report response'));
    expect(copies, 1);
    expect(reports, 1);
  });

  testWidgets('new assistant reply reveals progressively', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      _host(
        reply,
        animateReveal: true,
        onRevealComplete: () => completions++,
      ),
    );

    expect(find.text(reply.text), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(reply.text), findsOneWidget);
    expect(completions, 1);

    await tester.pump(const Duration(seconds: 1));
    expect(completions, 1);
  });

  testWidgets('reduced motion shows the reply immediately', (tester) async {
    await tester.pumpWidget(
      _host(reply, animateReveal: true, disableAnimations: true),
    );

    expect(find.text(reply.text), findsOneWidget);
  });

  testWidgets('reveal does not restart after scrolling off screen',
      (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    var completions = 0;
    var reveal = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ListView.builder(
              controller: scroll,
              itemCount: 2,
              itemBuilder: (context, index) => index == 0
                  ? const SizedBox(height: 1000)
                  : BodhiMessageBubble(
                      message: reply,
                      animateReveal: reveal,
                      onRevealComplete: () {
                        completions++;
                        setState(() => reveal = false);
                      },
                    ),
            ),
          ),
        ),
      ),
    );

    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    scroll.jumpTo(0);
    await tester.pump(const Duration(seconds: 2));
    expect(completions, 1);

    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    expect(find.text(reply.text), findsOneWidget);
    expect(completions, 1);
  });
}
