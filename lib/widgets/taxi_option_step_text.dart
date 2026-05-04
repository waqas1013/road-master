import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Splits option copy into readable lines (matches web-style step-by-step clarity).
List<String> linesForOptionText(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return [];

  if (t.contains('\n')) {
    return t.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  // "... 1. Första steget 2. Andra steget"
  final numbered = t.split(RegExp(r'\s(?=\d+\.\s)'));
  if (numbered.length > 1) {
    return numbered.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  // Clauses separated by semicolon — common in long Swedish answers.
  if (t.contains(';')) {
    final parts = t.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length > 1) return parts;
  }

  return [t];
}

bool _alreadyNumbered(String line) => RegExp(r'^\d+[\.\)]\s').hasMatch(line.trim());

/// Visual: one block per step, comfortable line height, optional auto-numbers when missing.
class TaxiOptionStepText extends StatelessWidget {
  const TaxiOptionStepText({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final lines = linesForOptionText(text);

    if (lines.length == 1) {
      return Text(
        lines.first,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 26 / 16,
          letterSpacing: 0.1,
          color: color,
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: 10));
      }
      final line = lines[i];
      final hasNum = _alreadyNumbered(line);

      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasNum) ...[
              SizedBox(
                width: 24,
                child: Text(
                  '${i + 1}.',
                  style: GoogleFonts.publicSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 26 / 15,
                    color: AppColors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  line,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 26 / 16,
                    letterSpacing: 0.1,
                    color: color,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  line,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 26 / 16,
                    letterSpacing: 0.1,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
