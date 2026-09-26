import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/theme/app_motion.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_card.dart';
import 'package:doctro/widgets/osler_input.dart';
import 'package:doctro/widgets/osler_tag.dart';
import 'package:doctro/widgets/osler_state_view.dart';
import 'package:doctro/features/medications/medication_controller.dart';
import 'package:doctro/features/medications/models/medication.dart';
import 'package:doctro/features/medications/models/medication_dose_log.dart';

class MedicationManagementScreen extends StatefulWidget {
  final MedicationController controller;

  const MedicationManagementScreen({super.key, required this.controller});

  @override
  State<MedicationManagementScreen> createState() =>
      _MedicationManagementScreenState();
}

class _MedicationManagementScreenState
    extends State<MedicationManagementScreen> {
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
    final medications = widget.controller.medications;

    return Scaffold(
      backgroundColor: AyurezeTheme.canvas,
      appBar: AppBar(
        backgroundColor: AyurezeTheme.canvas,
        elevation: 0,
        title: const Text('My Medications'),
        foregroundColor: AyurezeTheme.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AyurezeTheme.healingGreenFill,
        onPressed: () => _showAddMedicationSheet(context),
        child: const HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01, color: Colors.white),
      ),
      body: medications.isEmpty
          ? _EmptyMedications(onAdd: () => _showAddMedicationSheet(context))
          : ListView(
              padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
              children: [
                ScreenEntrance(
                    child: _AdherenceCard(controller: widget.controller)),
                const SizedBox(height: AyurezeTheme.space2xl),
                for (var i = 0; i < medications.length; i++)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AyurezeTheme.spaceSm),
                    child: ScreenEntrance(
                      index: i + 1,
                      child: _MedicationTile(
                        medication: medications[i],
                        onLogDose: (status) => widget.controller
                            .logDose(medications[i].id, status),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showAddMedicationSheet(BuildContext context) {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final timingController = TextEditingController(text: 'After Eating');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AyurezeTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AyurezeTheme.radius2xl)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AyurezeTheme.spaceXl,
          right: AyurezeTheme.spaceXl,
          top: AyurezeTheme.spaceXl,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
              AyurezeTheme.spaceXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Medication',
                style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: AyurezeTheme.spaceLg),
            OslerInput(
              label: 'Medication Name',
              hint: 'e.g. Amoxiciline',
              controller: nameController,
            ),
            const SizedBox(height: AyurezeTheme.spaceLg),
            OslerInput(
              label: 'Dose & Measurement',
              hint: 'e.g. 500mg, 2x Pills',
              controller: dosageController,
            ),
            const SizedBox(height: AyurezeTheme.spaceLg),
            OslerInput(
              label: 'Take with meal?',
              hint: 'e.g. After Eating',
              controller: timingController,
            ),
            const SizedBox(height: AyurezeTheme.space2xl),
            OslerButton(
              text: 'Add Medication',
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                widget.controller.addManualMedication(
                  name: nameController.text.trim(),
                  dosage: dosageController.text.trim(),
                  timing: timingController.text.trim(),
                );
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final MedicationController controller;

  const _AdherenceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final adherence = controller.adherence;
    return OslerCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AyurezeTheme.healingGreen10,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              adherence != null ? '$adherence%' : '--',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AyurezeTheme.healingGreen100,
                  ),
            ),
          ),
          const SizedBox(width: AyurezeTheme.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adherence',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  adherence == null
                      ? 'Log a dose to see your adherence.'
                      : '${controller.logs.length} doses logged.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AyurezeTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final Medication medication;
  final ValueChanged<DoseStatus> onLogDose;

  const _MedicationTile({required this.medication, required this.onLogDose});

  @override
  Widget build(BuildContext context) {
    return OslerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      [medication.dosage, medication.timing]
                          .where((s) => s.isNotEmpty)
                          .join(' - '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AyurezeTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              OslerTag(
                label: medication.isPrescribed
                    ? 'Prescribed by ${medication.prescribingDoctorName}'
                    : 'Self-added',
                style: medication.isPrescribed
                    ? OslerTagStyle.info
                    : OslerTagStyle.secondary,
              ),
            ],
          ),
          const SizedBox(height: AyurezeTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onLogDose(DoseStatus.skipped),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AyurezeTheme.remoteRed50,
                    side: BorderSide(color: AyurezeTheme.remoteRed50),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AyurezeTheme.radiusPill),
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: AyurezeTheme.spaceSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onLogDose(DoseStatus.taken),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyurezeTheme.healingGreenFill,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AyurezeTheme.radiusPill),
                    ),
                  ),
                  child: const Text('Take'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMedications extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyMedications({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return OslerStateView(
      icon: HugeIcons.strokeRoundedMedicine01,
      title: 'No Medications!',
      message:
          'You have 0 medications. Kindly setup a new one manually or scan with AI.',
      actionLabel: 'Add Medication',
      onAction: onAdd,
    );
  }
}
