import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/search/models/search_result.dart';
import 'package:doctro/features/search/search_screen.dart';

void main() {
  const results = [
    SearchResult(
      title: 'AI Symptom Checker',
      subtitle: 'Analyze your symptoms',
      category: SearchResultCategory.resources,
      matchPercent: 99,
    ),
    SearchResult(
      title: 'Find a Doctor',
      subtitle: 'Browse doctors by specialization',
      category: SearchResultCategory.doctor,
      matchPercent: 54,
    ),
  ];

  testWidgets('shows the start-searching state, then filters as you type',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(results: results)),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI Symptom Checker'), findsOneWidget);
    expect(find.text('Find a Doctor'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'doctor');
    await tester.pumpAndSettle();

    expect(find.text('Find a Doctor'), findsOneWidget);
    expect(find.text('AI Symptom Checker'), findsNothing);
  });

  testWidgets('shows the start-searching state when there are no results',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(results: [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start Searching'), findsOneWidget);
  });

  testWidgets('shows a not-found state for a query that matches nothing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(results: results)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pumpAndSettle();

    expect(find.text('Woops, Not Found'), findsOneWidget);
  });

  testWidgets('filters by category chip', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchScreen(results: results)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Doctor'));
    await tester.pumpAndSettle();

    expect(find.text('Find a Doctor'), findsOneWidget);
    expect(find.text('AI Symptom Checker'), findsNothing);
  });
}
