import 'package:doctro/features/search/models/search_result.dart';

/// Pure filter/sort used by [SearchScreen] - kept out of the widget so it
/// can be unit-tested without pumping a tree. Matches the kit's behavior:
/// case-insensitive substring match against title and subtitle, an optional
/// category filter, and results ranked by [SearchResult.matchPercent]
/// (highest first).
List<SearchResult> filterSearchResults(
  List<SearchResult> results, {
  required String query,
  SearchResultCategory? category,
}) {
  final trimmed = query.trim().toLowerCase();

  final filtered = results.where((result) {
    if (category != null && result.category != category) return false;
    if (trimmed.isEmpty) return true;
    return result.title.toLowerCase().contains(trimmed) ||
        result.subtitle.toLowerCase().contains(trimmed);
  }).toList();

  filtered.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
  return filtered;
}
