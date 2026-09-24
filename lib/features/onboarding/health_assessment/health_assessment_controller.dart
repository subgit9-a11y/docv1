import 'package:flutter/foundation.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_progress.dart';
import 'package:doctro/features/onboarding/health_assessment/models/health_assessment_question.dart';

class HealthAssessmentController extends ChangeNotifier {
  final List<HealthAssessmentQuestion> questions;
  final Map<String, Object?> _answers = {};
  int _index = 0;

  HealthAssessmentController({
    this.questions = healthAssessmentQuestions,
  });

  int get index => _index;
  int get total => questions.length;
  bool get isComplete => _index >= questions.length;
  double get progress => assessmentProgress(_index, questions.length);

  HealthAssessmentQuestion get currentQuestion => questions[_index];
  Object? answerFor(String questionId) => _answers[questionId];
  Map<String, Object?> get answers => Map.unmodifiable(_answers);

  bool get canProceed =>
      isComplete ||
      isQuestionAnswered(currentQuestion, _answers[currentQuestion.id]);

  void setAnswer(String questionId, Object? value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  void next() {
    if (isComplete || !canProceed) return;
    _index++;
    notifyListeners();
  }

  void back() {
    if (_index == 0) return;
    _index--;
    notifyListeners();
  }
}
