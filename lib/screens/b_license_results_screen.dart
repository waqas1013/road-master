import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BLicenseResultsScreen extends StatelessWidget {
  const BLicenseResultsScreen({
    super.key,
    required this.categoryTitle,
    required this.setNumber,
    required this.correctCount,
    required this.totalCount,
  });

  final String categoryTitle;
  final int setNumber;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final incorrect = (totalCount - correctCount).clamp(0, totalCount);
    final pct = totalCount > 0 ? (correctCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final pctLabel = '${(pct * 100).round()}%';
    final passed = pct >= 0.80; // B License typically requires 52/65 = 80% passing rate

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
          icon: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.primaryContainer),
          onPressed: () => context.go('/category-practice?title=${Uri.encodeComponent(categoryTitle)}'),
        ),
        title: Text(
          'B License Theory',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // --- Header ---
              Text(
                'Set $setNumber Results',
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
                'Your result overview for this practice set.',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 28 / 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              if (totalCount == 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No questions in this set.',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              else ...[
                // --- Overall Score Card ---
                _overallScoreCard(pct, pctLabel, passed),
                const SizedBox(height: 16),

                // --- Correct / Incorrect row ---
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.check_circle_rounded,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        label: 'Correct',
                        value: '$correctCount/$totalCount',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.cancel_rounded,
                        iconBg: AppColors.errorContainer,
                        iconColor: AppColors.error,
                        label: 'Incorrect',
                        value: '$incorrect/$totalCount',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- Action Buttons ---
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.pushReplacement('/b-license-question?title=${Uri.encodeComponent(categoryTitle)}&set=$setNumber');
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      'Retake Set',
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
                      context.pop(); // Returns to the practice set selection
                    },
                    icon: const Icon(Icons.list_rounded, size: 20),
                    label: Text(
                      'Back to Sets',
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
    );
  }

  // ---------------------------------------------------------------------------
  // Overall Score — circular ring card
  // ---------------------------------------------------------------------------
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
            'Total Score',
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
                      passed ? 'PASSED' : 'FAILED',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        letterSpacing: 1.5,
                        color: passed ? Colors.green.shade700 : AppColors.onSurfaceVariant,
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

  // ---------------------------------------------------------------------------
  // Stat card — icon circle + label + big number
  // ---------------------------------------------------------------------------
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
}

// -----------------------------------------------------------------------------
// Circular score ring painter
// -----------------------------------------------------------------------------
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
