import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_controller.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_screen.dart';
import 'package:doctro/features/onboarding/health_assessment/models/health_assessment_question.dart';

void main() {
  const questions = [
    HealthAssessmentQuestion(
      id: 'goal',
      title: 'What is your main health goal?',
      type: QuestionType.singleChoice,
      icon: [],
      options: ['Lose weight', 'Build muscle'],
    ),
    HealthAssessmentQuestion(
      id: 'notes',
      title: 'Anything else?',
      type: QuestionType.textInput,
      icon: [],
      optional: true,
    ),
  ];

  testWidgets(
      'blocks Continue until answered, then completes and calls onFinish',
      (WidgetTester tester) async {
    final controller = HealthAssessmentController(questions: questions);
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: HealthAssessmentScreen(
          controller: controller,
          onFinish: () => finished = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What is your main health goal?'), findsOneWidget);

    final continueButton = tester.widget<ElevatedButton>(find.descendant(
      of: find.byType(HealthAssessmentScreen),
      matching: find.byType(ElevatedButton),
    ));
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('Lose weight'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Anything else?'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text("You're All Set!"), findsOneWidget);

    await tester.tap(find.text("Let's Get Healthy"));
    await tester.pump();

    expect(finished, isTrue);
  });
}
