import 'package:doctro/models/astra/prescription_model.dart';

/// Where a tracked medication came from - the answer to how patient-tracked
/// meds relate to doctor-issued prescriptions: a [Medication] is either
/// derived from a doctor's [AstraPrescription] (read-only in the UI, always
/// traceable back to the prescribing doctor and prescription) or entered by
/// the patient themselves (manually or via the kit's "Scan with AI" flow),
/// which is freely editable. The two never merge into one writable record.
enum MedicationSource { prescribed, manual }

class Medication {
  final String id;
  final String name;
  final String dosage;

  /// e.g. "After Eating", "Before Eating", "Anytime".
  final String timing;
  final MedicationSource source;

  /// Set only when [source] is [MedicationSource.prescribed].
  final String? prescribingDoctorName;
  final String? prescriptionId;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
    required this.source,
    this.prescribingDoctorName,
    this.prescriptionId,
  });

  bool get isPrescribed => source == MedicationSource.prescribed;

  /// Maps a doctor-issued [MedicineItem] onto the patient's medication list.
  /// This is the one seam between the two domains: prescriptions stay owned
  /// by [AstraPrescription], and this factory is the only place a
  /// prescribed drug becomes a trackable [Medication].
  factory Medication.fromPrescriptionItem(
    MedicineItem item, {
    required String prescriptionId,
    required String doctorName,
    required int index,
  }) {
    return Medication(
      id: '$prescriptionId-$index',
      name: item.medicineName ?? 'Unnamed medication',
      dosage: [
        if (item.dose != null) item.dose!,
        if (item.scheduleDisplay.isNotEmpty) item.scheduleDisplay,
      ].join(' - '),
      timing: item.timing ?? 'Anytime',
      source: MedicationSource.prescribed,
      prescribingDoctorName: doctorName,
      prescriptionId: prescriptionId,
    );
  }
}
