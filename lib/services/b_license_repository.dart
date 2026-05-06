import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/b_license_practice_question.dart';

class BLicenseRepository {
  static final BLicenseRepository instance = BLicenseRepository._();
  BLicenseRepository._();

  bool _isLoaded = false;
  final Map<String, List<BLicensePracticeQuestion>> _categorizedQuestions = {};
  
  static const int _setChunkSize = 50;

  Future<void> load() async {
    if (_isLoaded) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/b_license_import/b_license_categorized.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>;

      final Map<String, List<dynamic>> rawCategoryMap = {};
      for (final q in questions) {
        final cat = q['category'] as String? ?? 'Traffic Rules';
        rawCategoryMap.putIfAbsent(cat, () => []).add(q);
      }

      for (final entry in rawCategoryMap.entries) {
        final cat = entry.key;
        final qs = entry.value;
        final List<BLicensePracticeQuestion> parsedQuestions = [];
        
        for (var i = 0; i < qs.length; i++) {
          final q = qs[i];
          final setNumber = (i ~/ _setChunkSize) + 1;
          
          final optionsList = (q['options'] as List<dynamic>?)?.map((e) => e['text'].toString()).toList() ?? [];
          final correctOptKey = q['correct_option'] as String?;
          int correctIdx = 0;
          if (correctOptKey != null && correctOptKey.isNotEmpty) {
            correctIdx = correctOptKey.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
            if (correctIdx < 0 || correctIdx >= optionsList.length) correctIdx = 0;
          }
          
          final qNumInSet = (i % _setChunkSize) + 1;
          int totalInThisSet = _setChunkSize;
          final remaining = qs.length - ((setNumber - 1) * _setChunkSize);
          if (remaining < _setChunkSize) {
            totalInThisSet = remaining;
          }

          String? imagePath;
          if (q['has_image'] == true) {
            final images = q['image_files'] as List<dynamic>?;
            if (images != null && images.isNotEmpty) {
              final rawStr = images.first.toString();
              // Extract just the filename to avoid absolute paths from the json dump
              final filename = rawStr.split('/').last;
              imagePath = 'assets/b_license_import/question_images/$filename';
            }
          }

          parsedQuestions.add(BLicensePracticeQuestion(
            id: q['id']?.toString() ?? 'q_${cat}_$i',
            category: cat,
            setNumber: setNumber,
            questionNumber: qNumInSet,
            totalInSet: totalInThisSet,
            prompt: q['question']?.toString() ?? '',
            options: optionsList,
            correctOptionIndex: correctIdx,
            imageAssetPath: imagePath,
          ));
        }
        _categorizedQuestions[cat] = parsedQuestions;
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading b_license categorized json: $e');
    }
  }

  int getSetCount(String category) {
    final qs = _categorizedQuestions[category] ?? [];
    if (qs.isEmpty) return 0;
    return qs.last.setNumber;
  }

  List<BLicensePracticeQuestion> getQuestionsForSet(String category, int setNumber) {
    return (_categorizedQuestions[category] ?? []).where((q) => q.setNumber == setNumber).toList();
  }

  int getTotalQuestions(String category) {
    return (_categorizedQuestions[category] ?? []).length;
  }
}
