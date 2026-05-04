import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../models/taxi_practice_question.dart';
import '../services/lagar_practice_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';
import '../router/taxi_question_transition.dart';

enum _QuestionCellState {
  current,
  answeredCorrect,
  answeredWrong,
  bookmarked,
  upcoming,
  skippedAuto,
  locked,
}

class TaxiLagarContinuePracticeScreen extends StatefulWidget {
  const TaxiLagarContinuePracticeScreen({super.key, required this.practiceSet});

  final int practiceSet;

  @override
  State<TaxiLagarContinuePracticeScreen> createState() => _TaxiLagarContinuePracticeScreenState();
}

class _TaxiLagarContinuePracticeScreenState extends State<TaxiLagarContinuePracticeScreen> {
  var _restarting = false;

  int get practiceSet => widget.practiceSet;

  Future<void> _confirmRestart() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Starta om setet?',
          style: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'All sparad framsteg för detta paket raderas och du börjar om från fråga 1.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Avbryt', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Starta om', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;

    setState(() => _restarting = true);
    await LagarPracticeRepository.instance.clear(practiceSet);
    if (!mounted) return;
    context.pushReplacement(
      taxiQuestionUriWithTx(
        '/taxi-question?module=lagstiftning&practiceSet=$practiceSet&q=1',
        TaxiQuestionTransition.forward,
      ),
      extra: TaxiQuestionTransition.forward,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LagarPracticeRepository.instance.progressRevision,
      builder: (context, _, __) {
        if (_restarting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final total = lagstiftningPracticeSetSize(practiceSet);
        final partition = lagstiftningPracticeQuestions(practiceSet);
        final progress = LagarPracticeRepository.instance.load(practiceSet);

        if (total == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/taxi-lagstiftning');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (progress?.completed == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/taxi-lagstiftning');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (progress == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.cardBackground,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: AppColors.primaryContainer),
                onPressed: () => context.go('/taxi-lagstiftning'),
              ),
              title: Text(
                'Taxi Teori',
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Inget pågående övning hittades för detta paket.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go('/taxi-lagstiftning'),
                      child: Text('Till övningspaket', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final nq = progress.nextQuestionIndex.clamp(1, total);
        final answered = progress.answers.length;
        final progressFraction = (answered / total).clamp(0.0, 1.0);
        final pctLabel = '${(progressFraction * 100).round()}%';
        final summaryLine = _setSummaryLine(partition);
        final themeLine = _dominantThemeLabel(partition);

        final resumeUri = taxiQuestionUriWithTx(
          '/taxi-question?module=lagstiftning&practiceSet=$practiceSet&q=$nq',
          TaxiQuestionTransition.forward,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
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
              'Taxi Teori',
              style: GoogleFonts.publicSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
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
                  const SizedBox(height: 20),
                  Text(
                    'Fortsätt öva',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.02,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set $practiceSet',
                    style: GoogleFonts.publicSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    themeLine,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _welcomeCard(
                    context,
                    resumeUri: resumeUri,
                    onRestart: _confirmRestart,
                    nq: nq,
                    total: total,
                    answered: answered,
                    progressFraction: progressFraction,
                    pctLabel: pctLabel,
                  ),
                  const SizedBox(height: 24),
                  _summaryCard(total: total, summaryLine: summaryLine),
                  const SizedBox(height: 28),
                  Text(
                    'Frågor i detta set',
                    style: GoogleFonts.publicSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tryck på en upplåst ruta för att öppna frågan. Låsta frågor låser upp när du övar dig framåt.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _questionGridSection(
                    total: total,
                    unlockedThrough: progress.visitedThrough.clamp(1, total),
                    nextQuestion: nq,
                    answersByQuestionId: progress.answers,
                    bookmarks: progress.bookmarks,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const TaxiShellBottomNav(),
        );
      },
    );
  }

  static String _dominantThemeLabel(List<TaxiPracticeQuestion> partition) {
    if (partition.isEmpty) return 'Övningsfrågor — taxi lagstiftning';
    final counts = <String, int>{};
    for (final q in partition) {
      final t = q.categoryTag.trim();
      if (t.isEmpty) continue;
      counts[t] = (counts[t] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'Övningsfrågor — taxi lagstiftning';
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  static String _setSummaryLine(List<TaxiPracticeQuestion> partition) {
    if (partition.isEmpty) {
      return 'När du fortsätter övar du i det här paketet.';
    }
    return 'Det här paketet följer samma övningsblock som i teoriprovet. '
        'Du kan pausa när som helst — vi sparar var du var.';
  }

  Widget _welcomeCard(
    BuildContext context, {
    required int nq,
    required int total,
    required int answered,
    required double progressFraction,
    required String pctLabel,
    required String resumeUri,
    required VoidCallback onRestart,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.waving_hand_rounded, size: 22, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Välkommen tillbaka',
                      style: GoogleFonts.publicSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.55,
                    ),
                    children: [
                      const TextSpan(text: 'Du är på '),
                      TextSpan(
                        text: 'fråga $nq av $total',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                      ),
                      TextSpan(
                        text: answered > 0
                            ? '. Du har kontrollerat $answered svar hittills.'
                            : '. Fortsätt när du är redo, eller starta om setet nedan.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Framsteg',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      pctLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressFraction.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Icon(Icons.play_circle_fill_rounded, size: 42, color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => context.push(
                      resumeUri,
                      extra: TaxiQuestionTransition.forward,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D325E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fortsätt övningen',
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: Icon(Icons.refresh_rounded, size: 20, color: Colors.white.withValues(alpha: 0.95)),
                    label: Text(
                      'Starta om setet',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.65)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({required int total, required String summaryLine}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Sammanfattning av setet',
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
            summaryLine,
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
              _chip('Lagstiftning'),
              _chip('Taxi teori'),
              _chip('$total frågor'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _questionGridSection({
    required int total,
    required int unlockedThrough,
    required int nextQuestion,
    required Map<String, int> answersByQuestionId,
    required Set<String> bookmarks,
  }) {
    final partition = lagstiftningPracticeQuestions(practiceSet);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionStatusLegend(),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemCount: total,
            itemBuilder: (context, index) {
              final i = index + 1;
              final id = i <= partition.length ? partition[i - 1].id : '';
              final correctIdx = id.isNotEmpty ? partition[i - 1].correctOptionIndex : null;
              final selected = id.isNotEmpty ? answersByQuestionId[id] : null;
              final hasAnswer = selected != null;
              final isCurrent = i == nextQuestion;
              final isFuture = i > nextQuestion;
              final isSaved = id.isNotEmpty && bookmarks.contains(id);

              final uri = taxiQuestionUriWithTx(
                '/taxi-question?module=lagstiftning&practiceSet=$practiceSet&q=$i',
                i >= nextQuestion
                    ? TaxiQuestionTransition.forward
                    : TaxiQuestionTransition.backward,
              );
              void openQuestion() => context.push(
                    uri,
                    extra: i >= nextQuestion
                        ? TaxiQuestionTransition.forward
                        : TaxiQuestionTransition.backward,
                  );

              if (i > unlockedThrough) {
                return _gridCell(
                  label: '$i',
                  state: _QuestionCellState.locked,
                  bookmarkBadge: false,
                  semanticLabel: 'Fråga $i, låst',
                  onTap: null,
                );
              }

              if (hasAnswer && correctIdx != null) {
                final correct = selected == correctIdx;
                return _gridCell(
                  label: '$i',
                  state: correct ? _QuestionCellState.answeredCorrect : _QuestionCellState.answeredWrong,
                  bookmarkBadge: isSaved,
                  semanticLabel: correct ? 'Fråga $i, rätt svar' : 'Fråga $i, fel svar',
                  onTap: openQuestion,
                );
              }
              if (hasAnswer) {
                return _gridCell(
                  label: '$i',
                  state: _QuestionCellState.answeredCorrect,
                  bookmarkBadge: isSaved,
                  semanticLabel: 'Fråga $i',
                  onTap: openQuestion,
                );
              }
              if (isCurrent) {
                return _gridCell(
                  label: '$i',
                  state: _QuestionCellState.current,
                  bookmarkBadge: isSaved,
                  semanticLabel: 'Fråga $i, aktuell',
                  onTap: openQuestion,
                );
              }
              if (isSaved) {
                return _gridCell(
                  label: '$i',
                  state: _QuestionCellState.bookmarked,
                  bookmarkBadge: false,
                  semanticLabel: 'Fråga $i, sparad',
                  onTap: openQuestion,
                );
              }
              if (isFuture) {
                return _gridCell(
                  label: '$i',
                  state: _QuestionCellState.upcoming,
                  bookmarkBadge: false,
                  semanticLabel: 'Fråga $i',
                  onTap: openQuestion,
                );
              }
              return _gridCell(
                label: '$i',
                state: _QuestionCellState.skippedAuto,
                bookmarkBadge: false,
                semanticLabel: 'Fråga $i, ej besvarad',
                onTap: openQuestion,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _questionStatusLegend() {
    TextStyle caption(Color color) => GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.2,
        );

    Widget entry(IconData icon, Color iconColor, String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(text, style: caption(AppColors.onSurfaceVariant)),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          entry(Icons.check_circle_rounded, AppColors.success, 'Rätt'),
          entry(Icons.cancel_rounded, AppColors.error, 'Fel'),
          entry(Icons.bookmark_rounded, AppColors.secondary, 'Sparad'),
          entry(Icons.play_circle_fill_rounded, AppColors.primary, 'Aktuell'),
          entry(Icons.lock_outline_rounded, AppColors.onSurfaceVariant, 'Låst'),
        ],
      ),
    );
  }

  Widget _gridCell({
    required String label,
    required _QuestionCellState state,
    required bool bookmarkBadge,
    required VoidCallback? onTap,
    required String semanticLabel,
  }) {
    Color bg = AppColors.cardBackground;
    Color border = AppColors.outlineVariant.withValues(alpha: 0.45);
    Color fg = AppColors.onBackground;
    List<BoxShadow>? shadow;
    Widget? cornerIcon;
    Color splash;
    Color highlight;

    switch (state) {
      case _QuestionCellState.current:
        bg = AppColors.primary;
        border = AppColors.primary;
        fg = Colors.white;
        splash = Colors.white30;
        highlight = Colors.white12;
        shadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
        cornerIcon = const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white);
      case _QuestionCellState.answeredCorrect:
        bg = AppColors.successLight.withValues(alpha: 0.95);
        border = AppColors.success.withValues(alpha: 0.5);
        fg = AppColors.onBackground;
        splash = AppColors.success.withValues(alpha: 0.2);
        highlight = AppColors.success.withValues(alpha: 0.08);
        cornerIcon = Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success);
      case _QuestionCellState.answeredWrong:
        bg = AppColors.errorContainer.withValues(alpha: 0.75);
        border = AppColors.error.withValues(alpha: 0.4);
        fg = AppColors.onBackground;
        splash = AppColors.error.withValues(alpha: 0.2);
        highlight = AppColors.error.withValues(alpha: 0.08);
        cornerIcon = Icon(Icons.cancel_rounded, size: 13, color: AppColors.error);
      case _QuestionCellState.bookmarked:
        bg = AppColors.secondaryContainer.withValues(alpha: 0.45);
        border = AppColors.secondary.withValues(alpha: 0.35);
        fg = AppColors.onBackground;
        splash = AppColors.secondary.withValues(alpha: 0.22);
        highlight = AppColors.secondary.withValues(alpha: 0.1);
        cornerIcon = Icon(Icons.bookmark_rounded, size: 13, color: AppColors.secondary);
      case _QuestionCellState.upcoming:
        bg = AppColors.surfaceContainerLow;
        border = AppColors.outlineVariant.withValues(alpha: 0.2);
        fg = AppColors.onSurfaceVariant.withValues(alpha: 0.62);
        splash = AppColors.primary.withValues(alpha: 0.1);
        highlight = AppColors.primary.withValues(alpha: 0.05);
      case _QuestionCellState.skippedAuto:
        bg = AppColors.surfaceContainerHigh.withValues(alpha: 0.65);
        border = AppColors.outlineVariant.withValues(alpha: 0.35);
        fg = AppColors.onSurfaceVariant.withValues(alpha: 0.55);
        splash = AppColors.primary.withValues(alpha: 0.1);
        highlight = AppColors.primary.withValues(alpha: 0.05);
      case _QuestionCellState.locked:
        bg = AppColors.surfaceContainerHigh.withValues(alpha: 0.42);
        border = AppColors.outlineVariant.withValues(alpha: 0.12);
        fg = AppColors.onSurfaceVariant.withValues(alpha: 0.32);
        splash = Colors.transparent;
        highlight = Colors.transparent;
        cornerIcon = Icon(
          Icons.lock_outline_rounded,
          size: 12,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
        );
    }

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: splash,
          highlightColor: highlight,
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border),
              boxShadow: shadow,
            ),
            child: Stack(
              children: [
                if (bookmarkBadge)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Icon(
                      Icons.bookmark_rounded,
                      size: 11,
                      color: state == _QuestionCellState.current
                          ? Colors.white.withValues(alpha: 0.92)
                          : AppColors.secondary,
                    ),
                  ),
                Center(
                  child: Text(
                    label,
                    style: GoogleFonts.publicSans(
                      fontSize: 13,
                      fontWeight: state == _QuestionCellState.current ? FontWeight.w700 : FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                if (cornerIcon != null)
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: cornerIcon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
