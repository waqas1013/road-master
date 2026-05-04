import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../services/lagar_practice_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';
import '../router/taxi_question_transition.dart';

class TaxiLagstiftningScreen extends StatefulWidget {
  const TaxiLagstiftningScreen({super.key});

  @override
  State<TaxiLagstiftningScreen> createState() => _TaxiLagstiftningScreenState();
}

class _TaxiLagstiftningScreenState extends State<TaxiLagstiftningScreen> {
  late final VoidCallback _onProgressStoreChanged;

  Future<void> _afterReturn(Future<Object?>? future) async {
    await future;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _onProgressStoreChanged = () {
      if (mounted) setState(() {});
    };
    LagarPracticeRepository.instance.progressRevision.addListener(_onProgressStoreChanged);
  }

  @override
  void dispose() {
    LagarPracticeRepository.instance.progressRevision.removeListener(_onProgressStoreChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.primaryContainer),
          onPressed: () => context.go('/taxi-dashboard'),
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
              const SizedBox(height: 12),
              Text(
                'Lagstiftning',
                style: GoogleFonts.publicSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 40 / 32,
                  letterSpacing: -0.64,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Övningspaket för vilotider, taxitrafiklagen och regler som styr yrkesmässig trafik.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurfaceVariant,
                  height: 24 / 16,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondaryFixed),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 20, color: AppColors.onSecondaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Studietips',
                            style: GoogleFonts.publicSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSecondaryContainer,
                              height: 20 / 14,
                              letterSpacing: 0.28,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Läs noga igenom frågorna om kör- och vilotider. Dessa är ofta mer detaljerade och kräver exakt kunskap om reglerna.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onSecondaryContainer.withValues(alpha: 0.9),
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Övningspaket',
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  height: 28 / 20,
                ),
              ),
              const SizedBox(height: 24),
              for (var s = 1; s <= kLagstiftningPracticeSetCount; s++) ...[
                if (s > 1) const SizedBox(height: 16),
                _buildSetCard(context, s),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TaxiShellBottomNav(),
    );
  }

  Widget _buildSetCard(BuildContext context, int practiceSet) {
    final total = lagstiftningPracticeSetSize(practiceSet);
    final partition = lagstiftningPracticeQuestions(practiceSet);
    final progress = LagarPracticeRepository.instance.load(practiceSet);

    final completed = progress?.completed == true;
    final started = progress != null;
    final correctById = {for (final q in partition) q.id: q.correctOptionIndex};
    final correct = progress?.correctCount(correctById) ?? 0;
    final scoreLabel = total > 0 ? '${((correct / total) * 100).round()}%' : '';

    late final String status;
    late final String subtitleLeft;
    late final double progressValue;
    late final String buttonLabel;
    var isCurrent = false;

    if (total == 0) {
      status = 'Inga frågor';
      subtitleLeft = '';
      progressValue = 0;
      buttonLabel = 'Kommer snart';
    } else if (completed) {
      status = '$correct / $total rätt';
      subtitleLeft = 'Poäng: $scoreLabel';
      progressValue = 1;
      buttonLabel = 'Granska resultat';
    } else if (started) {
      final p = progress;
      final nq = p.nextQuestionIndex.clamp(1, total);
      status = 'Fråga $nq av $total';
      subtitleLeft = '${p.answers.length} besvarade';
      progressValue = (p.answers.length / total).clamp(0.0, 0.99);
      if (nq > 1 || p.answers.isNotEmpty) {
        isCurrent = true;
      }
      buttonLabel = 'Fortsätt öva';
    } else {
      status = 'Inte påbörjat';
      subtitleLeft = '$total frågor';
      progressValue = 0;
      buttonLabel = 'Starta set';
    }

    void onPressed() {
      if (total == 0) return;
      if (completed) {
        _afterReturn(context.push('/taxi-lagar-review?practiceSet=$practiceSet'));
        return;
      }
      if (!started) {
        _afterReturn(() async {
          await LagarPracticeRepository.instance.clear(practiceSet);
          if (!context.mounted) return;
          await context.push(
            taxiQuestionUriWithTx(
              '/taxi-question?module=lagstiftning&practiceSet=$practiceSet&q=1',
              TaxiQuestionTransition.forward,
            ),
          );
        }());
        return;
      }
      _afterReturn(
        context.push('/taxi-lagar-continue?practiceSet=$practiceSet'),
      );
    }

    final isNotStarted = !started && !completed;

    return Opacity(
      opacity: isNotStarted ? 0.80 : 1.0,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? AppColors.primary.withValues(alpha: 0.20)
                : AppColors.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isCurrent)
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: Container(width: 3, color: AppColors.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set $practiceSet',
                        style: GoogleFonts.publicSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: (completed || isCurrent)
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                      if (completed)
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                      else if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pågår',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _questionRangeLabel(practiceSet, total),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subtitleLeft,
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        status,
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progressValue.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed ? AppColors.success : AppColors.primary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: isCurrent && !completed
                        ? ElevatedButton(
                            onPressed: total == 0 ? null : onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              buttonLabel,
                              style: GoogleFonts.publicSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                letterSpacing: 0.28,
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: total == 0 ? null : onPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: completed
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                              side: BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              buttonLabel,
                              style: GoogleFonts.publicSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                letterSpacing: 0.28,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _questionRangeLabel(int practiceSet, int total) {
    if (total == 0) return 'Inga frågor ännu';
    final parts = lagstiftningPracticePartitions();
    var start = 1;
    for (var i = 0; i < practiceSet - 1 && i < parts.length; i++) {
      start += parts[i].length;
    }
    return 'Frågor $start – ${start + total - 1}';
  }

}
