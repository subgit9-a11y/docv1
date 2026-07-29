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
  });
}
