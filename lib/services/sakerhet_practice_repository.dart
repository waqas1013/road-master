import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/taxi_sakerhet_practice_sets.dart';

const _keyPrefix = 'sakerhet_practice_v2_';

/// Persisted progress for one Säkerhet **practice** card (Set 1–4).
class SakerhetSetProgress {
  const SakerhetSetProgress({
    required this.practiceSet,
    required this.nextQuestionIndex,
    required this.completed,
    required this.answers,
    this.bookmarks = const {},
    this.visitedThrough = 1,
  });

  final int practiceSet;
  /// Next question to show when user taps **Continue** (1-based within that practice set).
  final int nextQuestionIndex;
  final bool completed;
  /// Saved after **Kontrollera svar** — question `id` → selected option index.
  final Map<String, int> answers;
  /// Bookmarked (**Sparad**) question ids in this set — toggled from the question screen.
  final Set<String> bookmarks;
  /// Highest question index (1-based) the user has reached — unlocks the question grid up to here.
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

  static SakerhetSetProgress? fromJson(int practiceSet, String raw) {
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
        final partition = sakerhetPracticeQuestions(practiceSet);
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
      return SakerhetSetProgress(
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

class SakerhetPracticeRepository {
  SakerhetPracticeRepository._(this._prefs);

  static SakerhetPracticeRepository? _instance;

  static Future<void> init() async {
    _instance = SakerhetPracticeRepository._(await SharedPreferences.getInstance());
  }

  static SakerhetPracticeRepository get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('SakerhetPracticeRepository.init() must be called before runApp');
    }
    return i;
  }

  final SharedPreferences _prefs;

  /// Incremented after any stored progress changes — listen to refresh UI (e.g. Säkerhet set cards).
  final ValueNotifier<int> progressRevision = ValueNotifier(0);

  String _key(int practiceSet) => '$_keyPrefix$practiceSet';

  SakerhetSetProgress? load(int practiceSet) {
    final raw = _prefs.getString(_key(practiceSet));
    if (raw == null || raw.isEmpty) return null;
    return SakerhetSetProgress.fromJson(practiceSet, raw);
  }

  Future<void> _save(SakerhetSetProgress p) async {
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

  /// Toggle **Sparad** for one question in a practice set (persists with set progress).
  Future<void> toggleBookmark({
    required int practiceSet,
    required String questionId,
  }) async {
    final prev = load(practiceSet);
    if (prev == null) {
      await _save(SakerhetSetProgress(
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
    await _save(SakerhetSetProgress(
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

  /// Opening a question: persist where the user is (resume point).
  Future<void> setResumeQuestion(int practiceSet, int questionOneBased) async {
    final prev = load(practiceSet);
    final answers = Map<String, int>.from(prev?.answers ?? {});
    final bookmarks = Set<String>.from(prev?.bookmarks ?? {});
    final visited = _maxVisited1(
      prev?.visitedThrough ?? 1,
      questionOneBased,
      prev?.nextQuestionIndex ?? questionOneBased,
    );
    await _save(SakerhetSetProgress(
      practiceSet: practiceSet,
      nextQuestionIndex: questionOneBased,
      completed: false,
      answers: answers,
      bookmarks: bookmarks,
      visitedThrough: visited,
    ));
  }

  /// After **Kontrollera svar**.
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
    await _save(SakerhetSetProgress(
      practiceSet: practiceSet,
      nextQuestionIndex: prev?.nextQuestionIndex ?? currentQuestionIndex,
      completed: prev?.completed ?? false,
      answers: answers,
      bookmarks: Set<String>.from(prev?.bookmarks ?? {}),
      visitedThrough: visited,
    ));
  }

  /// After **Nästa**: move resume pointer; mark completed on last.
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
      await _save(SakerhetSetProgress(
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
      await _save(SakerhetSetProgress(
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
