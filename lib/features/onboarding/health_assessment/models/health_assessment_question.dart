import 'package:hugeicons/hugeicons.dart';

enum QuestionType {
  singleChoice,
  multiChoice,
  numberInput,
  textInput,
  slider,
  media
}

class HealthAssessmentQuestion {
  final String id;
  final String title;
  final String? subtitle;
  final QuestionType type;
  final List<List<dynamic>> icon;

  /// For [QuestionType.singleChoice] / [QuestionType.multiChoice].
  final List<String> options;

  /// For [QuestionType.slider] / [QuestionType.numberInput].
  final double min;
  final double max;
  final String? unit;

  /// True for the three AI-analysis steps (text/voice/photo) - these can be
  /// skipped, since they're supplementary input for the AI, not required
  /// clinical data.
  final bool optional;

  const HealthAssessmentQuestion({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.icon,
    this.options = const [],
    this.min = 0,
    this.max = 100,
    this.unit,
    this.optional = false,
  });
}

/// The kit's 17-step Comprehensive Health Assessment: goals through fitness
/// baseline (1-10), medical background (11-14), then three optional
/// AI-driven analysis steps (15-17: text, voice, photo) the AI can use for
/// a richer read than the structured answers alone.
const List<HealthAssessmentQuestion> healthAssessmentQuestions = [
  HealthAssessmentQuestion(
    id: 'goal',
    title: 'What is your main health goal?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedTarget02,
    options: [
      'Lose weight',
      'Build muscle',
      'Manage a condition',
      'General wellness',
    ],
  ),
  HealthAssessmentQuestion(
    id: 'gender',
    title: 'What is your gender?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedUserSquare,
    options: ['Male', 'Female', 'Other', 'Prefer not to say'],
  ),
  HealthAssessmentQuestion(
    id: 'age',
    title: 'How old are you?',
    type: QuestionType.slider,
    icon: HugeIcons.strokeRoundedCalendar03,
    min: 13,
    max: 100,
    unit: 'years',
  ),
  HealthAssessmentQuestion(
    id: 'height',
    title: "What's your height?",
    type: QuestionType.slider,
    icon: HugeIcons.strokeRoundedRuler,
    min: 120,
    max: 220,
    unit: 'cm',
  ),
  HealthAssessmentQuestion(
    id: 'weight',
    title: "What's your weight?",
    type: QuestionType.slider,
    icon: HugeIcons.strokeRoundedWeightScale01,
    min: 30,
    max: 200,
    unit: 'kg',
  ),
  HealthAssessmentQuestion(
    id: 'blood_type',
    title: 'What is your blood type?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedBloodType,
    options: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', "I don't know"],
  ),
  HealthAssessmentQuestion(
    id: 'fitness_level',
    title: 'How would you describe your fitness level?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedDumbbell01,
    options: ['Sedentary', 'Lightly active', 'Active', 'Very active'],
  ),
  HealthAssessmentQuestion(
    id: 'medical_conditions',
    title: 'Do you have any medical conditions?',
    subtitle: 'Select all that apply, or none.',
    type: QuestionType.multiChoice,
    icon: HugeIcons.strokeRoundedStethoscope02,
    options: [
      'Diabetes',
      'Hypertension',
      'Heart Disease',
      'Asthma',
      'None',
    ],
  ),
  HealthAssessmentQuestion(
    id: 'medications',
    title: 'Are you currently taking any medications?',
    type: QuestionType.textInput,
    icon: HugeIcons.strokeRoundedPill,
  ),
  HealthAssessmentQuestion(
    id: 'allergies',
    title: 'Do you have any allergies?',
    type: QuestionType.textInput,
    icon: HugeIcons.strokeRoundedAlert02,
  ),
  HealthAssessmentQuestion(
    id: 'alcohol_consumption',
    title: 'How often do you drink alcohol?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedDrink,
    options: ['Never', 'Occasionally', 'Frequently (3x weekly)', 'Daily'],
  ),
  HealthAssessmentQuestion(
    id: 'smoking',
    title: 'Do you smoke?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedCigarette,
    options: ['Never', 'Occasionally', 'Regularly', 'Trying to quit'],
  ),
  HealthAssessmentQuestion(
    id: 'sleep_quality',
    title: 'How many hours do you sleep on average?',
    type: QuestionType.slider,
    icon: HugeIcons.strokeRoundedMoon02,
    min: 3,
    max: 12,
    unit: 'hours',
  ),
  HealthAssessmentQuestion(
    id: 'diet',
    title: 'What best describes your diet?',
    type: QuestionType.singleChoice,
    icon: HugeIcons.strokeRoundedVegan,
    options: ['Balanced', 'Vegetarian', 'Vegan', 'Keto', 'No specific diet'],
  ),
  HealthAssessmentQuestion(
    id: 'ai_text_analysis',
    title: 'Describe how you have been feeling lately',
    subtitle: 'Optional - helps Osler AI tailor its suggestions.',
    type: QuestionType.textInput,
    icon: HugeIcons.strokeRoundedTextFont,
    optional: true,
  ),
  HealthAssessmentQuestion(
    id: 'ai_voice_analysis',
    title: 'Record a short voice note',
    subtitle: 'Optional - Osler AI can analyze tone and speech patterns.',
    type: QuestionType.media,
    icon: HugeIcons.strokeRoundedMic01,
    optional: true,
  ),
  HealthAssessmentQuestion(
    id: 'ai_photo_analysis',
    title: 'Take or upload a photo',
    subtitle: 'Optional - Osler AI can analyze visible symptoms.',
    type: QuestionType.media,
    icon: HugeIcons.strokeRoundedCamera01,
    optional: true,
  ),
];
