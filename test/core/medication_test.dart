import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/medications/medication_controller.dart';
import 'package:doctro/features/medications/models/medication.dart';
import 'package:doctro/features/medications/models/medication_dose_log.dart';
import 'package:doctro/models/astra/prescription_model.dart';

void main() {
  group('Medication.fromPrescriptionItem', () {
    test('carries the prescribing doctor and prescription id through', () {
      final medication = Medication.fromPrescriptionItem(
        MedicineItem(
          medicineName: 'Amoxiciline',
          dose: '500mg',
          schedule: '1-0-1',
          timing: 'After Eating',
        ),
        prescriptionId: 'rx-1',
        doctorName: 'Dr. Hannibal Lector',
        index: 0,
      );

      expect(medication.source, MedicationSource.prescribed);
      expect(medication.isPrescribed, isTrue);
      expect(medication.prescribingDoctorName, 'Dr. Hannibal Lector');
      expect(medication.prescriptionId, 'rx-1');
      expect(medication.name, 'Amoxiciline');
      expect(medication.dosage, '500mg - Morning, Night');
      expect(medication.timing, 'After Eating');
    });
  });

  group('adherencePercent', () {
    test('returns null with no logs', () {
      expect(adherencePercent([]), isNull);
    });

    test('computes the percentage of taken doses', () {
      final logs = [
        MedicationDoseLog(
            medicationId: 'm1',
            date: DateTime(2026, 1, 1),
            status: DoseStatus.taken),
        MedicationDoseLog(
            medicationId: 'm1',
            date: DateTime(2026, 1, 2),
            status: DoseStatus.taken),
        MedicationDoseLog(
            medicationId: 'm1',
            date: DateTime(2026, 1, 3),
            status: DoseStatus.skipped),
      ];

      expect(adherencePercent(logs), 67);
    });
  });

  group('MedicationController', () {
    test('seeds medications from prescriptions', () {
      final controller = MedicationController(prescriptions: [
        AstraPrescription(
          prescriptionId: 'rx-1',
          doctorId: 'doc-1',
          medicines: [
            MedicineItem(medicineName: 'Ibuprofen', dose: '200mg'),
          ],
        ),
      ]);

      expect(controller.medications, hasLength(1));
      expect(controller.medications.single.isPrescribed, isTrue);
    });

    test('falls back to a generic label without a doctorNameResolver', () {
      final controller = MedicationController(prescriptions: [
        AstraPrescription(
          prescriptionId: 'rx-1',
          doctorId: 'doc-1',
          medicines: [MedicineItem(medicineName: 'Ibuprofen')],
        ),
      ]);

      // AstraPrescription only carries a doctorId, not a name - it must
      // never fabricate one like 'Dr. doc-1' out of the raw id.
      expect(
          controller.medications.single.prescribingDoctorName, 'Your doctor');
    });

    test('uses doctorNameResolver when one is supplied', () {
      final controller = MedicationController(
        prescriptions: [
          AstraPrescription(
            prescriptionId: 'rx-1',
            doctorId: 'doc-1',
            medicines: [MedicineItem(medicineName: 'Ibuprofen')],
          ),
        ],
        doctorNameResolver: (id) => id == 'doc-1' ? 'Dr. Hannibal Lector' : id,
      );

      expect(controller.medications.single.prescribingDoctorName,
          'Dr. Hannibal Lector');
    });

    test('adds and removes manual medications without touching prescribed ones',
        () {
      final controller = MedicationController(prescriptions: [
        AstraPrescription(
          prescriptionId: 'rx-1',
          doctorId: 'doc-1',
          medicines: [MedicineItem(medicineName: 'Ibuprofen')],
        ),
      ]);

      controller.addManualMedication(
          name: 'Vitamin C', dosage: '1000mg', timing: 'Morning');
      expect(controller.medications, hasLength(2));

      final manual =
          controller.medications.firstWhere((m) => m.name == 'Vitamin C');
      controller.removeManualMedication(manual.id);

      expect(controller.medications, hasLength(1));
      expect(controller.medications.single.name, 'Ibuprofen');
    });

    test('logging a dose updates adherence', () {
      final controller = MedicationController();
      controller.addManualMedication(
          name: 'Vitamin C', dosage: '1000mg', timing: 'Morning');
      final id = controller.medications.single.id;

      controller.logDose(id, DoseStatus.taken);
      controller.logDose(id, DoseStatus.skipped);

      expect(controller.adherence, 50);
      expect(controller.logsFor(id), hasLength(2));
    });
  });
}
