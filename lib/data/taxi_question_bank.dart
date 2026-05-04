import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/taxi_practice_question.dart';

/// Loads taxi practice items from **assets/taxi/bank/questions.json** at startup.
///
/// **JSON shape:** either a top-level array `[{...}, ...]` or `{ "questions": [...] }`.
/// Each object maps to [TaxiPracticeQuestion] (see [_parseQuestion] keys).
/// Replace or append to that file when you export from **taxi-license**.
///
/// **Images (Phase 2):** paths under `assets/taxi/bank/images/` in JSON are served from
/// **Firebase Storage** at `taxi/bank/images/<file>` when available; otherwise the
/// bundled asset is used. See [scripts/upload_taxi_bank_images_to_storage.sh].
class TaxiQuestionBank {
  TaxiQuestionBank._();
  static final TaxiQuestionBank instance = TaxiQuestionBank._();

  List<TaxiPracticeQuestion> _questions = [];
  bool _loaded = false;

  List<TaxiPracticeQuestion> get questions => List.unmodifiable(_questions);

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/taxi/bank/questions.json');
      final decoded = jsonDecode(raw);
      final List<dynamic> list;
      if (decoded is List<dynamic>) {
        list = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['questions'] is List<dynamic>) {
        list = decoded['questions']! as List<dynamic>;
      } else {
        list = const [];
      }
      _questions = [
        for (final e in list)
          if (e is Map<String, dynamic> && (e['id']?.toString() ?? '').isNotEmpty) _parseQuestion(e),
      ];
    } catch (e, st) {
      debugPrint('TaxiQuestionBank: failed to load questions.json — $e');
      debugPrint('$st');
      _questions = [];
    }
    _loaded = true;
  }

  TaxiPracticeQuestion? lookup({
    required String module,
    required int set,
    required int questionOneBased,
  }) {
    for (final q in _questions) {
      if (q.moduleId == module && q.setNumber == set && q.questionNumber == questionOneBased) {
        return q;
      }
    }
    return null;
  }

  /// First row in the bank (for router fallback when lookup fails).
  TaxiPracticeQuestion? get firstQuestion => _questions.isEmpty ? null : _questions.first;
}

TaxiPracticeQuestion _parseQuestion(Map<String, dynamic> m) {
  final optionsRaw = m['options'];
  final options = optionsRaw is List<dynamic>
      ? optionsRaw.map((e) => e.toString()).toList()
      : <String>[];

  return TaxiPracticeQuestion(
    id: m['id']?.toString() ?? '',
    moduleId: m['moduleId'] as String,
    setNumber: _asInt(m['setNumber'], 1),
    questionNumber: _asInt(m['questionNumber'], 1),
    totalInSet: _asInt(m['totalInSet'], 1),
    categoryTag: m['categoryTag'] as String? ?? '',
    prompt: m['prompt'] as String? ?? '',
    options: options,
    correctOptionIndex: _asInt(m['correctOptionIndex'], 0),
    explanationText: m['explanationText'] as String?,
    explanationImageAssetPaths: _stringList(m['explanationImageAssetPaths']),
    explanationImageUrls: _stringList(m['explanationImageUrls']),
    imageAssetPath: m['imageAssetPath'] as String?,
    imageNetworkUrl: m['imageNetworkUrl'] as String?,
    imageSemanticLabel: m['imageSemanticLabel'] as String?,
    designIllustrationPrompt: m['designIllustrationPrompt'] as String?,
  );
}

int _asInt(dynamic v, int fallback) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? fallback;
}

List<String> _stringList(dynamic v) {
  if (v == null) return const [];
  if (v is List<dynamic>) return v.map((e) => e.toString()).toList();
  return const [];
}
