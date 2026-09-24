import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/search/models/search_result.dart';
import 'package:doctro/features/search/search_filter.dart';

void main() {
  const results = [
    SearchResult(
      title: 'AI Symptom Checker',
      subtitle: 'Analyze your symptoms',
      category: SearchResultCategory.resources,
      matchPercent: 99,
    ),
    SearchResult(
      title: 'Find a Doctor',
      subtitle: 'Browse doctors by specialization',
      category: SearchResultCategory.doctor,
      matchPercent: 54,
    ),
    SearchResult(
      title: 'Medication Reminders',
      subtitle: 'Manage dosage schedules',
      category: SearchResultCategory.medication,
      matchPercent: 68,
    ),
  ];

  group('filterSearchResults', () {
    test('returns everything, ranked by match percent, for an empty query', () {
      final filtered = filterSearchResults(results, query: '');

      expect(filtered.map((r) => r.title),
          ['AI Symptom Checker', 'Medication Reminders', 'Find a Doctor']);
    });

    test('matches case-insensitively against title or subtitle', () {
      final byTitle = filterSearchResults(results, query: 'symptom');
      expect(byTitle, hasLength(1));
      expect(byTitle.single.title, 'AI Symptom Checker');

      final bySubtitle = filterSearchResults(results, query: 'SPECIALIZATION');
      expect(bySubtitle, hasLength(1));
      expect(bySubtitle.single.title, 'Find a Doctor');
    });

    test('applies the category filter in addition to the query', () {
      final filtered = filterSearchResults(
        results,
        query: '',
        category: SearchResultCategory.doctor,
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.title, 'Find a Doctor');
    });

    test('returns an empty list when nothing matches', () {
      final filtered = filterSearchResults(results, query: 'zzz-no-match');
      expect(filtered, isEmpty);
    });
  });
}
