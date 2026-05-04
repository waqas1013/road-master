import '../models/taxi_practice_question.dart';
import 'taxi_question_bank.dart';
import 'taxi_sakerhet_questions.dart';

/// All **Säkerhet** questions from the bank are split evenly into this many practice cards.
const int kSakerhetPracticeSetCount = 8;

List<List<TaxiPracticeQuestion>>? _sakerhetPartitions;

/// Ordered partitions of Säkerhet bank items (set 1 … [kSakerhetPracticeSetCount]).
List<List<TaxiPracticeQuestion>> sakerhetPracticePartitions() {
  if (_sakerhetPartitions != null) return _sakerhetPartitions!;

  final all = TaxiQuestionBank.instance.questions
      .where((q) => q.moduleId == kTaxiModuleSakerhet)
      .toList()
    ..sort((a, b) {
      final c = a.setNumber.compareTo(b.setNumber);
      if (c != 0) return c;
      final d = a.questionNumber.compareTo(b.questionNumber);
      if (d != 0) return d;
      return a.id.compareTo(b.id);
    });

  _sakerhetPartitions = _chunkIntoN(all, kSakerhetPracticeSetCount);
  return _sakerhetPartitions!;
}

/// Call after bank reload in tests / hot restart if counts change.
void clearSakerhetPracticePartitionCacheInternal() {
  _sakerhetPartitions = null;
}

List<List<TaxiPracticeQuestion>> _chunkIntoN(List<TaxiPracticeQuestion> sorted, int n) {
  if (sorted.isEmpty) {
    return List.generate(n, (_) => <TaxiPracticeQuestion>[]);
  }
  final out = <List<TaxiPracticeQuestion>>[];
  final base = sorted.length ~/ n;
  final rem = sorted.length % n;
  var i = 0;
  for (var s = 0; s < n; s++) {
    final chunkSize = base + (s < rem ? 1 : 0);
    out.add(sorted.sublist(i, i + chunkSize));
    i += chunkSize;
  }
  return out;
}

/// `practiceSet` is 1-based (card "Set 1" … "Set 4").
TaxiPracticeQuestion? lookupSakerhetPracticeQuestion({
  required int practiceSet,
  required int questionOneBased,
}) {
  if (practiceSet < 1 || practiceSet > kSakerhetPracticeSetCount) return null;
  final parts = sakerhetPracticePartitions();
  final list = parts[practiceSet - 1];
  if (list.isEmpty) return null;
  final idx = questionOneBased - 1;
  if (idx < 0 || idx >= list.length) return null;
  final raw = list[idx];
  return raw.copyWith(
    setNumber: practiceSet,
    questionNumber: questionOneBased,
    totalInSet: list.length,
    categoryTag: raw.categoryTag.isNotEmpty ? raw.categoryTag : 'Säkerhet',
  );
}

int sakerhetPracticeSetSize(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kSakerhetPracticeSetCount) return 0;
  final parts = sakerhetPracticePartitions();
  return parts[practiceSet - 1].length;
}

List<TaxiPracticeQuestion> sakerhetPracticeQuestions(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kSakerhetPracticeSetCount) return const [];
  return sakerhetPracticePartitions()[practiceSet - 1];
}
