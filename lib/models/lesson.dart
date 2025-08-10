class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.isPaid,
  });

  final String id;
  final String title;
  final String description;
  final String level; // 'A1'...'B2'
  final bool isPaid;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        level: json['level'] as String,
        isPaid: json['isPaid'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'level': level,
        'isPaid': isPaid,
      };
}