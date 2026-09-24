import 'package:flutter/foundation.dart';
import 'package:doctro/features/medications/models/medication.dart';
import 'package:doctro/features/medications/models/medication_dose_log.dart';
import 'package:doctro/models/astra/prescription_model.dart';

/// Owns the patient's combined medication list (prescribed + manually
/// added) and their dose logs. Prescribed medications are seeded from
/// [AstraPrescription]s via [Medication.fromPrescriptionItem] and can't be
/// edited or removed here - only the prescribing doctor can change those;
/// this controller only tracks whether each dose was taken.
class MedicationController extends ChangeNotifier {
  final List<Medication> _medications;
  final List<MedicationDoseLog> _logs = [];

  MedicationController({List<AstraPrescription> prescriptions = const []})
      : _medications = _fromPrescriptions(prescriptions);

  static List<Medication> _fromPrescriptions(
      List<AstraPrescription> prescriptions) {
    final result = <Medication>[];
    for (final prescription in prescriptions) {
      final medicines = prescription.medicines;
      if (medicines == null) continue;
      for (var i = 0; i < medicines.length; i++) {
        result.add(Medication.fromPrescriptionItem(
          medicines[i],
          prescriptionId: prescription.prescriptionId ?? prescription.id ?? '',
          doctorName: 'Dr. ${prescription.doctorId ?? 'Unknown'}',
          index: i,
        ));
      }
    }
    return result;
  }

  List<Medication> get medications => List.unmodifiable(_medications);
  List<MedicationDoseLog> get logs => List.unmodifiable(_logs);
  int? get adherence => adherencePercent(_logs);

  List<MedicationDoseLog> logsFor(String medicationId) =>
      _logs.where((log) => log.medicationId == medicationId).toList();

  void addManualMedication({
    required String name,
    required String dosage,
    required String timing,
  }) {
    _medications.add(Medication(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      dosage: dosage,
      timing: timing,
      source: MedicationSource.manual,
    ));
    notifyListeners();
  }

  void removeManualMedication(String id) {
    _medications.removeWhere(
        (med) => med.id == id && med.source == MedicationSource.manual);
    notifyListeners();
  }

  void logDose(String medicationId, DoseStatus status, {DateTime? date}) {
    _logs.add(MedicationDoseLog(
      medicationId: medicationId,
      date: date ?? DateTime.now(),
      status: status,
    ));
    notifyListeners();
  }
}
