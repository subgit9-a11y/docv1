import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/theme/app_motion.dart';
import 'package:doctro/widgets/osler_card.dart';
import 'package:doctro/widgets/osler_state_view.dart';
import 'package:doctro/widgets/osler_tag.dart';
import 'package:doctro/features/health_records/models/appointment_summary.dart';
import 'package:doctro/features/health_records/models/health_document.dart';
import 'package:doctro/features/health_records/models/medical_history_entry.dart';
import 'package:doctro/features/health_records/repository/health_records_repository.dart';
import 'package:doctro/features/medications/models/medication.dart';

class HealthRecordsScreen extends StatefulWidget {
  final HealthRecordsRepository repository;

  const HealthRecordsScreen({super.key, required this.repository});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  late Future<_HealthRecordsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HealthRecordsData> _load() async {
    final repo = widget.repository;
    final results = await Future.wait([
      repo.currentMedications(),
      repo.medicalHistory(),
      repo.appointments(),
      repo.documents(),
    ]);
    return _HealthRecordsData(
      medications: results[0] as List<Medication>,
      history: results[1] as List<MedicalHistoryEntry>,
      appointments: results[2] as List<AppointmentSummary>,
      documents: results[3] as List<HealthDocument>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AyurezeTheme.canvas,
        appBar: AppBar(
          backgroundColor: AyurezeTheme.canvas,
          elevation: 0,
          foregroundColor: AyurezeTheme.textPrimary,
          title: const Text('Health Record Overview'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AyurezeTheme.healingGreen100,
            unselectedLabelColor: AyurezeTheme.textSecondary,
            indicatorColor: AyurezeTheme.healingGreenFill,
            tabs: const [
              Tab(text: 'Medications'),
              Tab(text: 'Medical History'),
              Tab(text: 'Appointments'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: FutureBuilder<_HealthRecordsData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const OslerLoadingView();
            }
            final data = snapshot.data!;
            return TabBarView(
              children: [
                _MedicationsTab(medications: data.medications),
                _MedicalHistoryTab(entries: data.history),
                _AppointmentsTab(appointments: data.appointments),
                _DocumentsTab(documents: data.documents),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HealthRecordsData {
  final List<Medication> medications;
  final List<MedicalHistoryEntry> history;
  final List<AppointmentSummary> appointments;
  final List<HealthDocument> documents;

  const _HealthRecordsData({
    required this.medications,
    required this.history,
    required this.appointments,
    required this.documents,
  });
}

class _MedicationsTab extends StatelessWidget {
  final List<Medication> medications;

  const _MedicationsTab({required this.medications});

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      return const _EmptyTab(
          message: 'No current medications on record.',
          icon: HugeIcons.strokeRoundedMedicine01);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
      itemCount: medications.length,
      separatorBuilder: (_, __) => const SizedBox(height: AyurezeTheme.spaceSm),
      itemBuilder: (context, index) {
        final medication = medications[index];
        return ScreenEntrance(
          index: index,
          child: OslerCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AyurezeTheme.healingGreen10,
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedMedicine01,
                    color: AyurezeTheme.healingGreen100,
                  ),
                ),
                const SizedBox(width: AyurezeTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medication.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        medication.dosage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MedicalHistoryTab extends StatelessWidget {
  final List<MedicalHistoryEntry> entries;

  const _MedicalHistoryTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyTab(
          message: 'No medical history on record.',
          icon: HugeIcons.strokeRoundedStethoscope02);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AyurezeTheme.spaceSm),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ScreenEntrance(
          index: index,
          child: OslerCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.flagged
                        ? AyurezeTheme.remoteRed10
                        : AyurezeTheme.healingGreen10,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: _iconFor(entry.bodySystem),
                    color: entry.flagged
                        ? AyurezeTheme.remoteRed100
                        : AyurezeTheme.healingGreen100,
                  ),
                ),
                const SizedBox(width: AyurezeTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        entry.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (entry.flagged)
                  const OslerTag(label: 'Flagged', style: OslerTagStyle.danger),
              ],
            ),
          ),
        );
      },
    );
  }

  List<List<dynamic>> _iconFor(BodySystem system) {
    switch (system) {
      case BodySystem.heart:
        return HugeIcons.strokeRoundedFavourite;
      case BodySystem.lung:
        return HugeIcons.strokeRoundedLungs;
      case BodySystem.gut:
        return HugeIcons.strokeRoundedDigestion;
      case BodySystem.muscle:
        return HugeIcons.strokeRoundedDumbbell01;
    }
  }
}

class _AppointmentsTab extends StatelessWidget {
  final List<AppointmentSummary> appointments;

  const _AppointmentsTab({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const _EmptyTab(
          message: 'No appointments on record.',
          icon: HugeIcons.strokeRoundedCalendar01);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AyurezeTheme.spaceSm),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return ScreenEntrance(
          index: index,
          child: OslerCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AyurezeTheme.connectivityBlue10,
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: AyurezeTheme.connectivityBlue100,
                  ),
                ),
                const SizedBox(width: AyurezeTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        appointment.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${appointment.dateTime.month}/${appointment.dateTime.day}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  final List<HealthDocument> documents;

  const _DocumentsTab({required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const _EmptyTab(
          message: 'No health documents on record.',
          icon: HugeIcons.strokeRoundedFile01);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(AyurezeTheme.spaceXl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AyurezeTheme.spaceSm,
        crossAxisSpacing: AyurezeTheme.spaceSm,
        childAspectRatio: 1.3,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return ScreenEntrance(
          index: index,
          child: OslerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedFile01,
                  color: AyurezeTheme.healingGreen100,
                ),
                const Spacer(),
                Text(document.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${document.category} - ${document.sizeLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AyurezeTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String message;
  final List<List<dynamic>> icon;

  const _EmptyTab({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OslerStateView(
      icon: icon,
      title: 'Nothing Here Yet',
      message: message,
    );
  }
}
