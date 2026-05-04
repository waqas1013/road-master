import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_exam_history.dart';
import '../services/mock_exam_session.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

/// Stitch **Test Results - Updated Nav** — provresultat efter slutprov.
class TaxiMockExamResultsScreen extends StatefulWidget {
  const TaxiMockExamResultsScreen({super.key});

  @override
  State<TaxiMockExamResultsScreen> createState() => _TaxiMockExamResultsScreenState();
}

class _TaxiMockExamResultsScreenState extends State<TaxiMockExamResultsScreen> {
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    final session = MockExamSession.submitted;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/taxi-mock-exams');
      });
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _persistHistory(session));
  }

  Future<void> _persistHistory(MockExamSession session) async {
    if (_recorded || !mounted) return;
    _recorded = true;
    await MockExamHistory.recordOnce(
      part: session.part,
      correct: session.correctCount(),
      total: session.questions.length,
      passed: session.passed,
      dedupeMillis: session.startedAt.millisecondsSinceEpoch,
    );
  }

  void _leaveToSlutprov() {
    MockExamSession.clear();
    context.go('/taxi-mock-exams');
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '0:00';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final session = MockExamSession.submitted;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final correct = session.correctCount();
    final total = session.questions.length;
    final passed = session.passed;
    final used = DateTime.now().difference(session.startedAt);
    final usedLabel = _formatDuration(used);
    final wrong = session.wrongAnsweredCount();
    final skipped = session.skippedCount();
    final categories = session.categoryBreakdown().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final outcomeMessage = passed
        ? 'Grattis! Du uppfyller kravet på minst ${session.passThreshold} rätt.'
        : 'Du behöver minst ${session.passThreshold} rätt för att bli godkänd på detta prov. Gå igenom dina fel och försök igen.';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _leaveToSlutprov();
      },
      child: Scaffold(
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
            onPressed: _leaveToSlutprov,
          ),
          title: Text(
            'Provresultat',
            style: GoogleFonts.publicSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.02 * 20,
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
              Text(
                'Resultat: ${session.resultHeaderSubtitle} - TaxiTeori',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$correct/$total',
                style: GoogleFonts.publicSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 44 / 40,
                  letterSpacing: -0.02 * 40,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: passed ? AppColors.success : AppColors.error,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      passed ? 'Godkänt' : 'Ej godkänt',
                      style: GoogleFonts.publicSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: passed ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                outcomeMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (session.abandonedByUser) ...[
                const SizedBox(height: 8),
                Text(
                  'Du avbröt provet. Resultatet baseras på de frågor du hann besvara.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              if (session.timeExpired) ...[
                const SizedBox(height: 8),
                Text(
                  'Tiden tog slut — provet avslutades automatiskt.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 20, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '$usedLabel Tid använd',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(child: _StatChip(icon: Icons.check_circle_outline, label: '$correct Rätt', color: AppColors.success)),
                    Expanded(child: _StatChip(icon: Icons.cancel_outlined, label: '$wrong Fel', color: AppColors.error)),
                    Expanded(child: _StatChip(icon: Icons.help_outline_rounded, label: '$skipped Hoppade över', color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Resultat per kategori',
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 24 / 18,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...categories.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 22 / 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value.correct}/${e.value.total}',
                        style: GoogleFonts.publicSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/taxi-mock-exam-review'),
                  icon: const Icon(Icons.visibility_rounded, color: AppColors.primary),
                  label: Text(
                    'Granska svar',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _leaveToSlutprov,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Tillbaka till Slutprov',
                    style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: TaxiShellBottomNav(
          selectedRoute: '/taxi-mock-exams',
          onBeforeNavigate: MockExamSession.clear,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
