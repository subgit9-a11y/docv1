import 'package:doctro/features/onboarding/health_assessment/models/health_assessment_question.dart';

/// Fraction of the assessment completed once [index] (0-based) is the
/// current step, out of [total] steps. Pure so it's unit-testable without a
/// controller.
double assessmentProgress(int index, int total) {
  if (total <= 0) return 0;
  return (index + 1).clamp(0, total) / total;
}

/// Whether [answer] satisfies [question] well enough to move on. Optional
/// questions (the AI analysis steps) are always satisfied, since they're
/// supplementary input, not required data.
bool isQuestionAnswered(HealthAssessmentQuestion question, Object? answer) {
  if (question.optional) return true;

  switch (question.type) {
    case QuestionType.singleChoice:
      return answer is String && answer.isNotEmpty;
    case QuestionType.multiChoice:
      return answer is List && answer.isNotEmpty;
    case QuestionType.numberInput:
    case QuestionType.slider:
      return answer is num;
    case QuestionType.textInput:
      return answer is String && answer.trim().isNotEmpty;
    case QuestionType.media:
      return answer == true;
  }
}
