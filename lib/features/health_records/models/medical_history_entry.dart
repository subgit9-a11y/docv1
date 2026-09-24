enum BodySystem { heart, lung, gut, muscle }

class MedicalHistoryEntry {
  final String id;
  final BodySystem bodySystem;
  final String title;
  final String summary;

  /// True when this entry needs the patient's attention (e.g. "Possible
  /// Disease Detected!" in the kit), false for a clean result like
  /// "Excellent Health".
  final bool flagged;

  const MedicalHistoryEntry({
    required this.id,
    required this.bodySystem,
    required this.title,
    required this.summary,
    this.flagged = false,
  });
}
