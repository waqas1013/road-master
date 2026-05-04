import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Stitch screen: "Taxi Mock Exams" — Slutprov listing.
class TaxiMockExamsScreen extends StatelessWidget {
  const TaxiMockExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.primaryContainer),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Slutprov',
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02 * 20,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Slutprov',
                style: GoogleFonts.publicSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 40 / 32,
                  letterSpacing: -0.02 * 32,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Testa dina kunskaper under realistiska förhållanden. Varje prov består av slumpmässigt utvalda frågor från alla kategorier för att simulera det riktiga Trafikverkets prov.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _ExamCard.newExam(
                title: 'Fullständigt prov 1',
                questionCount: 65,
                duration: '50 minuter',
                onStart: () {},
              ),
              const SizedBox(height: 16),
              _ExamCard.inProgress(
                title: 'Fullständigt prov 2',
                answeredCount: 20,
                totalCount: 65,
                timeLeft: '35 minuter kvar',
                onContinue: () {},
              ),
              const SizedBox(height: 16),
              _ExamCard.passed(
                title: 'Fullständigt prov 3',
                totalCount: 65,
                correctCount: 58,
                percentage: 89,
                onViewResults: () {},
              ),
              const SizedBox(height: 16),
              _ExamCard.failed(
                title: 'Fullständigt prov 4',
                totalCount: 65,
                correctCount: 42,
                percentage: 65,
                onViewResults: () {},
                onRetry: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, icon: Icons.home_rounded, label: 'Hem', isSelected: false, route: '/taxi-dashboard'),
              _navItem(context, icon: Icons.map_outlined, label: 'Karta', isSelected: false, route: '/taxi-karta'),
              _navItem(context, icon: Icons.verified_user_outlined, label: 'Säkerhet', isSelected: false, route: '/taxi-sakerhet'),
              _navItem(context, icon: Icons.gavel_outlined, label: 'Lagar', isSelected: false, route: '/taxi-lagstiftning'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!isSelected) context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          constraints: const BoxConstraints(minWidth: 64),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
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

// ─── Exam card widget ────────────────────────────────────────

enum _ExamStatus { newExam, inProgress, passed, failed }

class _ExamCard extends StatelessWidget {
  const _ExamCard._({
    required this.title,
    required this.status,
    this.questionCount,
    this.duration,
    this.answeredCount,
    this.totalCount,
    this.timeLeft,
    this.correctCount,
    this.percentage,
    this.onStart,
    this.onContinue,
    this.onViewResults,
    this.onRetry,
  });

  factory _ExamCard.newExam({
    required String title,
    required int questionCount,
    required String duration,
    required VoidCallback onStart,
  }) {
    return _ExamCard._(
      title: title,
      status: _ExamStatus.newExam,
      questionCount: questionCount,
      duration: duration,
      totalCount: questionCount,
      onStart: onStart,
    );
  }

  factory _ExamCard.inProgress({
    required String title,
    required int answeredCount,
    required int totalCount,
    required String timeLeft,
    required VoidCallback onContinue,
  }) {
    return _ExamCard._(
      title: title,
      status: _ExamStatus.inProgress,
      answeredCount: answeredCount,
      totalCount: totalCount,
      timeLeft: timeLeft,
      onContinue: onContinue,
    );
  }

  factory _ExamCard.passed({
    required String title,
    required int totalCount,
    required int correctCount,
    required int percentage,
    required VoidCallback onViewResults,
  }) {
    return _ExamCard._(
      title: title,
      status: _ExamStatus.passed,
      totalCount: totalCount,
      correctCount: correctCount,
      percentage: percentage,
      onViewResults: onViewResults,
    );
  }

  factory _ExamCard.failed({
    required String title,
    required int totalCount,
    required int correctCount,
    required int percentage,
    required VoidCallback onViewResults,
    required VoidCallback onRetry,
  }) {
    return _ExamCard._(
      title: title,
      status: _ExamStatus.failed,
      totalCount: totalCount,
      correctCount: correctCount,
      percentage: percentage,
      onViewResults: onViewResults,
      onRetry: onRetry,
    );
  }

