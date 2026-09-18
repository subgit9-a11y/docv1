import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/widgets/session_timeout_handler.dart';

void main() {
  group('SessionTimeoutHandler Widget Test', () {
    testWidgets('Renders child and accepts interaction',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionTimeoutHandler(
              onTimeout: () {},
              child: GestureDetector(
                onTap: () => tapped = true,
                child: const Center(child: Text('Content')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);

      await tester.tap(find.text('Content'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Fires onTimeout once the idle timeout elapses',
        (WidgetTester tester) async {
      var timeouts = 0;
      var now = DateTime(2026, 1, 1, 12);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionTimeoutHandler(
              timeout: const Duration(minutes: 15),
              clock: () => now,
              onTimeout: () => timeouts++,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      expect(timeouts, 0);

      // Ticker runs every 30s. Move past the window and let it check.
      now = now.add(const Duration(minutes: 16));
      await tester.pump(const Duration(seconds: 31));
      expect(timeouts, 1);

      // Already timed out: further checks must not fire again.
      await tester.pump(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 31));
      expect(timeouts, 1);
    });

    testWidgets('User activity defers the timeout',
        (WidgetTester tester) async {
      var timeouts = 0;
      var now = DateTime(2026, 1, 1, 12);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionTimeoutHandler(
              timeout: const Duration(minutes: 15),
              clock: () => now,
              onTimeout: () => timeouts++,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      // Stay active just under the window across several ticks.
      for (var i = 0; i < 5; i++) {
        now = now.add(const Duration(minutes: 10));
        await tester.pump(const Duration(seconds: 31));
        await tester.tap(find.text('Content'));
        await tester.pump();
      }
      expect(timeouts, 0);

      // Now go idle past the window.
      now = now.add(const Duration(minutes: 20));
      await tester.pump(const Duration(seconds: 31));
      expect(timeouts, 1);
    });
  });
}
