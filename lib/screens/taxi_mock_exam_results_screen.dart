import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_exam_history.dart';
import '../services/mock_exam_session.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

/// Stitch **Provresultat** layout.
class TaxiMockExamResultsScreen extends StatefulWidget {
  const TaxiMockExamResultsScreen({super.key});

  @override
  State<TaxiMockExamResultsScreen> createState() =>
      _TaxiMockExamResultsScreenState();
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _persistHistory(session),
    );
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

  String _resultTitle(MockExamSession session) {
    return 'Resultat: ${session.resultHeaderSubtitle}';
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
          automaticallyImplyLeading: false,
          shape: const Border(
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: _leaveToSlutprov,
          ),
          title: Text(
            _resultTitle(session),
            style: GoogleFonts.publicSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ScoreRing(correct: correct, total: total, passed: passed),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (passed ? AppColors.success : AppColors.error)
                                .withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            passed
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 22,
                            color: passed
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          passed ? 'Godkänt' : 'Ej godkänt',
                          style: GoogleFonts.publicSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: passed ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      outcomeMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (session.abandonedByUser) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Du avbröt provet. Resultatet baseras på de frågor du hann besvara.',
                        textAlign: TextAlign.center,
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 20 / 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.access_time_rounded,
                      value: usedLabel,
                      label: 'Tid använd',
                      backgroundColor: AppColors.chipBlue,
                      iconColor: AppColors.chipBlueText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.check_circle_outline_rounded,
                      value: '$correct',
                      label: 'Rätt',
                      backgroundColor: AppColors.successLight,
                      iconColor: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.cancel_outlined,
                      value: '$wrong',
                      label: 'Fel',
                      backgroundColor: AppColors.errorContainer,
                      iconColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.help_outline_rounded,
                      value: '$skipped',
                      label: 'Hoppade',
                      backgroundColor: AppColors.warningLight,
                      iconColor: const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/taxi-mock-exam-review'),
                  icon: const Icon(Icons.visibility_rounded, size: 22),
                  label: Text(
                    'Granska svar',
                    style: GoogleFonts.publicSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _leaveToSlutprov,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.surfaceVariant),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tillbaka till Slutprov',
                    style: GoogleFonts.publicSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
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

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.correct,
    required this.total,
    required this.passed,
  });

  final int correct;
  final int total;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : (correct / total).clamp(0.0, 1.0);
    final ringColor = passed ? AppColors.success : AppColors.error;
    final trackColor = passed
        ? AppColors.success.withValues(alpha: 0.2)
        : const Color(0xFFFFCDD2);
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(148, 148),
            painter: _RingPainter(
              progress: progress,
              color: ringColor,
              trackColor: trackColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correct',
                style: GoogleFonts.publicSans(
                  fontSize: 66 / 2,
                  fontWeight: FontWeight.w700,
                  color: ringColor,
                ),
              ),
              Text(
                'av $total',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, 0, math.pi * 2, false, bgPaint);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    this.iconColor = AppColors.onSurfaceVariant,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.publicSans(
              fontSize: 32 / 2,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
