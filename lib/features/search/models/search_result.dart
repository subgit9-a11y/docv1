enum SearchResultCategory { resources, medication, doctor, consultation }

/// One row in the global search screen's result list. Match percentage is
/// pre-computed by whatever produced the result set (an AI ranking service,
/// a local index, etc.) - this model only carries it for display.
///
/// [routeName] is the named route to open on tap, when this result points
/// at a real in-app destination (as the default index does); it is null for
/// results built without one, such as in tests.
class SearchResult {
  final String title;
  final String subtitle;
  final SearchResultCategory category;
  final int matchPercent;
  final String? routeName;

  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.matchPercent,
    this.routeName,
  });
}
