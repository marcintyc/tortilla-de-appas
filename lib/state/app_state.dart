import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CefrLevel { a1, a2, b1, b2 }

extension CefrLevelX on CefrLevel {
  String get label => switch (this) {
        CefrLevel.a1 => 'A1',
        CefrLevel.a2 => 'A2',
        CefrLevel.b1 => 'B1',
        CefrLevel.b2 => 'B2',
      };
}

class LessonProgress {
  LessonProgress({required this.lessonId, required this.completed});
  final String lessonId;
  final bool completed;

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'completed': completed,
      };

  static LessonProgress fromJson(Map<String, dynamic> json) =>
      LessonProgress(lessonId: json['lessonId'], completed: json['completed']);
}

class AppState extends ChangeNotifier {
  static const _prefsKey = 'habla_app_state_v1';

  CefrLevel? _selectedLevel;
  bool _isSubscribed = false;
  final Map<String, LessonProgress> _progressByLessonId = {};

  CefrLevel? get selectedLevel => _selectedLevel;
  bool get isSubscribed => _isSubscribed;
  Map<String, LessonProgress> get progress => _progressByLessonId;

  Future<void> restoreFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final level = map['selectedLevel'] as String?;
      _selectedLevel = switch (level) {
        'A1' => CefrLevel.a1,
        'A2' => CefrLevel.a2,
        'B1' => CefrLevel.b1,
        'B2' => CefrLevel.b2,
        _ => null,
      };
      _isSubscribed = map['isSubscribed'] == true;
      final prog = (map['progress'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final p in prog) {
        final lp = LessonProgress.fromJson(p);
        _progressByLessonId[lp.lessonId] = lp;
      }
    } catch (_) {
      // ignore malformed state
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'selectedLevel': _selectedLevel?.label,
      'isSubscribed': _isSubscribed,
      'progress': _progressByLessonId.values.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  void setLevel(CefrLevel level) {
    _selectedLevel = level;
    _persist();
    notifyListeners();
  }

  void toggleSubscription([bool? value]) {
    _isSubscribed = value ?? !_isSubscribed;
    _persist();
    notifyListeners();
  }

  void markLessonCompleted(String lessonId, bool completed) {
    _progressByLessonId[lessonId] = LessonProgress(
      lessonId: lessonId,
      completed: completed,
    );
    _persist();
    notifyListeners();
  }

  void resetProgress() {
    _progressByLessonId.clear();
    _persist();
    notifyListeners();
  }
}