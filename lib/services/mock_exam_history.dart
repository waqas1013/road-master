import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  DateTime get completedAt =>
      DateTime.fromMillisecondsSinceEpoch(completedAtMillis, isUtc: false);

  int get scorePercent => total > 0 ? ((correct * 100) / total).round() : 0;

  Map<String, dynamic> toJson() => {
    'completedAtMillis': completedAtMillis,
    'part': part,
    'correct': correct,
    'total': total,
    'passed': passed,
  };

  static MockExamHistoryEntry? fromJson(Map<String, dynamic> m) {
    final t = (m['completedAtMillis'] ?? m['t']) as num?;
    final p = (m['part'] ?? m['p']) as num?;
    final c = (m['correct'] ?? m['c']) as num?;
    final n = (m['total'] ?? m['n']) as num?;
    final ok = m['passed'] ?? m['ok'];
    if (t == null || p == null || c == null || n == null || ok is! bool) {
      return null;
    }
    return MockExamHistoryEntry(
      completedAtMillis: t.toInt(),
      part: p.toInt(),
      correct: c.toInt(),
      total: n.toInt(),
      passed: ok,
    );
  }
}

class MockExamHistory {
  MockExamHistory._();

  static const _legacyKey = 'taxi_mock_exam_history_v1';
  static const _legacyDedupeKey = '${_legacyKey}_last_dedupe';
  static const _maxEntries = 20;

  static CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('taxi_mock_exam_history');

  static Future<List<MockExamHistoryEntry>> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snap = await _collection(
        uid,
      ).orderBy('completedAtMillis', descending: true).limit(_maxEntries).get();
      final out = <MockExamHistoryEntry>[];
      for (final d in snap.docs) {
        final entry = MockExamHistoryEntry.fromJson(d.data());
        if (entry != null) out.add(entry);
      }
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final existing = await _collection(
      uid,
    ).where('dedupeMillis', isEqualTo: dedupeMillis).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = MockExamHistoryEntry(
      completedAtMillis: now,
      part: part,
      correct: correct,
      total: total,
      passed: passed,
    );

    await _collection(uid).add({
      ...entry.toJson(),
      'dedupeMillis': dedupeMillis,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Keep only the most recent N entries in Firestore.
    final all = await _collection(
      uid,
    ).orderBy('completedAtMillis', descending: true).get();
    if (all.docs.length > _maxEntries) {
      for (var i = _maxEntries; i < all.docs.length; i++) {
        await all.docs[i].reference.delete();
      }
    }
  }

  /// Removes old local-only history from previous app versions.
  static Future<void> clearLocalCacheForPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyKey);
    await prefs.remove(_legacyDedupeKey);
  }
}
