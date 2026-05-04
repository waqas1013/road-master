import 'package:flutter/foundation.dart';

/// One multiple-choice item in the taxi theory practice flows.
/// Förklaring mirrors the web bank: optional **text** and/or one or more **images**
/// (`explanationImageAssetPaths` / `explanationImageUrls`).
@immutable
class TaxiPracticeQuestion {
  const TaxiPracticeQuestion({
    required this.id,
    required this.moduleId,
    required this.setNumber,
    required this.questionNumber,
    required this.totalInSet,
    required this.categoryTag,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    this.explanationText,
    this.explanationImageAssetPaths = const [],
    this.explanationImageUrls = const [],
    this.imageAssetPath,
    this.imageNetworkUrl,
    this.imageSemanticLabel,
    this.designIllustrationPrompt,
  });

  final String id;
  final String moduleId;
  final int setNumber;
  /// 1-based index within the set (matches UI "Fråga n av …").
  final int questionNumber;
  final int totalInSet;
  final String categoryTag;
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;

  /// Optional written förklaring (e.g. from imports or extra copy).
  final String? explanationText;

  /// Illustration(s) for förklaring — local assets (paths as in [pubspec]).
  final List<String> explanationImageAssetPaths;

  /// Illustration(s) for förklaring — HTTPS URLs (e.g. Firebase Storage / CDN).
  final List<String> explanationImageUrls;

  final String? imageAssetPath;
  final String? imageNetworkUrl;
  final String? imageSemanticLabel;
  final String? designIllustrationPrompt;

  double get progress => questionNumber / totalInSet;

  String get progressTitle => 'Fråga $questionNumber av $totalInSet';

  /// Whether the **question** has a scenario image to show after the prompt.
  bool get hasQuestionImage =>
      (imageAssetPath != null && imageAssetPath!.isNotEmpty) ||
      (imageNetworkUrl != null && imageNetworkUrl!.isNotEmpty);

  /// Whether **Visa förklaring** has any content (text and/or images).
  bool get hasExplanationContent {
    final t = explanationText?.trim();
    if (t != null && t.isNotEmpty) return true;
    return explanationImageAssetPaths.isNotEmpty || explanationImageUrls.isNotEmpty;
  }
}
