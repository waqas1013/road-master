import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/taxi_lagstiftning_practice_sets.dart';

const _keyPrefix = 'lagar_practice_v1_';

class LagarSetProgress {
  const LagarSetProgress({
    required this.practiceSet,
    required this.nextQuestionIndex,
    required this.completed,
    required this.answers,
    this.bookmarks = const {},
    this.visitedThrough = 1,
  });

  final int practiceSet;
  final int nextQuestionIndex;
  final bool completed;
  final Map<String, int> answers;
  final Set<String> bookmarks;
  final int visitedThrough;

  int get totalAnswered => answers.length;

  int correctCount(Map<String, int> correctById) {
    var n = 0;
    for (final e in answers.entries) {
      final c = correctById[e.key];
      if (c != null && c == e.value) n++;
    }
    return n;
  }

  Map<String, dynamic> toJson() => {
        'nextQ': nextQuestionIndex,
        'completed': completed,
        'answers': answers.map((k, v) => MapEntry(k, v)),
        'bookmarks': bookmarks.toList(),
        'visitedThrough': visitedThrough,
      };

  static LagarSetProgress? fromJson(int practiceSet, String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final answersRaw = m['answers'];
      final answers = <String, int>{};
      if (answersRaw is Map<String, dynamic>) {
        for (final e in answersRaw.entries) {
          final v = e.value;
          if (v is int) {
            answers[e.key] = v;
          } else if (v is num) {
            answers[e.key] = v.toInt();
          }
        }
      }
      final bookmarks = <String>{};
      final bm = m['bookmarks'];
      if (bm is List<dynamic>) {
        for (final e in bm) {
          if (e is String && e.isNotEmpty) bookmarks.add(e);
        }
      }
      final nextQ = (m['nextQ'] as num?)?.toInt() ?? 1;
      final vtRaw = m['visitedThrough'];
      final int visitedThrough;
      if (vtRaw is num) {
        visitedThrough = vtRaw.toInt();
      } else {
        var vt = nextQ;
        final partition = lagstiftningPracticeQuestions(practiceSet);
        for (final e in answers.entries) {
          final idx = partition.indexWhere((q) => q.id == e.key);
          if (idx >= 0 && idx + 1 > vt) vt = idx + 1;
        }
        for (final id in bookmarks) {
          final idx = partition.indexWhere((q) => q.id == id);
          if (idx >= 0 && idx + 1 > vt) vt = idx + 1;
        }
        visitedThrough = vt;
      }
      return LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: nextQ,
        completed: m['completed'] == true,
        answers: answers,
        bookmarks: bookmarks,
        visitedThrough: visitedThrough < 1 ? 1 : visitedThrough,
      );
    } catch (_) {
      return null;
    }
  }
}

class LagarPracticeRepository {
  LagarPracticeRepository._(this._prefs);

  static LagarPracticeRepository? _instance;

  static Future<void> init() async {
    _instance = LagarPracticeRepository._(await SharedPreferences.getInstance());
  }

  static LagarPracticeRepository get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('LagarPracticeRepository.init() must be called before runApp');
    }
    return i;
  }

  final SharedPreferences _prefs;

  final ValueNotifier<int> progressRevision = ValueNotifier(0);

  String _key(int practiceSet) => '$_keyPrefix$practiceSet';

  LagarSetProgress? load(int practiceSet) {
    final raw = _prefs.getString(_key(practiceSet));
    if (raw == null || raw.isEmpty) return null;
    return LagarSetProgress.fromJson(practiceSet, raw);
  }

  Future<void> _save(LagarSetProgress p) async {
    await _prefs.setString(_key(p.practiceSet), jsonEncode(p.toJson()));
    progressRevision.value++;
  }

  Future<void> startFresh(int practiceSet) async {
    await clear(practiceSet);
  }

  Future<void> clear(int practiceSet) async {
    await _prefs.remove(_key(practiceSet));
    progressRevision.value++;
  }

  Future<void> toggleBookmark({
    required int practiceSet,
    required String questionId,
  }) async {
    final prev = load(practiceSet);
    if (prev == null) {
      await _save(LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: 1,
        completed: false,
        answers: {},
        bookmarks: {questionId},
        visitedThrough: 1,
      ));
      return;
    }
    final bookmarks = Set<String>.from(prev.bookmarks);
    if (bookmarks.contains(questionId)) {
      bookmarks.remove(questionId);
    } else {
      bookmarks.add(questionId);
    }
    await _save(LagarSetProgress(
      practiceSet: practiceSet,
      nextQuestionIndex: prev.nextQuestionIndex,
      completed: prev.completed,
      answers: Map<String, int>.from(prev.answers),
      bookmarks: bookmarks,
      visitedThrough: prev.visitedThrough,
    ));
  }

  bool isBookmarked(int practiceSet, String questionId) {
    final p = load(practiceSet);
    return p?.bookmarks.contains(questionId) ?? false;
  }

  Future<void> setResumeQuestion(int practiceSet, int questionOneBased) async {
    final prev = load(practiceSet);
    final answers = Map<String, int>.from(prev?.answers ?? {});
    final bookmarks = Set<String>.from(prev?.bookmarks ?? {});
    final visited = _maxVisited1(
      prev?.visitedThrough ?? 1,
      questionOneBased,
      prev?.nextQuestionIndex ?? questionOneBased,
    );
    await _save(LagarSetProgress(
      practiceSet: practiceSet,
      nextQuestionIndex: questionOneBased,
      completed: false,
      answers: answers,
      bookmarks: bookmarks,
      visitedThrough: visited,
    ));
  }

  Future<void> recordAnswer({
    required int practiceSet,
    required String questionId,
    required int selectedIndex,
    required int currentQuestionIndex,
  }) async {
    final prev = load(practiceSet);
    final answers = Map<String, int>.from(prev?.answers ?? {});
    answers[questionId] = selectedIndex;
    final visited = _maxVisited1(
      prev?.visitedThrough ?? 1,
      currentQuestionIndex,
      prev?.nextQuestionIndex ?? currentQuestionIndex,
    );
    await _save(LagarSetProgress(
      practiceSet: practiceSet,
      nextQuestionIndex: prev?.nextQuestionIndex ?? currentQuestionIndex,
      completed: prev?.completed ?? false,
      answers: answers,
      bookmarks: Set<String>.from(prev?.bookmarks ?? {}),
      visitedThrough: visited,
    ));
  }

  Future<void> advanceAfterNext({
    required int practiceSet,
    required int nextQuestionOneBased,
    required int totalInSet,
  }) async {
    final prev = load(practiceSet);
    final answers = Map<String, int>.from(prev?.answers ?? {});
    final bookmarks = Set<String>.from(prev?.bookmarks ?? {});
    if (nextQuestionOneBased > totalInSet) {
      final visited = _maxVisited1(
        prev?.visitedThrough ?? 1,
        totalInSet,
        prev?.nextQuestionIndex ?? totalInSet,
      );
      await _save(LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: totalInSet,
        completed: true,
        answers: answers,
        bookmarks: bookmarks,
        visitedThrough: visited,
      ));
    } else {
      final visited = _maxVisited1(
        prev?.visitedThrough ?? 1,
        nextQuestionOneBased,
        prev?.nextQuestionIndex ?? nextQuestionOneBased,
      );
      await _save(LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: nextQuestionOneBased,
        completed: false,
        answers: answers,
        bookmarks: bookmarks,
        visitedThrough: visited,
      ));
    }
  }
}

int _maxVisited1(int a, int b, int c) {
  var m = a;
  if (b > m) m = b;
  if (c > m) m = c;
  return m < 1 ? 1 : m;
}
