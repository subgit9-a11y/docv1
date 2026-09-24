import 'package:doctro/features/community/models/community_post.dart';

/// Filters the community feed by category, newest first. Kept out of the
/// widget so it's unit-testable, same as filterSearchResults.
List<CommunityPost> filterCommunityPosts(
  List<CommunityPost> posts, {
  CommunityPostCategory? category,
}) {
  final filtered = category == null
      ? List<CommunityPost>.from(posts)
      : posts.where((post) => post.category == category).toList();

  filtered.sort((a, b) => b.postedAt.compareTo(a.postedAt));
  return filtered;
}
