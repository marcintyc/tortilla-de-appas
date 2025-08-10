import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_post.dart';
import '../models/feed_comment.dart';

enum CefrLevel { a1, a2, b1, b2 }

enum UserRole { student, teacher }

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

  // Auth
  String? _userName;
  UserRole _userRole = UserRole.student;

  // PRO community feed state
  final List<FeedPost> _userFeedPosts = [];
  final Set<String> _likedPostIds = {};
  final Map<String, List<FeedComment>> _userCommentsByPostId = {};

  CefrLevel? get selectedLevel => _selectedLevel;
  bool get isSubscribed => _isSubscribed;
  Map<String, LessonProgress> get progress => _progressByLessonId;

  String? get userName => _userName;
  UserRole get userRole => _userRole;
  bool get isLoggedIn => _userName != null && _userName!.trim().isNotEmpty;

  List<FeedPost> get userFeedPosts => List.unmodifiable(_userFeedPosts);
  Set<String> get likedPostIds => Set.unmodifiable(_likedPostIds);
  List<FeedComment> commentsFor(String postId) =>
      List.unmodifiable(_userCommentsByPostId[postId] ?? const []);

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
      final liked = (map['likedPostIds'] as List?)?.cast<String>() ?? [];
      _likedPostIds.addAll(liked);
      final userPosts = (map['userFeedPosts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final up in userPosts) {
        _userFeedPosts.add(FeedPost.fromJson(up));
      }
      final commentsMap = (map['userCommentsByPostId'] as Map?)?.cast<String, dynamic>() ?? {};
      commentsMap.forEach((postId, list) {
        final items = (list as List).cast<Map<String, dynamic>>();
        _userCommentsByPostId[postId] = items.map(FeedComment.fromJson).toList();
      });
      final savedName = map['userName'] as String?;
      final savedRole = map['userRole'] as String?;
      _userName = savedName;
      _userRole = switch (savedRole) {
        'teacher' => UserRole.teacher,
        _ => UserRole.student,
      };
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
      'likedPostIds': _likedPostIds.toList(),
      'userFeedPosts': _userFeedPosts.map((e) => e.toJson()).toList(),
      'userCommentsByPostId': _userCommentsByPostId.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
      'userName': _userName,
      'userRole': _userRole == UserRole.teacher ? 'teacher' : 'student',
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

  void signIn({required String name, required UserRole role}) {
    _userName = name.trim();
    _userRole = role;
    _persist();
    notifyListeners();
  }

  void signOut() {
    _userName = null;
    _userRole = UserRole.student;
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

  // Feed actions
  void toggleLike(String postId) {
    if (_likedPostIds.contains(postId)) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }
    _persist();
    notifyListeners();
  }

  void addUserPost(String content) {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'user-${now.hashCode}';
    _userFeedPosts.insert(
      0,
      FeedPost(
        id: id,
        author: isLoggedIn ? (_userName ?? 'You') : 'You',
        content: content,
        timestampIso: now,
        isTeacher: _userRole == UserRole.teacher,
        likes: 0,
      ),
    );
    _persist();
    notifyListeners();
  }

  void addComment({required String postId, required String content}) {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = 'c-${now.hashCode}';
    final list = _userCommentsByPostId.putIfAbsent(postId, () => []);
    list.add(FeedComment(
      id: id,
      author: isLoggedIn ? (_userName ?? 'You') : 'You',
      content: content,
      timestampIso: now,
      isTeacher: _userRole == UserRole.teacher,
    ));
    _persist();
    notifyListeners();
  }
}