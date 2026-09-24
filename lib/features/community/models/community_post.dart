enum CommunityPostCategory { disease, health, doctor, workshop }

class CommunityPost {
  final String id;
  final String authorName;
  final String content;
  final CommunityPostCategory category;
  final int likes;
  final int comments;
  final DateTime postedAt;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.content,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    required this.postedAt,
  });

  CommunityPost copyWith({int? likes}) => CommunityPost(
        id: id,
        authorName: authorName,
        content: content,
        category: category,
        likes: likes ?? this.likes,
        comments: comments,
        postedAt: postedAt,
      );
}
