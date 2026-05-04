import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_karta_practice_sets.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../data/taxi_sakerhet_practice_sets.dart';
import '../models/taxi_practice_question.dart';
import '../services/karta_practice_repository.dart';
import '../services/lagar_practice_repository.dart';
import '../services/mock_exam_history.dart';
import '../services/sakerhet_practice_repository.dart';
import '../services/taxi_entitlement_service.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

/// Stitch node: a6a676fce94a43819bd936684625e3f0
class TaxiStatisticsScreen extends StatelessWidget {
  const TaxiStatisticsScreen({super.key});

  static String _svDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  static double _completionFor({
    required int setCount,
    required int Function(int set) setSize,
    required Object? Function(int set) load,
  }) {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= setCount; i++) {
      totalQ += setSize(i);
      final p = load(i);
      if (p == null) continue;
      answered += _answersMap(p).length;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  static Map<String, int> _answersMap(dynamic prog) {
    if (prog == null) return {};
    try {
      final a = prog.answers as Map<String, int>?;
      return a ?? {};
    } catch (_) {
      return {};
    }
  }

  static double _moduleAccuracy({
    required int setCount,
    required List<TaxiPracticeQuestion> Function(int set) questionsForSet,
    required Object? Function(int set) load,
  }) {
    var answered = 0;
    var correct = 0;
    for (var set = 1; set <= setCount; set++) {
      final prog = load(set);
      if (prog == null) continue;
      final answers = _answersMap(prog);
      if (answers.isEmpty) continue;
      final qs = questionsForSet(set);
      final correctById = {for (final q in qs) q.id: q.correctOptionIndex};
      for (final e in answers.entries) {
        final c = correctById[e.key];
        if (c == null) continue;
        answered++;
        if (c == e.value) correct++;
      }
    }
    if (answered == 0) return 0;
    return correct / answered;
  }

  static double _focusedSetAccuracy({
    required int setCount,
    required List<TaxiPracticeQuestion> Function(int set) questionsForSet,
    required Object? Function(int set) load,
  }) {
    var best = 0;
    double acc = 0;
    for (var set = 1; set <= setCount; set++) {
      final prog = load(set);
      final answers = _answersMap(prog);
      if (answers.isEmpty) continue;
      if (answers.length >= best) {
        best = answers.length;
        final qs = questionsForSet(set);
        final correctById = {for (final q in qs) q.id: q.correctOptionIndex};
        var c = 0;
        for (final e in answers.entries) {
          final x = correctById[e.key];
          if (x != null && x == e.value) c++;
        }
        acc = c / answers.length;
      }
    }
    return acc;
  }

  static double _latestSakerhet(List<MockExamHistoryEntry> history) {
    for (final e in history) {
      if (e.part == 1) return e.scorePercent / 100;
    }
    return _focusedSetAccuracy(
      setCount: kSakerhetPracticeSetCount,
      questionsForSet: sakerhetPracticeQuestions,
      load: (s) => SakerhetPracticeRepository.instance.load(s),
    );
  }

  static double _latestLagar(List<MockExamHistoryEntry> history) {
    for (final e in history) {
      if (e.part == 2) return e.scorePercent / 100;
    }
    return _focusedSetAccuracy(
      setCount: kLagstiftningPracticeSetCount,
      questionsForSet: lagstiftningPracticeQuestions,
      load: (s) => LagarPracticeRepository.instance.load(s),
    );
  }

  static double _latestKarta() {
    return _focusedSetAccuracy(
      setCount: kKartaPracticeSetCount,
      questionsForSet: kartaPracticeQuestions,
      load: (s) => KartaPracticeRepository.instance.load(s),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MockExamHistoryEntry>>(
      future: MockExamHistory.load(),
      builder: (context, snap) {
        final loggedIn =
            TaxiEntitlementService.instance.canViewPersonalTaxiProgress;
        final history = loggedIn ? (snap.data ?? []) : <MockExamHistoryEntry>[];

        final sComp = loggedIn
            ? _completionFor(
                setCount: kSakerhetPracticeSetCount,
                setSize: sakerhetPracticeSetSize,
                load: (s) => SakerhetPracticeRepository.instance.load(s),
              )
            : 0.0;
        final kComp = loggedIn
            ? _completionFor(
                setCount: kKartaPracticeSetCount,
                setSize: kartaPracticeSetSize,
                load: (s) => KartaPracticeRepository.instance.load(s),
              )
            : 0.0;
        final lComp = loggedIn
            ? _completionFor(
                setCount: kLagstiftningPracticeSetCount,
                setSize: lagstiftningPracticeSetSize,
                load: (s) => LagarPracticeRepository.instance.load(s),
              )
            : 0.0;
        const vComp = 0.0;

        final overall = ((sComp + kComp + lComp + vComp) / 4 * 100).round();
        final sMain =
            (loggedIn
                ? _moduleAccuracy(
                    setCount: kSakerhetPracticeSetCount,
                    questionsForSet: sakerhetPracticeQuestions,
                    load: (s) => SakerhetPracticeRepository.instance.load(s),
                  )
                : 0.0) *
            100;
        final kMain =
            (loggedIn
                ? _moduleAccuracy(
                    setCount: kKartaPracticeSetCount,
                    questionsForSet: kartaPracticeQuestions,
                    load: (s) => KartaPracticeRepository.instance.load(s),
                  )
                : 0.0) *
            100;
        final lMain =
            (loggedIn
                ? _moduleAccuracy(
                    setCount: kLagstiftningPracticeSetCount,
                    questionsForSet: lagstiftningPracticeQuestions,
                    load: (s) => LagarPracticeRepository.instance.load(s),
                  )
                : 0.0) *
            100;
        final vMain = 0.0;

        final sLatest = (_latestSakerhet(history) * 100).round();
        final kLatest = (_latestKarta() * 100).round();
        final lLatest = (_latestLagar(history) * 100).round();
        const vLatest = 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 64,
            shape: const Border(
              bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
            ),
            titleSpacing: 16,
            title: Row(
              children: [
                Icon(
                  Icons.menu_rounded,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.local_taxi_rounded,
                  size: 18,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'TaxiTeori',
                  style: GoogleFonts.publicSans(
                    fontSize: 34 / 2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F6DB5), Color(0xFF0A3A66)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Min Statistik',
                  style: GoogleFonts.publicSans(
                    fontSize: 38 / 2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                if (!loggedIn) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => context.push('/login'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Text(
                        'Logga in för att se din personliga statistik.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _OverallCard(overallPercent: overall),
                const SizedBox(height: 18),
                Text(
                  'Studiekategorier',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.92,
                  children: [
                    _CategoryTile(
                      title: 'Säkerhet &\nBeteende',
                      icon: Icons.security_rounded,
                      iconColor: const Color(0xFF2F6DB5),
                      iconBg: const Color(0xFFE4EEFF),
                      pct: sMain.round(),
                      latest: sLatest,
                      barColor: const Color(0xFF4E6DFF),
                    ),
                    _CategoryTile(
                      title: 'Karta &\nRuttplanering',
                      icon: Icons.map_rounded,
                      iconColor: const Color(0xFF2B8A3E),
                      iconBg: const Color(0xFFE2F6E8),
                      pct: kMain.round(),
                      latest: kLatest,
                      barColor: const Color(0xFF46B26D),
                    ),
                    _CategoryTile(
                      title: 'Lagstiftning',
                      icon: Icons.gavel_rounded,
                      iconColor: const Color(0xFF8A42C8),
                      iconBg: const Color(0xFFF0E4FF),
                      pct: lMain.round(),
                      latest: lLatest,
                      barColor: const Color(0xFF8A42C8),
                    ),
                    _CategoryTile(
                      title: 'Vägmärken',
                      icon: Icons.traffic_rounded,
                      iconColor: const Color(0xFFC26A1A),
                      iconBg: const Color(0xFFFFF1DD),
                      pct: vMain.round(),
                      latest: vLatest,
                      barColor: const Color(0xFFD48A2A),
                      notStarted: true,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Senaste Slutprov',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                _HistoryCard(history: history),
              ],
            ),
          ),
          bottomNavigationBar: const TaxiShellBottomNav(
            selectedRoute: '/taxi-statistik',
          ),
        );
      },
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.overallPercent});

  final int overallPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CircularProgressIndicator(
                    value: (overallPercent / 100).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$overallPercent%',
                      style: GoogleFonts.publicSans(
                        fontSize: 40 / 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    Text(
                      'TOTALT',
                      style: GoogleFonts.publicSans(
                        fontSize: 14 / 2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Övergripande framsteg',
            style: GoogleFonts.publicSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Du är på god väg mot din taxilegitimation. Fortsätt öva på de områden där du behöver mer träning för att nå 100%.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.35,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.pct,
    required this.latest,
    required this.barColor,
    this.notStarted = false,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int pct;
  final int latest;
  final Color barColor;
  final bool notStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notStarted ? 'Ej påbörjat' : 'Senaste: $latest%',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});

  final List<MockExamHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Text(
          'Inga avslutade slutprov ännu.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    final top = history.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: List.generate(top.length, (i) {
          final e = top[i];
          final n = history.length - i;
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (e.passed ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    e.passed ? Icons.check_rounded : Icons.close_rounded,
                    size: 16,
                    color: e.passed ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TaxiStatisticsScreen._svDate(e.completedAt),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Slutprov #$n',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${e.scorePercent}%',
                      style: GoogleFonts.publicSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      e.passed ? 'GODKÄND' : 'UNDERKÄND',
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: e.passed ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