  final String title;
  final _ExamStatus status;
  final int? questionCount;
  final String? duration;
  final int? answeredCount;
  final int? totalCount;
  final String? timeLeft;
  final int? correctCount;
  final int? percentage;
  final VoidCallback? onStart;
  final VoidCallback? onContinue;
  final VoidCallback? onViewResults;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          if (status == _ExamStatus.inProgress)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                color: AppColors.surfaceVariant,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: totalCount != null && totalCount! > 0
                      ? (answeredCount ?? 0) / totalCount!
                      : 0,
                  child: Container(color: AppColors.secondary),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              status == _ExamStatus.inProgress ? 28 : 24,
              24,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.publicSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildInfoRows(),
                if (status == _ExamStatus.passed || status == _ExamStatus.failed) ...[
                  const SizedBox(height: 12),
                  _buildResultBox(),
                ],
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    Color bg;
    Color fg;
    String text;
    switch (status) {
      case _ExamStatus.newExam:
        bg = AppColors.primaryContainer;
        fg = AppColors.onPrimaryContainer;
        text = 'Nytt prov';
      case _ExamStatus.inProgress:
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        text = 'Påbörjat';
      case _ExamStatus.passed:
      case _ExamStatus.failed:
        bg = AppColors.surfaceVariant;
        fg = AppColors.onSurfaceVariant;
        text = 'Avslutat';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: fg,
        ),
      ),
    );
  }

  List<Widget> _buildInfoRows() {
    final rows = <Widget>[];
    final style = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: AppColors.onSurfaceVariant,
    );
    const iconColor = AppColors.onSurfaceVariant;

    switch (status) {
      case _ExamStatus.newExam:
        rows.add(_infoRow(Icons.format_list_bulleted_rounded, '${questionCount ?? 65} frågor', style, iconColor));
        rows.add(const SizedBox(height: 8));
        rows.add(_infoRow(Icons.timer_outlined, duration ?? '50 minuter', style, iconColor));
        rows.add(const SizedBox(height: 8));
        rows.add(_infoRow(Icons.category_outlined, 'Alla kategorier', style, iconColor));
      case _ExamStatus.inProgress:
        rows.add(_infoRow(Icons.format_list_bulleted_rounded, '$answeredCount av $totalCount frågor besvarade', style, iconColor));
        rows.add(const SizedBox(height: 8));
        rows.add(_infoRow(Icons.timer_outlined, timeLeft ?? '', style, iconColor));
      case _ExamStatus.passed:
      case _ExamStatus.failed:
        rows.add(_infoRow(Icons.format_list_bulleted_rounded, '$totalCount frågor', style, iconColor));
    }
    return rows;
  }

  Widget _infoRow(IconData icon, String text, TextStyle style, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }

  Widget _buildResultBox() {
    final isPassed = status == _ExamStatus.passed;
    final borderColor = isPassed ? AppColors.success : AppColors.error;
    final scoreColor = isPassed ? AppColors.success : AppColors.error;
    final statusText = isPassed ? 'Godkänt ($percentage%)' : 'Ej Godkänt ($percentage%)';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultat',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.02 * 14,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '$correctCount/$totalCount',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 32 / 24,
                  letterSpacing: -0.01 * 24,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    switch (status) {
      case _ExamStatus.newExam:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Starta Prov',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.02 * 14,
              ),
            ),
          ),
        );
      case _ExamStatus.inProgress:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Fortsätt Prov',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.02 * 14,
              ),
            ),
          ),
        );
      case _ExamStatus.passed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onViewResults,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.onSurface,
              side: const BorderSide(color: AppColors.outline),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Se resultat',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.02 * 14,
              ),
            ),
          ),
        );
      case _ExamStatus.failed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onViewResults,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainer,
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outline),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Se resultat',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.02 * 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Gör om',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.02 * 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );
    }
  }
}
