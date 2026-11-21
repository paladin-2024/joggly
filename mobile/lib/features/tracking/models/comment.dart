class Comment {
  final String id;
  final String authorId;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String body;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.body,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorDisplayName: json['authorDisplayName'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] as String?,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
