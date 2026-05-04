import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF003B6A);
  static const Color primaryContainer = Color(0xFF005291);
  static const Color primaryLight = Color(0xFFD3E4FF);
  /// Stitch `primary-fixed-dim` (CTA borders / accents).
  static const Color primaryFixedDim = Color(0xFFA2C9FF);
  /// Stitch `on-primary-fixed` / `on-primary-fixed-variant` (text on primary-fixed surfaces).
  static const Color onPrimaryFixed = Color(0xFF001C38);
  static const Color onPrimaryFixedVariant = Color(0xFF004881);

  // Secondary
  static const Color secondary = Color(0xFF3F627E);
  static const Color secondaryContainer = Color(0xFFBADEFF);
  /// Progress fill on readiness card / secondary-fixed from design tokens.
  static const Color secondaryFixed = Color(0xFFCBE6FF);

  // Tertiary
  static const Color tertiary = Color(0xFF313B42);
  static const Color tertiaryContainer = Color(0xFF485259);
  static const Color tertiaryFixed = Color(0xFFDAE4ED);
  static const Color onTertiaryFixed = Color(0xFF131D23);

  // Extra semantic on-colors
  static const Color onSecondaryFixed = Color(0xFF001E30);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color surfaceTint = Color(0xFF1F60A0);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFBF9F8);
  static const Color surface = Color(0xFFFBF9F8);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E2);
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  /// Surface variant / borders (matches Stitch `surface-variant`).
  static const Color surfaceVariant = Color(0xFFE4E2E2);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldLight = Color(0xFFF8F9FA);

  // On-colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF9BC6FF);
  static const Color onSecondaryContainer = Color(0xFF3F637E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1B1C1C);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF424750);
  static const Color outline = Color(0xFF727781);
  static const Color outlineVariant = Color(0xFFC2C7D2);

  // Semantic colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);

  // Badge / chip colors
  static const Color chipBlue = Color(0xFFE3F2FD);
  static const Color chipBlueText = Color(0xFF1565C0);

  // Progress bar colors
  static const Color progressGreen = Color(0xFF4CAF50);
  static const Color progressRed = Color(0xFFE53935);
  static const Color progressYellow = Color(0xFFFFC107);
  static const Color progressBlue = Color(0xFF2196F3);
}

/// Studiekategorier bento on taxi Hem — Stitch `3360ae7c248249269ae0659c37508139` (blue / green / purple / orange).
class TaxiHemBentoStyle {
  const TaxiHemBentoStyle({
    required this.cardBackground,
    required this.border,
    required this.iconBackground,
    required this.iconForeground,
    required this.percentText,
    required this.trackBackground,
    required this.progressColor,
  });

  final Color cardBackground;
  final Color border;
  final Color iconBackground;
  final Color iconForeground;
  final Color percentText;
  final Color trackBackground;
  final Color progressColor;

  static const sakerhet = TaxiHemBentoStyle(
    cardBackground: Color(0xFFF5FAFE),
    border: Color(0xFFDBEAFE),
    iconBackground: Color(0xFFDBEAFE),
    iconForeground: Color(0xFF1D4ED8),
    percentText: Color(0xFF1E40AF),
    trackBackground: Color(0x80DBEAFE),
    progressColor: Color(0xFF2563EB),
  );

  static const karta = TaxiHemBentoStyle(
    cardBackground: Color(0xFFF4FCF7),
    border: Color(0xFFDCFCE7),
    iconBackground: Color(0xFFDCFCE7),
    iconForeground: Color(0xFF15803D),
    percentText: Color(0xFF166534),
    trackBackground: Color(0x80DCFCE7),
    progressColor: Color(0xFF16A34A),
  );

  static const lagstiftning = TaxiHemBentoStyle(
    cardBackground: Color(0xFFF9F5FF),
    border: Color(0xFFF3E8FF),
    iconBackground: Color(0xFFF3E8FF),
    iconForeground: Color(0xFF7E22CE),
    percentText: Color(0xFF6B21A8),
    trackBackground: Color(0x80F3E8FF),
    progressColor: Color(0xFF9333EA),
  );

  static const vagmarken = TaxiHemBentoStyle(
    cardBackground: Color(0xFFFFFBF5),
    border: Color(0xFFFFEDD5),
    iconBackground: Color(0xFFFFEDD5),
    iconForeground: Color(0xFFC2410C),
    percentText: Color(0xFF9A3412),
    trackBackground: Color(0x80FFEDD5),
    progressColor: Color(0xFFEA580C),
  );
}
