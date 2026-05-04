import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';
import '../router/taxi_question_transition.dart';

class TaxiContinuePracticeScreen extends StatelessWidget {
  const TaxiContinuePracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 24),
          onPressed: () {},
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Set 2',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Situational Awareness & Traffic Regulations',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Welcome back card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.stars_rounded, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Welcome back',
                                style: GoogleFonts.publicSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onBackground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'You are currently on '),
                                TextSpan(
                                  text: 'Question 41 of 75',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.onBackground),
                                ),
                                const TextSpan(text: '. Continue your practice to master situational awareness.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                '54%',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.54,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, size: 40, color: AppColors.primaryLight),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => context.push(
                                taxiQuestionUriWithTx(
                                  '/taxi-question',
                                  TaxiQuestionTransition.forward,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D325E), // Darker shade of primary
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue Practice',
                                    style: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Set Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Set Summary',
                          style: GoogleFonts.publicSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This set focuses on real-world scenarios requiring acute situational awareness and strict adherence to traffic laws. It covers questions 76 through 150 from the master question bank.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag('Situational Awareness'),
                        _buildTag('Traffic Laws'),
                        _buildTag('75 Questions Total'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Questions in this Set',
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              // Questions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  _buildQuestionItem(1, isCompleted: true),
                  _buildQuestionItem(2, isCompleted: true),
                  _buildQuestionItem(null, isCompleted: true, text: '...'),
                  _buildQuestionItem(40, isCompleted: true),
                  _buildQuestionItem(41, isCurrent: true),
                  _buildQuestionItem(42, isLocked: true),
                  _buildQuestionItem(43, isLocked: true),
                  _buildQuestionItem(44, isLocked: true),
                  _buildQuestionItem(null, isLocked: true, text: '...'),
                  _buildQuestionItem(75, isLocked: true),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TaxiShellBottomNav(),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildQuestionItem(int? number, {bool isCompleted = false, bool isCurrent = false, bool isLocked = false, String? text}) {
    Color bgColor = Colors.white;
    Color borderColor = AppColors.outlineVariant.withValues(alpha: 0.5);
    Color textColor = AppColors.onBackground;

    if (isCompleted) {
      borderColor = AppColors.success.withValues(alpha: 0.3);
    } else if (isCurrent) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isLocked) {
      bgColor = AppColors.surfaceContainerLow;
      borderColor = Colors.transparent;
      textColor = AppColors.onSurfaceVariant.withValues(alpha: 0.6);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              text ?? number.toString(),
              style: GoogleFonts.publicSans(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (isCompleted)
            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.success),
            )
          else if (isCurrent)
            const Positioned(
              bottom: 4,
              right: 4,
              child: Icon(Icons.play_arrow_rounded, size: 12, color: Colors.white),
            )
          else if (isLocked)
            Positioned(
              bottom: 4,
              right: 4,
              child: Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.outline),
            ),
        ],
      ),
    );
  }
}
