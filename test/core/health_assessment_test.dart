import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_controller.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_progress.dart';
import 'package:doctro/features/onboarding/health_assessment/models/health_assessment_question.dart';

void main() {
  group('healthAssessmentQuestions', () {
    test('has exactly 17 steps', () {
      expect(healthAssessmentQuestions, hasLength(17));
    });

    test('every id is unique', () {
      final ids = healthAssessmentQuestions.map((q) => q.id).toSet();
      expect(ids, hasLength(healthAssessmentQuestions.length));
    });

    test('the three AI analysis steps are optional; the rest are required', () {
      final optionalIds =
          healthAssessmentQuestions.where((q) => q.optional).map((q) => q.id);
      expect(optionalIds,
          ['ai_text_analysis', 'ai_voice_analysis', 'ai_photo_analysis']);
    });
  });

  group('assessmentProgress', () {
    test('is 0 for a zero-length assessment', () {
      expect(assessmentProgress(0, 0), 0);
    });

    test('reaches 1.0 on the last step', () {
      expect(assessmentProgress(16, 17), 1.0);
    });

    test('is a fraction mid-way through', () {
      expect(assessmentProgress(0, 4), 0.25);
    });
  });

  group('isQuestionAnswered', () {
    const required = HealthAssessmentQuestion(
      id: 'q',
      title: 't',
      type: QuestionType.singleChoice,
      icon: [],
      options: ['A', 'B'],
    );
    const optional = HealthAssessmentQuestion(
      id: 'q',
      title: 't',
      type: QuestionType.textInput,
      icon: [],
      optional: true,
    );

    test('a required singleChoice needs a non-empty string', () {
      expect(isQuestionAnswered(required, null), isFalse);
      expect(isQuestionAnswered(required, ''), isFalse);
      expect(isQuestionAnswered(required, 'A'), isTrue);
    });

    test('an optional question is always answered', () {
      expect(isQuestionAnswered(optional, null), isTrue);
    });
  });

  group('HealthAssessmentController', () {
    test('cannot advance past a required unanswered question', () {
      final controller = HealthAssessmentController();
      expect(controller.canProceed, isFalse);

      controller.next();
      expect(controller.index, 0);
    });

    test('advances once the current question is answered', () {
      final controller = HealthAssessmentController();
      controller.setAnswer(controller.currentQuestion.id, 'Lose weight');
      expect(controller.canProceed, isTrue);

      controller.next();
      expect(controller.index, 1);
    });

    test('back() steps back and never goes below 0', () {
      final controller = HealthAssessmentController();
      controller.back();
      expect(controller.index, 0);
    });

    test('isComplete becomes true after the last question', () {
      final controller = HealthAssessmentController(
        questions: const [
          HealthAssessmentQuestion(
            id: 'only',
            title: 't',
            type: QuestionType.textInput,
            icon: [],
            optional: true,
          ),
        ],
      );

      expect(controller.isComplete, isFalse);
      controller.next();
      expect(controller.isComplete, isTrue);
      expect(controller.progress, 1.0);
    });
  });
}
