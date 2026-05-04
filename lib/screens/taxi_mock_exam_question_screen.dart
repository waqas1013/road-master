import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/taxi_practice_question.dart';
import '../services/mock_exam_session.dart';
import '../services/taxi_entitlement_service.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_bank_image.dart';
import '../widgets/taxi_option_step_text.dart';

/// Timed slutprov flow — random questions from Säkerhet (Delprov 1) or Lagstiftning (Delprov 2).
class TaxiMockExamQuestionScreen extends StatefulWidget {
  const TaxiMockExamQuestionScreen({super.key, required this.part});

  final int part;

  @override
  State<TaxiMockExamQuestionScreen> createState() => _TaxiMockExamQuestionScreenState();
}

class _TaxiMockExamQuestionScreenState extends State<TaxiMockExamQuestionScreen> {
  MockExamSession? _session;
  int _index = 0;
  int _selectedOption = -1;
  bool _locked = false;
  Timer? _timer;

  TaxiPracticeQuestion? get q {
    final s = _session;
    if (s == null || _index < 0 || _index >= s.questions.length) return null;
    return s.questions[_index];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (widget.part != 1 && widget.part != 2) {
      if (mounted) context.pop();
      return;
    }
    if (!await TaxiEntitlementService.instance.canStartSlutprov()) {
      if (!mounted) return;
      final loggedIn = TaxiEntitlementService.instance.isLoggedIn;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loggedIn
                ? 'Du behöver en aktiv prenumeration för att starta slutprov.'
                : 'Logga in för att starta slutprov.',
          ),
        ),
      );
      context.pop();
      return;
    }
    if (!mounted) return;
    final session = MockExamSession.start(part: widget.part);
    if (session == null || session.questions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga frågor finns i frågebanken ännu.')),
      );
      context.pop();
      return;
    }
    setState(() {
      _session = session;
    });
    _loadSelectionForIndex();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _loadSelectionForIndex() {
    final s = _session;
    if (s == null) return;
    _selectedOption = s.answers[_index] ?? -1;
  }

  void _persistAnswer() {
    final s = _session;
    if (s == null) return;
    if (_selectedOption >= 0) {
      s.answers[_index] = _selectedOption;
    } else {
      s.answers.remove(_index);
    }
  }

  void _tick() {
    if (!mounted || _session == null || _locked) return;
    final rem = _session!.endsAt.difference(DateTime.now());
    if (rem.isNegative || rem.inSeconds == 0) {
      _handleTimeUp();
    } else {
      setState(() {});
    }
  }

  void _handleTimeUp() {
    if (_locked || !mounted) return;
    _timer?.cancel();
    _persistAnswer();
    setState(() {
      _locked = true;
      _session!.timeExpired = true;
    });
    if (!mounted) return;
    MockExamSession.prepareResults(_session!);
    unawaited(GoRouter.of(context).pushReplacement<void>('/taxi-mock-exam-results'));
  }

  Future<bool> _confirmAbandon() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Avsluta prov?', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
        content: Text(
          'Du får ett resultat baserat på det du hunnit svara på. Vill du verkligen avsluta provet?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Fortsätt')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Avsluta')),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _onBack() async {
    if (_locked) return;
    if (await _confirmAbandon()) {
      _timer?.cancel();
      _persistAnswer();
      _session!.abandonedByUser = true;
      _session!.timeExpired = false;
      if (!mounted) return;
      MockExamSession.prepareResults(_session!);
      unawaited(GoRouter.of(context).pushReplacement<void>('/taxi-mock-exam-results'));
    }
  }

  void _onPrevious() {
    if (_locked || _session == null) return;
    if (_index <= 0) {
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.lightImpact();
    _persistAnswer();
    setState(() {
      _index--;
      _loadSelectionForIndex();
    });
  }

  void _onNext() {
    if (_locked || _session == null) return;
    final s = _session!;
    final last = _index >= s.questions.length - 1;
    HapticFeedback.lightImpact();
    _persistAnswer();
    if (last) {
      _timer?.cancel();
      setState(() => _locked = true);
      MockExamSession.prepareResults(s);
      unawaited(GoRouter.of(context).pushReplacement<void>('/taxi-mock-exam-results'));
      return;
    }
    setState(() {
      _index++;
      _loadSelectionForIndex();
    });
  }

  String _formatMmSs(Duration d) {
    if (d.isNegative) return '0:00';
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:${m.padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _session;
    final question = q;
    if (s == null || question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalSec = kMockExamDurationMinutes * 60;
    final remaining = s.endsAt.difference(DateTime.now());
    final remSec = remaining.isNegative ? 0 : remaining.inSeconds;
    final progress = remSec / totalSec;

    final urgent = remSec <= 5 * 60 && remSec > 0;
    final timerColor = urgent ? AppColors.error : AppColors.primaryContainer;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBack();
      },
      child: Scaffold(
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
            onPressed: _onBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.delprovLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
              ),
              Text(
                _locked ? '0:00' : _formatMmSs(remaining),
                style: GoogleFonts.publicSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: timerColor,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  value: _locked ? 0 : progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    urgent ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: LinearProgressIndicator(
                        value: question.questionNumber / question.totalInSet,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fråga ${question.questionNumber} av ${question.totalInSet}',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.prompt,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 26 / 18,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (question.hasQuestionImage) ...[
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildQuestionImage(question),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ...List.generate(
                      question.options.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOption(question, i),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionImage(TaxiPracticeQuestion question) {
    final label = question.imageSemanticLabel ?? question.designIllustrationPrompt ?? '';
    final p = question.imageAssetPath?.trim();
    final u = question.imageNetworkUrl?.trim();
    if ((p == null || p.isEmpty) && (u == null || u.isEmpty)) {
      return ColoredBox(
        color: AppColors.surfaceContainerHigh,
        child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.outline)),
      );
    }
    return TaxiBankImage(
      assetPath: p,
      httpsUrl: u,
      fit: BoxFit.cover,
      semanticLabel: label,
    );
  }

  Widget _buildOption(TaxiPracticeQuestion question, int index) {
    final isSelected = _selectedOption == index;
    final optionText = question.options[index];

    final cardBorder = isSelected ? AppColors.primary : AppColors.outlineVariant;
    final cardBorderWidth = isSelected ? 2.0 : 1.5;
    final cardBg = isSelected ? AppColors.primaryLight.withValues(alpha: 0.28) : AppColors.surfaceContainerLow;

    final lines = linesForOptionText(optionText);
    final firstLine = lines.isNotEmpty ? lines.first : optionText;

    return Semantics(
      button: true,
      label: 'Alternativ ${index + 1}: $firstLine',
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _locked
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
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final s = _session!;
    final isFirst = _index <= 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        border: Border(top: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.8))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _locked || isFirst ? null : _onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: isFirst ? AppColors.outlineVariant : AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chevron_left_rounded, size: 20),
                    const SizedBox(width: 4),
                    Text('Föregående', style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _locked ? null : _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _index >= s.questions.length - 1 ? 'Avsluta' : 'Nästa',
                      style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _index >= s.questions.length - 1 ? Icons.check_rounded : Icons.chevron_right_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
