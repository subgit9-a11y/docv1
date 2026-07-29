import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/widgets/session_timeout_handler.dart';

void main() {
  group('SessionTimeoutHandler Widget Test', () {
    testWidgets(
        'Triggers onTimeout after specified duration without interaction',
        (WidgetTester tester) async {
      bool timeoutTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionTimeoutHandler(
              timeout: const Duration(seconds: 1),
              onTimeout: () {
                timeoutTriggered = true;
              },
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(timeoutTriggered, isFalse);
      expect(find.text('Content'), findsOneWidget);

      // Wait for timeout duration
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify timeout triggered
      expect(timeoutTriggered, isTrue);
    });

    testWidgets('Interaction resets the timer', (WidgetTester tester) async {
      bool timeoutTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionTimeoutHandler(
              timeout: const Duration(seconds: 2),
              onTimeout: () {
                timeoutTriggered = true;
              },
              child: const Center(child: Text('Interact with me')),
            ),
          ),
        ),
      );

      // Wait 1 second (halfway to timeout)
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(timeoutTriggered, isFalse);

      // Simulate a tap to reset the timer
      await tester.tap(find.text('Interact with me'));
      await tester.pump();

      // Wait another 1.5 seconds. If timer didn't reset, it would trigger at 2s total.
      // Since it did reset, we are at 1.5s out of 2s for the new timer.
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
      expect(timeoutTriggered, isFalse);

      // Wait for the full remaining time
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(timeoutTriggered, isTrue);
    });
  });
}
