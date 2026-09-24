import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/errors/error_utility_screen.dart';

void main() {
  group('ErrorUtilityScreen', () {
    testWidgets('renders each kind with its title and default badge',
        (WidgetTester tester) async {
      const cases = {
        ErrorUtilityKind.notFound: 'Not Found',
        ErrorUtilityKind.noInternet: 'No Internet',
        ErrorUtilityKind.internalError: 'Internal Error',
        ErrorUtilityKind.maintenance: 'Maintenance',
        ErrorUtilityKind.notAllowed: 'Not Allowed',
      };

      for (final entry in cases.entries) {
        await tester.pumpWidget(
          MaterialApp(home: ErrorUtilityScreen(kind: entry.key)),
        );
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget);
        expect(find.text('Take Me Home'), findsOneWidget);
      }
    });

    testWidgets('invokes onAction instead of the default navigation',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorUtilityScreen(
            kind: ErrorUtilityKind.noInternet,
            onAction: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Take Me Home'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('honors a custom badge label override',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorUtilityScreen(
            kind: ErrorUtilityKind.maintenance,
            badgeLabel: 'Come back in 8h 12m',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Come back in 8h 12m'), findsOneWidget);
    });
  });
}
