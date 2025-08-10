class NewsItem {
  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.videoUrl,
    required this.publishedAt,
    this.isPaid = false,
  });

  final String id;
  final String title;
  final String summary;
  final String videoUrl; // could be YouTube or mp4 link
  final String publishedAt;
  final bool isPaid;

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        videoUrl: json['videoUrl'] as String,
        publishedAt: json['publishedAt'] as String,
        isPaid: json['isPaid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'videoUrl': videoUrl,
        'publishedAt': publishedAt,
        'isPaid': isPaid,
      };
}