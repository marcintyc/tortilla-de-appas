class FeedComment {
  FeedComment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestampIso,
    this.isTeacher = false,
  });

  final String id;
  final String author;
  final String content;
  final String timestampIso;
  final bool isTeacher;

  factory FeedComment.fromJson(Map<String, dynamic> json) => FeedComment(
        id: json['id'] as String,
        author: json['author'] as String,
        content: json['content'] as String,
        timestampIso: json['timestampIso'] as String,
        isTeacher: json['isTeacher'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'content': content,
        'timestampIso': timestampIso,
        'isTeacher': isTeacher,
      };
}