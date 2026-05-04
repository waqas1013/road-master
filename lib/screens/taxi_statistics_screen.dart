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

/// Stitch **Statistics & Progress - Updated Nav** — Min statistik.
class TaxiStatisticsScreen extends StatelessWidget {
  const TaxiStatisticsScreen({super.key});

  static String _svDate(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  static double _sakerhetCompletion() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kSakerhetPracticeSetCount; i++) {
      totalQ += sakerhetPracticeSetSize(i);
      final p = SakerhetPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  static double _lagarCompletion() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kLagstiftningPracticeSetCount; i++) {
      totalQ += lagstiftningPracticeSetSize(i);
      final p = LagarPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  static double _kartaCompletion() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kKartaPracticeSetCount; i++) {
      totalQ += kartaPracticeSetSize(i);
      final p = KartaPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  /// Rätt / svarade över alla set i modulen.
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

  static Map<String, int> _answersMap(dynamic prog) {
    if (prog == null) return {};
    try {
      final a = prog.answers as Map<String, int>?;
      return a ?? {};
    } catch (_) {
      return {};
    }
  }

  static double _sakerhetAccuracy() => _moduleAccuracy(
        setCount: kSakerhetPracticeSetCount,
        questionsForSet: sakerhetPracticeQuestions,
        load: (s) => SakerhetPracticeRepository.instance.load(s),
      );

  static double _lagarAccuracy() => _moduleAccuracy(
        setCount: kLagstiftningPracticeSetCount,
        questionsForSet: lagstiftningPracticeQuestions,
        load: (s) => LagarPracticeRepository.instance.load(s),
      );

  static double _kartaAccuracy() => _moduleAccuracy(
        setCount: kKartaPracticeSetCount,
        questionsForSet: kartaPracticeQuestions,
        load: (s) => KartaPracticeRepository.instance.load(s),
      );

  /// Senaste: senaste slutprov för delprov om finns, annars set med flest svarade.
  static double _senasteSakerhet(List<MockExamHistoryEntry> history) {
    for (final e in history) {
      if (e.part == 1) return e.scorePercent / 100;
    }
    return _focusedSetAccuracy(
      setCount: kSakerhetPracticeSetCount,
      questionsForSet: sakerhetPracticeQuestions,
      load: (s) => SakerhetPracticeRepository.instance.load(s),
    );
  }

  static double _senasteLagar(List<MockExamHistoryEntry> history) {
    for (final e in history) {
      if (e.part == 2) return e.scorePercent / 100;
    }
    return _focusedSetAccuracy(
      setCount: kLagstiftningPracticeSetCount,
      questionsForSet: lagstiftningPracticeQuestions,
      load: (s) => LagarPracticeRepository.instance.load(s),
    );
  }

  static double _senasteKarta() {
    return _focusedSetAccuracy(
      setCount: kKartaPracticeSetCount,
      questionsForSet: kartaPracticeQuestions,
      load: (s) => KartaPracticeRepository.instance.load(s),
    );
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MockExamHistoryEntry>>(
      future: MockExamHistory.load(),
      builder: (context, snap) {
        final loggedIn = TaxiEntitlementService.instance.canViewPersonalTaxiProgress;
        final history = loggedIn ? (snap.data ?? []) : <MockExamHistoryEntry>[];
        final overallPct = loggedIn
            ? ((_sakerhetCompletion() + _kartaCompletion() + _lagarCompletion()) / 3 * 100).round()
            : 0;

        final sAcc = loggedIn ? _sakerhetAccuracy() : 0.0;
        final kAcc = loggedIn ? _kartaAccuracy() : 0.0;
        final lAcc = loggedIn ? _lagarAccuracy() : 0.0;
        final sSen = loggedIn ? _senasteSakerhet(history) : 0.0;
        final kSen = loggedIn ? _senasteKarta() : 0.0;
        final lSen = loggedIn ? _senasteLagar(history) : 0.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shape: const Border(
              bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryContainer),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/taxi-dashboard');
                }
              },
            ),
            title: Text(
              'Min Statistik - TaxiTeori',
              style: GoogleFonts.publicSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.query_stats_rounded, size: 28, color: AppColors.primaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Min Statistik',
                        style: GoogleFonts.publicSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 32 / 24,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!loggedIn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Material(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => context.push('/login'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.login_rounded, color: AppColors.primaryContainer),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Logga in för att se din sparade statistik och resultat från den här enheten.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    height: 20 / 14,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: (overallPct / 100).clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$overallPct%',
                              style: GoogleFonts.publicSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Klar',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Övergripande framsteg',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Du är på god väg mot din taxilegitimation. Fortsätt öva på de områden där du behöver mer träning för att nå 100%.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Kategoriuppdelning',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryCard(
                  icon: Icons.security_rounded,
                  title: 'Säkerhet & beteende',
                  mainPct: (sAcc * 100).round(),
                  senastePct: (sSen * 100).round(),
                ),
                const SizedBox(height: 12),
                _CategoryCard(
                  icon: Icons.map_rounded,
                  title: 'Karta & Ruttplanering',
                  mainPct: (kAcc * 100).round(),
                  senastePct: (kSen * 100).round(),
                ),
                const SizedBox(height: 12),
                _CategoryCard(
                  icon: Icons.gavel_rounded,
                  title: 'Lagstiftning',
                  mainPct: (lAcc * 100).round(),
                  senastePct: (lSen * 100).round(),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Styrkor',
                      style: GoogleFonts.publicSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _Bullet(icon: Icons.check_circle_rounded, iconColor: AppColors.success, text: 'Väjningsregler'),
                const _Bullet(icon: Icons.check_circle_rounded, iconColor: AppColors.success, text: 'Passagerarsäkerhet'),
                const _Bullet(icon: Icons.check_circle_rounded, iconColor: AppColors.success, text: 'Skyltavläsning'),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Icon(Icons.trending_down_rounded, color: AppColors.error, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Kräver övning',
                      style: GoogleFonts.publicSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _Bullet(icon: Icons.cancel_rounded, iconColor: AppColors.error, text: 'GPS-navigering utan mottagning'),
                const _Bullet(icon: Icons.cancel_rounded, iconColor: AppColors.error, text: 'Specifika lokala lagar'),
                const _Bullet(icon: Icons.cancel_rounded, iconColor: AppColors.error, text: 'Arbetstidsregler'),
                const SizedBox(height: 28),
                Text(
                  'Senaste Slutprov',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Text(
                    'Inga avslutade slutprov ännu. Gör ett slutprov för att se historik här.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                else
                  ...List.generate(history.length, (i) {
                    final e = history[i];
                    final n = history.length - i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SlutprovHistoryTile(
                        dateLabel: _svDate(e.completedAt),
                        title: 'Slutprov #$n',
                        percent: e.scorePercent,
                        passed: e.passed,
                      ),
                    );
                  }),
              ],
            ),
          ),
          bottomNavigationBar: const TaxiShellBottomNav(selectedRoute: '/taxi-statistik'),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.mainPct,
    required this.senastePct,
  });

  final IconData icon;
  final String title;
  final int mainPct;
  final int senastePct;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.publicSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$mainPct%',
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              Text(
                'Senaste: $senastePct%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (mainPct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlutprovHistoryTile extends StatelessWidget {
  const _SlutprovHistoryTile({
    required this.dateLabel,
    required this.title,
    required this.percent,
    required this.passed,
  });

  final String dateLabel;
  final String title;
  final int percent;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percent% ${passed ? 'Godkänd' : 'Underkänd'}',
            style: GoogleFonts.publicSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: passed ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
