class FeedPost {
  FeedPost({
    required this.id,
    required this.author,
    required this.content,
    required this.timestampIso,
    this.isTeacher = false,
    this.likes = 0,
  });

  final String id;
  final String author; // e.g., "Teacher" or username
  final String content;
  final String timestampIso;
  final bool isTeacher;
  final int likes;

  FeedPost copyWith({
    int? likes,
  }) => FeedPost(
        id: id,
        author: author,
        content: content,
        timestampIso: timestampIso,
        isTeacher: isTeacher,
        likes: likes ?? this.likes,
      );

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
        id: json['id'] as String,
        author: json['author'] as String,
        content: json['content'] as String,
        timestampIso: json['timestampIso'] as String,
        isTeacher: json['isTeacher'] as bool? ?? false,
        likes: json['likes'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'content': content,
        'timestampIso': timestampIso,
        'isTeacher': isTeacher,
        'likes': likes,
      };
}