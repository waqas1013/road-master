import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/taxi_practice_question.dart';
import '../services/mock_exam_session.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

/// Per-question review for the last completed slutprov (Stitch **Granska svar**).
class TaxiMockExamReviewScreen extends StatelessWidget {
  const TaxiMockExamReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = MockExamSession.submitted;
    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryContainer),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Granska svar',
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: session.questions.length,
        itemBuilder: (context, index) {
          final TaxiPracticeQuestion q = session.questions[index];
          final sel = session.answers[index];
          final correctIdx = q.correctOptionIndex;
          final skipped = sel == null;
          final wrong = !skipped && sel != correctIdx;

          String statusLabel;
          Color statusColor;
          if (skipped) {
            statusLabel = 'Hoppade över';
            statusColor = AppColors.onSurfaceVariant;
          } else if (wrong) {
            statusLabel = 'Fel';
            statusColor = AppColors.error;
          } else {
            statusLabel = 'Rätt';
            statusColor = AppColors.success;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Fråga ${index + 1}',
                          style: GoogleFonts.publicSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        statusLabel,
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q.prompt,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 20 / 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    skipped ? 'Ditt svar: —' : 'Ditt svar: ${q.options[sel]}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 18 / 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rätt svar: ${q.options[correctIdx]}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const TaxiShellBottomNav(selectedRoute: '/taxi-mock-exams'),
    );
  }
}
