import 'dart:math';

import '../data/taxi_lagstiftning_practice_sets.dart';
import '../data/taxi_question_bank.dart';
import '../data/taxi_sakerhet_questions.dart';
import '../models/taxi_practice_question.dart';

const int kMockExamDelprov1QuestionTarget = 70;
const int kMockExamDelprov2QuestionTarget = 50;
const int kMockExamPassThresholdDelprov1 = 48;
const int kMockExamPassThresholdDelprov2 = 34;
const int kMockExamDurationMinutes = 50;

/// Active slutprov (mock exam). One session at a time; cleared after viewing results.
class MockExamSession {
  MockExamSession._({
    required this.part,
    required this.questions,
    required this.startedAt,
    required this.endsAt,
    required this.passThreshold,
  });

  /// 1 = Säkerhet och beteende, 2 = Lagstiftning.
  final int part;
  final List<TaxiPracticeQuestion> questions;
  final DateTime startedAt;
  final DateTime endsAt;
  final int passThreshold;

  /// 0-based question index → selected option index.
  final Map<int, int> answers = {};

  bool timeExpired = false;
  bool abandonedByUser = false;

  /// Holds the session for [TaxiMockExamResultsScreen] so it survives route replacement timing.
  static MockExamSession? _current;
  static MockExamSession? _submitted;

  static MockExamSession? get current => _current;

  /// Session to display on results (set immediately before navigating to results).
  static MockExamSession? get submitted => _submitted ?? _current;

  static void prepareResults(MockExamSession session) {
    _submitted = session;
    _current = session;
  }

  static void clear() {
    _current = null;
    _submitted = null;
  }

  static List<TaxiPracticeQuestion> _modulePool(String moduleId) {
    final fromBank = TaxiQuestionBank.instance.questions.where((q) => q.moduleId == moduleId).toList();
    if (moduleId == kTaxiModuleSakerhet) {
      final seen = fromBank.map((q) => q.id).toSet();
      final merged = [...fromBank];
      for (final q in taxiSakerhetSet1) {
        if (!seen.contains(q.id)) {
          merged.add(q);
          seen.add(q.id);
        }
      }
      return merged;
    }
    return fromBank;
  }

  static int _passThreshold(int part, int n) {
    if (part == 1) {
      if (n >= kMockExamDelprov1QuestionTarget) return kMockExamPassThresholdDelprov1;
      return max(1, (kMockExamPassThresholdDelprov1 * n / kMockExamDelprov1QuestionTarget).ceil());
    }
    if (n >= kMockExamDelprov2QuestionTarget) return kMockExamPassThresholdDelprov2;
    return max(1, (kMockExamPassThresholdDelprov2 * n / kMockExamDelprov2QuestionTarget).ceil());
  }

  /// Builds a new session with a shuffled subset. Returns null if the bank is empty.
  static MockExamSession? start({required int part}) {
    if (part != 1 && part != 2) return null;
    _submitted = null;
    final module = part == 1 ? kTaxiModuleSakerhet : kTaxiModuleLagstiftning;
    final target = part == 1 ? kMockExamDelprov1QuestionTarget : kMockExamDelprov2QuestionTarget;
    final pool = _modulePool(module);
    if (pool.isEmpty) {
      _current = null;
      return null;
    }
    final rng = Random();
    final shuffled = List<TaxiPracticeQuestion>.from(pool)..shuffle(rng);
    final n = min(target, shuffled.length);
    final picked = shuffled.sublist(0, n);
    final renumbered = <TaxiPracticeQuestion>[
      for (var i = 0; i < picked.length; i++)
        picked[i].copyWith(
          questionNumber: i + 1,
          totalInSet: picked.length,
        ),
    ];
    final threshold = _passThreshold(part, n);
    final now = DateTime.now();
    _current = MockExamSession._(
      part: part,
      questions: renumbered,
      startedAt: now,
      endsAt: now.add(const Duration(minutes: kMockExamDurationMinutes)),
      passThreshold: threshold,
    );
    return _current;
  }

  int correctCount() {
    var c = 0;
    for (var i = 0; i < questions.length; i++) {
      final sel = answers[i];
      if (sel != null && sel == questions[i].correctOptionIndex) c++;
    }
    return c;
  }

  /// Answered but incorrect.
  int wrongAnsweredCount() {
    var n = 0;
    for (var i = 0; i < questions.length; i++) {
      final sel = answers[i];
      if (sel != null && sel != questions[i].correctOptionIndex) n++;
    }
    return n;
  }

  /// No option selected for this item.
  int skippedCount() {
    var n = 0;
    for (var i = 0; i < questions.length; i++) {
      if (!answers.containsKey(i)) n++;
    }
    return n;
  }

  /// Per [TaxiPracticeQuestion.categoryTag] — correct / total in this session.
  Map<String, ({int correct, int total})> categoryBreakdown() {
    final map = <String, ({int correct, int total})>{};
    for (var i = 0; i < questions.length; i++) {
      final tag = questions[i].categoryTag.trim().isEmpty ? 'Övrigt' : questions[i].categoryTag.trim();
      final prev = map[tag] ?? (correct: 0, total: 0);
      final ok = answers[i] != null && answers[i] == questions[i].correctOptionIndex;
      map[tag] = (correct: prev.correct + (ok ? 1 : 0), total: prev.total + 1);
    }
    return map;
  }

  bool get passed => correctCount() >= passThreshold;

  String get delprovLabel => part == 1 ? 'Delprov 1: Säkerhet och beteende' : 'Delprov 2: Lagstiftning';

  /// Short label for result header (Stitch).
  String get resultHeaderSubtitle =>
      part == 1 ? 'Säkerhet & beteende' : 'Lagstiftning';
}
