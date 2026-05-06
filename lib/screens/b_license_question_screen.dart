import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/b_license_repository.dart';
import '../models/b_license_practice_question.dart';
import '../widgets/taxi_option_step_text.dart'; // Reuse the option text widget
import '../widgets/taxi_shell_bottom_nav.dart'; // Just the standard bottom nav component used in taxi, wait, we shouldn't use taxi bottom nav on b license. Let's just use the default bottom bar if needed.

class BLicenseQuestionScreen extends StatefulWidget {
  final String categoryTitle;
  final int setNumber;

  const BLicenseQuestionScreen({
    super.key,
    required this.categoryTitle,
    required this.setNumber,
  });

  @override
  State<BLicenseQuestionScreen> createState() => _BLicenseQuestionScreenState();
}

class _BLicenseQuestionScreenState extends State<BLicenseQuestionScreen> {
  late List<BLicensePracticeQuestion> _questions;
  int _currentIndex = 0;
  int _selectedOption = -1;
  bool _checked = false;
  bool _explanationExpanded = false;
  
  // Track stats for the current session
  int _correctAnswers = 0;
  // Keep track of which question indices we've already answered correctly so we don't double count if we go back
  final Set<int> _answeredCorrectly = {};

  @override
  void initState() {
    super.initState();
    _questions = BLicenseRepository.instance.getQuestionsForSet(widget.categoryTitle, widget.setNumber);
  }

  BLicensePracticeQuestion get q => _questions[_currentIndex];

  void _onNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = -1;
        _checked = false;
        _explanationExpanded = false;
      });
    } else {
      // End of set, go to results
      context.pushReplacement('/b-license-results?title=${Uri.encodeComponent(widget.categoryTitle)}&set=${widget.setNumber}&correct=$_correctAnswers&total=${_questions.length}');
    }
  }

  void _onPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedOption = -1;
        _checked = false;
        _explanationExpanded = false;
      });
    } else {
      context.pop(); // return to sets list if at the very beginning
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice Set')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final progress = (q.questionNumber) / q.totalInSet;
    final isLastQuestion = _currentIndex >= _questions.length - 1;

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fråga ${q.questionNumber} av ${q.totalInSet}',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              q.category,
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            q.prompt,
                            style: GoogleFonts.publicSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 28 / 20,
                              color: AppColors.onSurface,
                            ),
                          ),
                          if (q.hasQuestionImage) ...[
                            const SizedBox(height: 16),
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  q.imageAssetPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(q.options.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildOptionCard(index),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectedOption == -1 || _checked
                            ? null
                            : () {
                                setState(() {
                                  _checked = true;
                                  if (q.hasExplanationContent) {
                                    _explanationExpanded = true;
                                  }
                                  
                                  if (_selectedOption == q.correctOptionIndex) {
                                    if (!_answeredCorrectly.contains(_currentIndex)) {
                                      _correctAnswers++;
                                      _answeredCorrectly.add(_currentIndex);
                                    }
                                  }
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.onPrimary,
                          disabledForegroundColor: AppColors.outline,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Kontrollera Svar',
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (q.hasExplanationContent) ...[
                      const SizedBox(height: 16),
                      Material(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _explanationExpanded = !_explanationExpanded;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.outlineVariant.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 22, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Visa förklaring',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 20 / 14,
                                      letterSpacing: 0.02 * 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _explanationExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Icons.expand_more_rounded,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (q.hasExplanationContent && _explanationExpanded) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          q.explanationText!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Navigation for Previous / Next
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.92),
              border: Border(
                top: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.8)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: q.questionNumber <= 1 ? () => context.pop() : _onPrevious,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: AppColors.outline,
                        side: BorderSide(
                          color: AppColors.primary,
                        ),
                        backgroundColor: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chevron_left_rounded, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Föregående',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastQuestion ? 'Visa resultat' : 'Nästa',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isLastQuestion
                                ? Icons.check_circle_outline_rounded
                                : Icons.chevron_right_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == q.correctOptionIndex;
    final optionText = q.options[index];

    Color cardBorder = AppColors.outlineVariant;
    double cardBorderWidth = 1.5;
    Color cardBg = AppColors.surfaceContainerLow;
    Color optionTextColor = AppColors.onSurface;

    if (!_checked && isSelected) {
      cardBorder = AppColors.primary;
      cardBorderWidth = 2;
      cardBg = AppColors.primaryLight.withValues(alpha: 0.28);
      optionTextColor = AppColors.onSurface;
    } else if (_checked) {
      if (isCorrect) {
        cardBorder = AppColors.success;
        cardBorderWidth = 2;
        cardBg = AppColors.successLight.withValues(alpha: 0.5);
        optionTextColor = AppColors.onSurface;
      } else if (isSelected) {
        cardBorder = AppColors.error;
        cardBorderWidth = 2;
        cardBg = AppColors.errorContainer.withValues(alpha: 0.4);
        optionTextColor = AppColors.onSurface;
      } else {
        cardBg = AppColors.surfaceContainerLow.withValues(alpha: 0.85);
        cardBorder = AppColors.outlineVariant.withValues(alpha: 0.65);
        cardBorderWidth = 1.5;
        optionTextColor = AppColors.onSurfaceVariant;
      }
    }

    return Semantics(
      button: true,
      label: 'Alternativ ${index + 1}: $optionText',
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _checked
              ? null
              : () {
                  setState(() => _selectedOption = index);
                },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: cardBorderWidth),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TaxiOptionStepText(
                text: optionText,
                color: optionTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
