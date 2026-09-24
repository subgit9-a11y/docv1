/// A workshop listing from the Resources tab. Deliberately display-only:
/// booking a paid seat implies real payment-processing (same open question
/// as the kit's E-Pharmacy checkout), so this model and the screens built
/// on it stop at "browse and view details" rather than inventing a
/// checkout flow unreviewed.
class Workshop {
  final String id;
  final String title;
  final String hostName;
  final DateTime dateTime;
  final String overview;
  final List<String> agenda;
  final double entryPrice;

  const Workshop({
    required this.id,
    required this.title,
    required this.hostName,
    required this.dateTime,
    required this.overview,
    this.agenda = const [],
    required this.entryPrice,
  });
}
