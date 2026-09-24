enum DoseStatus { taken, skipped, rescheduled }

class MedicationDoseLog {
  final String medicationId;
  final DateTime date;
  final DoseStatus status;

  const MedicationDoseLog({
    required this.medicationId,
    required this.date,
    required this.status,
  });
}

/// Percentage of logged doses that were taken, rounded to the nearest whole
/// number. Returns null when there is nothing to compute from yet, rather
/// than a misleading 0%.
int? adherencePercent(List<MedicationDoseLog> logs) {
  if (logs.isEmpty) return null;
  final taken = logs.where((log) => log.status == DoseStatus.taken).length;
  return ((taken / logs.length) * 100).round();
}
