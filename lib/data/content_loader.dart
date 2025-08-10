import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/lesson.dart';
import '../models/news_item.dart';

class ContentLoader {
  static Future<List<Lesson>> loadLessons() async {
    final raw = await rootBundle.loadString('assets/content/lessons.json');
    final data = jsonDecode(raw) as List<dynamic>;
    return data.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<NewsItem>> loadNews() async {
    final raw = await rootBundle.loadString('assets/content/news.json');
    final data = jsonDecode(raw) as List<dynamic>;
    return data
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}