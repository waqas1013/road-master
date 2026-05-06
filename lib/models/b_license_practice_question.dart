import 'package:flutter/foundation.dart';

@immutable
class BLicensePracticeQuestion {
  const BLicensePracticeQuestion({
    required this.id,
    required this.category,
    required this.setNumber,
    required this.questionNumber,
    required this.totalInSet,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    this.imageAssetPath,
    this.explanationText,
  });

  final String id;
  final String category;
  final int setNumber;
  final int questionNumber;
  final int totalInSet;
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String? imageAssetPath;
  final String? explanationText;

  bool get hasQuestionImage => imageAssetPath != null && imageAssetPath!.isNotEmpty;
  bool get hasExplanationContent => explanationText != null && explanationText!.isNotEmpty;
}
