import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persisted slutprov attempts for Min statistik / Senaste Slutprov.
class MockExamHistoryEntry {
  const MockExamHistoryEntry({
    required this.completedAtMillis,
    required this.part,
    required this.correct,
    required this.total,
    required this.passed,
  });

  final int completedAtMillis;
  final int part;
  final int correct;
  final int total;
  final bool passed;

  DateTime get completedAt => DateTime.fromMillisecondsSinceEpoch(completedAtMillis, isUtc: false);

  int get scorePercent => total > 0 ? ((correct * 100) / total).round() : 0;

  Map<String, dynamic> toJson() => {
        't': completedAtMillis,
        'p': part,
        'c': correct,
        'n': total,
        'ok': passed,
      };

  static MockExamHistoryEntry? fromJson(Map<String, dynamic> m) {
    final t = (m['t'] as num?)?.toInt();
    final p = (m['p'] as num?)?.toInt();
    final c = (m['c'] as num?)?.toInt();
    final n = (m['n'] as num?)?.toInt();
    final ok = m['ok'];
    if (t == null || p == null || c == null || n == null || ok is! bool) return null;
    return MockExamHistoryEntry(
      completedAtMillis: t,
      part: p,
      correct: c,
      total: n,
      passed: ok,
    );
  }
}

class MockExamHistory {
  MockExamHistory._();

  static const _key = 'taxi_mock_exam_history_v1';
  static const _maxEntries = 20;

  static Future<List<MockExamHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final out = <MockExamHistoryEntry>[];
      for (final e in list) {
        if (e is Map) {
          final entry = MockExamHistoryEntry.fromJson(Map<String, dynamic>.from(e));
          if (entry != null) out.add(entry);
        }
      }
      out.sort((a, b) => b.completedAtMillis.compareTo(a.completedAtMillis));
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Idempotent per attempt: same [dedupeMillis] skips duplicate save.
  static Future<void> recordOnce({
    required int part,
    required int correct,
    required int total,
    required bool passed,
    required int dedupeMillis,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRaw = prefs.getString('${_key}_last_dedupe');
    if (lastRaw == dedupeMillis.toString()) return;

    final existing = await load();
    final entry = MockExamHistoryEntry(
      completedAtMillis: DateTime.now().millisecondsSinceEpoch,
      part: part,
      correct: correct,
      total: total,
      passed: passed,
    );
    final merged = [entry, ...existing];
    if (merged.length > _maxEntries) merged.removeRange(_maxEntries, merged.length);
    await prefs.setString(
      _key,
      jsonEncode(merged.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('${_key}_last_dedupe', dedupeMillis.toString());
  }
}
