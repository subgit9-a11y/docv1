import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/theme/app_motion.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_controller.dart';
import 'package:doctro/features/onboarding/health_assessment/models/health_assessment_question.dart';

class HealthAssessmentScreen extends StatefulWidget {
  final HealthAssessmentController controller;
  final VoidCallback onFinish;

  const HealthAssessmentScreen({
    super.key,
    required this.controller,
    required this.onFinish,
  });

  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: AyurezeTheme.canvas,
      body: SafeArea(
        child: controller.isComplete
            ? _CompletionView(onFinish: widget.onFinish)
            : Padding(
                padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              controller.index == 0 ? null : controller.back,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: AyurezeTheme.iconPrimary,
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AyurezeTheme.radiusPill),
                            child: LinearProgressIndicator(
                              value: controller.progress,
                              minHeight: 8,
                              backgroundColor: AyurezeTheme.border,
                              valueColor: const AlwaysStoppedAnimation(
                                  AyurezeTheme.healingGreenFill),
                            ),
                          ),
                        ),
                        const SizedBox(width: AyurezeTheme.spaceMd),
                        Text('${controller.index + 1}/${controller.total}'),
                      ],
                    ),
                    Expanded(
                      child: ScreenEntrance(
                        key: ValueKey(controller.currentQuestion.id),
                        child: _QuestionView(
                          question: controller.currentQuestion,
                          answer: controller
                              .answerFor(controller.currentQuestion.id),
                          onAnswer: (value) => controller.setAnswer(
                              controller.currentQuestion.id, value),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (controller.currentQuestion.optional) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.next,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AyurezeTheme.radiusPill),
                                ),
                              ),
                              child: const Text('Skip'),
                            ),
                          ),
                          const SizedBox(width: AyurezeTheme.spaceSm),
                        ],
                        Expanded(
                          flex: 2,
                          child: OslerButton(
                            text: 'Continue',
                            onPressed:
                                controller.canProceed ? controller.next : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final HealthAssessmentQuestion question;
  final Object? answer;
  final ValueChanged<Object?> onAnswer;

  const _QuestionView({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AyurezeTheme.spaceLg),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AyurezeTheme.healingGreen10,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: question.icon,
              color: AyurezeTheme.healingGreen100,
            ),
          ),
          const SizedBox(height: AyurezeTheme.spaceLg),
          Text(question.title,
              style: Theme.of(context).textTheme.headlineMedium),
          if (question.subtitle != null) ...[
            const SizedBox(height: AyurezeTheme.spaceSm),
            Text(
              question.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AyurezeTheme.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: AyurezeTheme.space2xl),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return Wrap(
          spacing: AyurezeTheme.spaceSm,
          runSpacing: AyurezeTheme.spaceSm,
          children: [
            for (final option in question.options)
              ChoiceChip(
                label: Text(option),
                selected: answer == option,
                onSelected: (_) => onAnswer(option),
              ),
          ],
        );
      case QuestionType.multiChoice:
        final selected = (answer as List?)?.cast<String>() ?? const <String>[];
        return Wrap(
          spacing: AyurezeTheme.spaceSm,
          runSpacing: AyurezeTheme.spaceSm,
          children: [
            for (final option in question.options)
              FilterChip(
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (isSelected) {
                  final updated = List<String>.from(selected);
                  if (isSelected) {
                    updated.add(option);
                  } else {
                    updated.remove(option);
                  }
                  onAnswer(updated);
                },
              ),
          ],
        );
      case QuestionType.slider:
        final value = (answer as num?)?.toDouble() ?? question.min;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${value.round()}${question.unit != null ? ' ${question.unit}' : ''}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Slider(
              value: value.clamp(question.min, question.max),
              min: question.min,
              max: question.max,
              activeColor: AyurezeTheme.healingGreenFill,
              onChanged: onAnswer,
            ),
          ],
        );
      case QuestionType.numberInput:
      case QuestionType.textInput:
        return TextField(
          maxLines: question.type == QuestionType.textInput ? 4 : 1,
          keyboardType: question.type == QuestionType.numberInput
              ? TextInputType.number
              : TextInputType.text,
          onChanged: onAnswer,
          decoration: InputDecoration(
            hintText: 'Type your answer',
            filled: true,
            fillColor: AyurezeTheme.oslerGray10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusLg),
              borderSide: BorderSide.none,
            ),
          ),
        );
      case QuestionType.media:
        final attached = answer == true;
        return OutlinedButton.icon(
          onPressed: () => onAnswer(true),
          icon: HugeIcon(
            icon: attached
                ? HugeIcons.strokeRoundedCheckmarkCircle02
                : question.icon,
            color: AyurezeTheme.healingGreen100,
          ),
          label: Text(attached ? 'Attached' : 'Attach'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusPill),
            ),
          ),
        );
    }
  }
}

class _CompletionView extends StatelessWidget {
  final VoidCallback onFinish;

  const _CompletionView({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AyurezeTheme.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AyurezeTheme.healingGreen10,
                shape: BoxShape.circle,
              ),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: AyurezeTheme.healingGreen100,
                size: 40,
              ),
            ),
            const SizedBox(height: AyurezeTheme.spaceLg),
            Text("You're All Set!",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AyurezeTheme.spaceSm),
            Text(
              'Osler AI is putting your answers to work. Your personalized '
              'health insights will appear on your dashboard shortly.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AyurezeTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AyurezeTheme.space2xl),
            SizedBox(
              width: double.infinity,
              child:
                  OslerButton(text: "Let's Get Healthy", onPressed: onFinish),
            ),
          ],
        ),
      ),
    );
  }
}
