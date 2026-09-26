import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/widgets/osler_state_view.dart';

void main() {
  group('OslerLoadingView', () {
    testWidgets('shows a spinner and an optional message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OslerLoadingView(message: 'Loading...')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('renders without a message', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OslerLoadingView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('OslerStateView', () {
    testWidgets('shows title, message, and triggers the action button',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OslerStateView(
            icon: HugeIcons.strokeRoundedCalendarCheck01,
            title: 'No Appointments Found',
            message: 'There are no appointments scheduled.',
            actionLabel: 'Refresh',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.text('No Appointments Found'), findsOneWidget);
      expect(find.text('There are no appointments scheduled.'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('omits the action button when none is given', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OslerStateView(
            icon: HugeIcons.strokeRoundedCalendarCheck01,
            title: 'Nothing here',
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('OslerStateView.error defaults to a retry action',
        (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OslerStateView.error(onRetry: () => retried = true),
        ),
      );

      expect(find.text("Couldn't Load Data"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
