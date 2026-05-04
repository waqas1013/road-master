import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  LagarPracticeRepository._() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  static LagarPracticeRepository? _instance;

  static Future<void> init() async {
    _instance = LagarPracticeRepository._();
    await _instance!._onAuthChanged(FirebaseAuth.instance.currentUser);
  }

  static LagarPracticeRepository get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'LagarPracticeRepository.init() must be called before runApp',
      );
    }
    return i;
  }

  final Map<int, LagarSetProgress> _cache = {};

  final ValueNotifier<int> progressRevision = ValueNotifier(0);

  LagarSetProgress? load(int practiceSet) => _cache[practiceSet];

  Future<void> _save(LagarSetProgress p) async {
    _cache[p.practiceSet] = p;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _doc(uid, p.practiceSet).set(p.toJson());
    }
    progressRevision.value++;
  }

  Future<void> startFresh(int practiceSet) async {
    await clear(practiceSet);
  }

  Future<void> clear(int practiceSet) async {
    _cache.remove(practiceSet);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _doc(uid, practiceSet).delete();
    }
    progressRevision.value++;
  }

  Future<void> toggleBookmark({
    required int practiceSet,
    required String questionId,
  }) async {
    final prev = load(practiceSet);
    if (prev == null) {
      await _save(
        LagarSetProgress(
          practiceSet: practiceSet,
          nextQuestionIndex: 1,
          completed: false,
          answers: {},
          bookmarks: {questionId},
          visitedThrough: 1,
        ),
      );
      return;
    }
    final bookmarks = Set<String>.from(prev.bookmarks);
    if (bookmarks.contains(questionId)) {
      bookmarks.remove(questionId);
    } else {
      bookmarks.add(questionId);
    }
    await _save(
      LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: prev.nextQuestionIndex,
        completed: prev.completed,
        answers: Map<String, int>.from(prev.answers),
        bookmarks: bookmarks,
        visitedThrough: prev.visitedThrough,
      ),
    );
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
    await _save(
      LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: questionOneBased,
        completed: false,
        answers: answers,
        bookmarks: bookmarks,
        visitedThrough: visited,
      ),
    );
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
    await _save(
      LagarSetProgress(
        practiceSet: practiceSet,
        nextQuestionIndex: prev?.nextQuestionIndex ?? currentQuestionIndex,
        completed: prev?.completed ?? false,
        answers: answers,
        bookmarks: Set<String>.from(prev?.bookmarks ?? {}),
        visitedThrough: visited,
      ),
    );
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
      await _save(
        LagarSetProgress(
          practiceSet: practiceSet,
          nextQuestionIndex: totalInSet,
          completed: true,
          answers: answers,
          bookmarks: bookmarks,
          visitedThrough: visited,
        ),
      );
    } else {
      final visited = _maxVisited1(
        prev?.visitedThrough ?? 1,
        nextQuestionOneBased,
        prev?.nextQuestionIndex ?? nextQuestionOneBased,
      );
      await _save(
        LagarSetProgress(
          practiceSet: practiceSet,
          nextQuestionIndex: nextQuestionOneBased,
          completed: false,
          answers: answers,
          bookmarks: bookmarks,
          visitedThrough: visited,
        ),
      );
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    _cache.clear();
    if (user != null) {
      final snap = await _collection(user.uid).get();
      for (final d in snap.docs) {
        final set = _setFromDocId(d.id);
        if (set == null) continue;
        final parsed = LagarSetProgress.fromJson(set, jsonEncode(d.data()));
        if (parsed != null) _cache[set] = parsed;
      }
    }
    progressRevision.value++;
  }

  static CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('taxi_lagar_progress');

  static DocumentReference<Map<String, dynamic>> _doc(
    String uid,
    int practiceSet,
  ) => _collection(uid).doc('set_$practiceSet');

  static int? _setFromDocId(String id) {
    if (!id.startsWith('set_')) return null;
    return int.tryParse(id.substring(4));
  }

  /// Removes old local-only progress from previous app versions.
  static Future<void> clearLocalCacheForPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

int _maxVisited1(int a, int b, int c) {
  var m = a;
  if (b > m) m = b;
  if (c > m) m = c;
  return m < 1 ? 1 : m;
}
