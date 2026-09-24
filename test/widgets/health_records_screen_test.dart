import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/health_records/health_records_screen.dart';
import 'package:doctro/features/health_records/models/appointment_summary.dart';
import 'package:doctro/features/health_records/models/health_document.dart';
import 'package:doctro/features/health_records/models/medical_history_entry.dart';
import 'package:doctro/features/health_records/repository/health_records_repository.dart';
import 'package:doctro/features/medications/models/medication.dart';

void main() {
  testWidgets('loads each tab from the repository and switches between them',
      (WidgetTester tester) async {
    final repository = InMemoryHealthRecordsRepository(
      medications: const [
        Medication(
          id: 'm1',
          name: 'Amoxiciline',
          dosage: '500mg',
          timing: 'After Eating',
          source: MedicationSource.prescribed,
          prescribingDoctorName: 'Dr. Gray',
        ),
      ],
      medicalHistory: const [
        MedicalHistoryEntry(
          id: 'h1',
          bodySystem: BodySystem.heart,
          title: 'Pulmonary Function Test',
          summary: 'Excellent Health',
        ),
      ],
      appointments: [
        AppointmentSummary(
          id: 'a1',
          doctorName: 'Dr. Phos Gray',
          type: 'General Medical Checkup',
          dateTime: DateTime(2026, 1, 3, 15, 30),
        ),
      ],
      documents: const [
        HealthDocument(
          id: 'd1',
          title: 'X-Ray Scans',
          category: 'Diagnostics',
          sizeLabel: '24mb',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: HealthRecordsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amoxiciline'), findsOneWidget);

    await tester.tap(find.text('Medical History'));
    await tester.pumpAndSettle();
    expect(find.text('Pulmonary Function Test'), findsOneWidget);

    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. Phos Gray'), findsOneWidget);

    await tester.tap(find.text('Documents'));
    await tester.pumpAndSettle();
    expect(find.text('X-Ray Scans'), findsOneWidget);
  });

  testWidgets('shows an empty state per tab when the repository is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HealthRecordsScreen(
          repository: InMemoryHealthRecordsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No current medications on record.'), findsOneWidget);
  });
}
