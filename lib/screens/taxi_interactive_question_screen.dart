import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_sakerhet_questions.dart';
import '../models/taxi_practice_question.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_option_step_text.dart';

/// Interactive practice question — layout aligned with Stitch **Interactive Practice Question v2**.
class TaxiInteractiveQuestionScreen extends StatefulWidget {
  const TaxiInteractiveQuestionScreen({
    super.key,
    required this.question,
    this.bottomNavActiveIndex = 2,
  });

  final TaxiPracticeQuestion question;
  /// Hem=0, Karta=1, Säkerhet=2, Lagar=3
  final int bottomNavActiveIndex;

  @override
  State<TaxiInteractiveQuestionScreen> createState() => _TaxiInteractiveQuestionScreenState();
}

class _TaxiInteractiveQuestionScreenState extends State<TaxiInteractiveQuestionScreen> {
  int _selectedOption = -1;
  bool _checked = false;
  bool _explanationExpanded = false;

  TaxiPracticeQuestion get q => widget.question;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          q.progressTitle,
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border_rounded, size: 24, color: AppColors.primaryContainer),
            onPressed: () {},
          ),
        ],
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
                        value: q.progress.clamp(0.0, 1.0),
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
                              q.categoryTag,
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
                                child: _buildQuestionImage(),
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
                        child: _buildOption(index),
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
                                Icon(Icons.info_outline_rounded, size: 22, color: AppColors.primary),
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
                                  child: Icon(
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
                        child: _buildExplanationBody(),
                      ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
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
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
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
                            'Nästa',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 20),
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// Förklaring: show all explanation images first, then optional text (matches web bank shape).
  Widget _buildExplanationBody() {
    final text = q.explanationText?.trim();
    final imageBlocks = <Widget>[];

    for (final path in q.explanationImageAssetPaths) {
      if (path.isEmpty) continue;
      imageBlocks.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            path,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
          ),
        ),
      );
    }
    for (final url in q.explanationImageUrls) {
      if (url.isEmpty) continue;
      imageBlocks.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
          ),
        ),
      );
    }

    if (imageBlocks.isEmpty && (text == null || text.isEmpty)) {
      return Text(
        'Ingen förklaring tillgänglig.',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          height: 20 / 14,
          color: AppColors.outline,
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < imageBlocks.length; i++) {
      children.add(imageBlocks[i]);
      if (i < imageBlocks.length - 1) {
        children.add(const SizedBox(height: 12));
      }
    }
    if (text != null && text.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 12));
      }
      children.add(
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  void _onNext() {
    final next = q.questionNumber + 1;
    final nextQ = lookupTaxiQuestion(
      module: q.moduleId,
      set: q.setNumber,
      questionOneBased: next,
    );
    if (nextQ != null) {
      context.pushReplacement(
        '/taxi-question?module=${q.moduleId}&set=${q.setNumber}&q=$next',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fler frågor i detta set kommer snart.')),
      );
    }
  }

  Widget _buildQuestionImage() {
    final label = q.imageSemanticLabel ?? q.designIllustrationPrompt ?? '';
    final path = q.imageAssetPath;
    if (path != null) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        semanticLabel: label.isEmpty ? null : label,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }
    final url = q.imageNetworkUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: label.isEmpty ? null : label,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return ColoredBox(
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.outline, size: 40),
      ),
    );
  }

  Widget _buildOption(int index) {
    final isSelected = _selectedOption == index;
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
      if (index == q.correctOptionIndex) {
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

    final lines = linesForOptionText(optionText);
    final firstLine = lines.isNotEmpty ? lines.first : optionText;
    return Semantics(
      button: true,
      label: 'Alternativ ${index + 1}: $firstLine',
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
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
              _buildNavItem(context, Icons.home_rounded, 'Hem', 0, '/taxi-dashboard'),
              _buildNavItem(context, Icons.map_outlined, 'Karta', 1, '/taxi-karta'),
              _buildNavItem(context, Icons.security_outlined, 'Säkerhet', 2, '/taxi-sakerhet'),
              _buildNavItem(context, Icons.gavel_outlined, 'Lagar', 3, '/taxi-lagstiftning'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, String route) {
    final isSelected = index == widget.bottomNavActiveIndex;
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
