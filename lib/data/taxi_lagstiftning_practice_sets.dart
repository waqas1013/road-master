import '../models/taxi_practice_question.dart';
import 'taxi_question_bank.dart';

const String kTaxiModuleLagstiftning = 'lagstiftning';

const int kLagstiftningPracticeSetCount = 4;

List<List<TaxiPracticeQuestion>>? _lagstiftningPartitions;

List<List<TaxiPracticeQuestion>> lagstiftningPracticePartitions() {
  if (_lagstiftningPartitions != null) return _lagstiftningPartitions!;

  final all = TaxiQuestionBank.instance.questions
      .where((q) => q.moduleId == kTaxiModuleLagstiftning)
      .toList()
    ..sort((a, b) {
      final c = a.setNumber.compareTo(b.setNumber);
      if (c != 0) return c;
      final d = a.questionNumber.compareTo(b.questionNumber);
      if (d != 0) return d;
      return a.id.compareTo(b.id);
    });

  _lagstiftningPartitions = _chunkIntoN(all, kLagstiftningPracticeSetCount);
  return _lagstiftningPartitions!;
}

void clearLagstiftningPracticePartitionCacheInternal() {
  _lagstiftningPartitions = null;
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

TaxiPracticeQuestion? lookupLagstiftningPracticeQuestion({
  required int practiceSet,
  required int questionOneBased,
}) {
  if (practiceSet < 1 || practiceSet > kLagstiftningPracticeSetCount) return null;
  final parts = lagstiftningPracticePartitions();
  final list = parts[practiceSet - 1];
  if (list.isEmpty) return null;
  final idx = questionOneBased - 1;
  if (idx < 0 || idx >= list.length) return null;
  final raw = list[idx];
  return raw.copyWith(
    setNumber: practiceSet,
    questionNumber: questionOneBased,
    totalInSet: list.length,
    categoryTag: raw.categoryTag.isNotEmpty ? raw.categoryTag : 'Lagstiftning',
  );
}

int lagstiftningPracticeSetSize(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kLagstiftningPracticeSetCount) return 0;
  final parts = lagstiftningPracticePartitions();
  return parts[practiceSet - 1].length;
}

List<TaxiPracticeQuestion> lagstiftningPracticeQuestions(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kLagstiftningPracticeSetCount) return const [];
  return lagstiftningPracticePartitions()[practiceSet - 1];
}
