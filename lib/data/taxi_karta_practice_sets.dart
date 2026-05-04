import '../models/taxi_practice_question.dart';
import 'taxi_question_bank.dart';

const String kTaxiModuleKarta = 'karta';

const int kKartaPracticeSetCount = 3;

List<List<TaxiPracticeQuestion>>? _kartaPartitions;

List<List<TaxiPracticeQuestion>> kartaPracticePartitions() {
  if (_kartaPartitions != null) return _kartaPartitions!;

  final all = TaxiQuestionBank.instance.questions
      .where((q) => q.moduleId == kTaxiModuleKarta)
      .toList()
    ..sort((a, b) {
      final c = a.setNumber.compareTo(b.setNumber);
      if (c != 0) return c;
      final d = a.questionNumber.compareTo(b.questionNumber);
      if (d != 0) return d;
      return a.id.compareTo(b.id);
    });

  _kartaPartitions = _chunkIntoN(all, kKartaPracticeSetCount);
  return _kartaPartitions!;
}

void clearKartaPracticePartitionCacheInternal() {
  _kartaPartitions = null;
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

TaxiPracticeQuestion? lookupKartaPracticeQuestion({
  required int practiceSet,
  required int questionOneBased,
}) {
  if (practiceSet < 1 || practiceSet > kKartaPracticeSetCount) return null;
  final parts = kartaPracticePartitions();
  final list = parts[practiceSet - 1];
  if (list.isEmpty) return null;
  final idx = questionOneBased - 1;
  if (idx < 0 || idx >= list.length) return null;
  final raw = list[idx];
  return raw.copyWith(
    setNumber: practiceSet,
    questionNumber: questionOneBased,
    totalInSet: list.length,
    categoryTag: raw.categoryTag.isNotEmpty ? raw.categoryTag : 'Karta',
  );
}

int kartaPracticeSetSize(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kKartaPracticeSetCount) return 0;
  final parts = kartaPracticePartitions();
  return parts[practiceSet - 1].length;
}

List<TaxiPracticeQuestion> kartaPracticeQuestions(int practiceSet) {
  if (practiceSet < 1 || practiceSet > kKartaPracticeSetCount) return const [];
  return kartaPracticePartitions()[practiceSet - 1];
}
