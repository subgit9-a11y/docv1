import 'package:flutter/foundation.dart';
import 'package:doctro/features/community/models/community_post.dart';
import 'package:doctro/features/community/models/workshop.dart';

class CommunityController extends ChangeNotifier {
  final List<CommunityPost> _posts;
  final List<Workshop> _workshops;
  final Set<String> _likedPostIds = {};

  CommunityController({
    List<CommunityPost> posts = const [],
    List<Workshop> workshops = const [],
  })  : _posts = List.of(posts),
        _workshops = List.of(workshops);

  List<CommunityPost> get posts => List.unmodifiable(_posts);
  List<Workshop> get workshops => List.unmodifiable(_workshops);

  bool isLiked(String postId) => _likedPostIds.contains(postId);

  void toggleLike(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    if (_likedPostIds.contains(postId)) {
      _likedPostIds.remove(postId);
      _posts[index] = post.copyWith(likes: post.likes - 1);
    } else {
      _likedPostIds.add(postId);
      _posts[index] = post.copyWith(likes: post.likes + 1);
    }
    notifyListeners();
  }

  void addPost({
    required String authorName,
    required String content,
    required CommunityPostCategory category,
  }) {
    _posts.insert(
      0,
      CommunityPost(
        id: 'post-${DateTime.now().microsecondsSinceEpoch}',
        authorName: authorName,
        content: content,
        category: category,
        postedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
