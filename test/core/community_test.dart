import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/features/community/community_controller.dart';
import 'package:doctro/features/community/community_filter.dart';
import 'package:doctro/features/community/models/community_post.dart';

void main() {
  final posts = [
    CommunityPost(
      id: 'p1',
      authorName: 'Bocchi The Rock',
      content: 'Older post',
      category: CommunityPostCategory.health,
      postedAt: DateTime(2026, 1, 1),
    ),
    CommunityPost(
      id: 'p2',
      authorName: 'Bocchi The Rock',
      content: 'Newer post',
      category: CommunityPostCategory.doctor,
      postedAt: DateTime(2026, 1, 5),
    ),
  ];

  group('filterCommunityPosts', () {
    test('sorts newest first with no category filter', () {
      final filtered = filterCommunityPosts(posts);
      expect(filtered.map((p) => p.id), ['p2', 'p1']);
    });

    test('filters by category', () {
      final filtered =
          filterCommunityPosts(posts, category: CommunityPostCategory.doctor);
      expect(filtered.map((p) => p.id), ['p2']);
    });
  });

  group('CommunityController', () {
    test('addPost inserts at the front of the feed', () {
      final controller = CommunityController(posts: posts);

      controller.addPost(
        authorName: 'You',
        content: 'Brand new post',
        category: CommunityPostCategory.health,
      );

      expect(controller.posts, hasLength(3));
      expect(controller.posts.first.content, 'Brand new post');
    });

    test('toggleLike increments then decrements likes', () {
      final controller = CommunityController(posts: posts);

      controller.toggleLike('p1');
      expect(controller.posts.firstWhere((p) => p.id == 'p1').likes, 1);
      expect(controller.isLiked('p1'), isTrue);

      controller.toggleLike('p1');
      expect(controller.posts.firstWhere((p) => p.id == 'p1').likes, 0);
      expect(controller.isLiked('p1'), isFalse);
    });
  });
}
