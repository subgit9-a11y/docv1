enum SearchResultCategory { resources, medication, doctor, consultation }

/// One row in the global search screen's result list. Match percentage is
/// pre-computed by whatever produced the result set (an AI ranking service,
/// a local index, etc.) - this model only carries it for display.
class SearchResult {
  final String title;
  final String subtitle;
  final SearchResultCategory category;
  final int matchPercent;

  const SearchResult({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.matchPercent,
  });
}
