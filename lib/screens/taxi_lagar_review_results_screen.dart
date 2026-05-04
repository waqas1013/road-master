import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../services/lagar_practice_repository.dart';
import '../theme/app_colors.dart';
import '../router/taxi_question_transition.dart';

class TaxiLagarReviewResultsScreen extends StatelessWidget {
  const TaxiLagarReviewResultsScreen({super.key, required this.practiceSet});

  final int practiceSet;

  @override
  Widget build(BuildContext context) {
    final partition = lagstiftningPracticeQuestions(practiceSet);
    final total = partition.length;
    final progress = LagarPracticeRepository.instance.load(practiceSet);
    final correctById = {for (final q in partition) q.id: q.correctOptionIndex};
    final correct = progress?.correctCount(correctById) ?? 0;
    final answered = progress?.answers.length ?? 0;
    final incorrect = (answered - correct).clamp(0, total);
    final pct = total > 0 ? (correct / total).clamp(0.0, 1.0) : 0.0;
    final pctLabel = '${(pct * 100).round()}%';
    final completed = progress?.completed == true;
    final passed = pct >= 0.65;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        shape: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.primaryContainer),
          onPressed: () => context.go('/taxi-lagstiftning'),
        ),
        title: Text(
          'Taxi Teori',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, size: 26, color: AppColors.primaryContainer),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Set $practiceSet resultat',
                style: GoogleFonts.publicSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 40 / 32,
                  letterSpacing: -0.64,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                completed
                    ? 'Din resultatöversikt för detta övningspaket.'
                    : 'Ofullständig övning — $answered av $total besvarade.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 28 / 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              if (total == 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Inga frågor i detta set ännu.',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              else ...[
                _overallScoreCard(pct, pctLabel, passed),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.check_circle_rounded,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        label: 'Rätt',
                        value: '$correct/$total',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.cancel_rounded,
                        iconBg: AppColors.errorContainer,
                        iconColor: AppColors.error,
                        label: 'Fel',
                        value: '$incorrect/$total',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await LagarPracticeRepository.instance.clear(practiceSet);
                      if (!context.mounted) return;
                      context.go(
                        taxiQuestionUriWithTx(
                          '/taxi-question?module=lagstiftning&practiceSet=$practiceSet&q=1',
                          TaxiQuestionTransition.forward,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      'Gör om set',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 0.28,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/taxi-lagar-continue?practiceSet=$practiceSet');
                    },
                    icon: const Icon(Icons.fact_check_rounded, size: 20),
                    label: Text(
                      'Granska alla frågor',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 0.28,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _overallScoreCard(double pct, String pctLabel, bool passed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Totalpoäng',
            style: GoogleFonts.publicSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(192, 192),
                  painter: _ScoreRingPainter(percentage: pct),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pctLabel,
                      style: GoogleFonts.publicSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 40 / 32,
                        letterSpacing: -0.64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passed ? 'GODKÄNT' : 'EJ GODKÄNT',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.publicSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 32 / 24,
                    letterSpacing: -0.24,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.surfaceVariant, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nav(context, Icons.home_rounded, 'Hem', 0, '/taxi-dashboard'),
              _nav(context, Icons.map_outlined, 'Karta', 1, '/taxi-karta'),
              _nav(context, Icons.security_outlined, 'Säkerhet', 2, '/taxi-sakerhet'),
              _nav(context, Icons.gavel_outlined, 'Lagar', 3, '/taxi-lagstiftning'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label, int index, String route) {
    final isSelected = index == 3;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.percentage});

  final double percentage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final bgPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      bgPaint,
    );

    final fgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * percentage,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) => old.percentage != percentage;
}
