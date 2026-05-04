import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Stitch **Welcome & Onboarding** — layout + colors from exported HTML; road image from Stitch CDN URL bundled as asset.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  /// Background crop from Stitch HTML (`background-image` on the 65% hero layer).
  static const _stitchRoadAsset = 'assets/images/onboarding_stitch_road.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final heroHeight = size.height * 0.65;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: top 65% road (Stitch asset), seamless blend via overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: Image.asset(
              _stitchRoadAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryLight.withValues(alpha: 0.4),
              ),
            ),
          ),
          // Stitch: `bg-gradient-to-b from-surface/10 via-surface/80 to-surface`
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Color.lerp(Colors.transparent, AppColors.surface, 0.1)!,
                    Color.lerp(Colors.transparent, AppColors.surface, 0.8)!,
                    AppColors.surface,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top: branding (flex, centered vertically)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // `w-24 h-24 bg-primary-container` + school icon `text-on-primary-container`
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: 48,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Trust badge: `bg-secondary-container text-on-secondary-container` + verified
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.onSecondaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sveriges smartaste teori',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom: headline, body, actions (Stitch `gap-md pb-md`)
                  Text(
                    'Din väg till körkortet börjar här',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.publicSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.64,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Vi hjälper dig att förstå trafikreglerna och klara teoriprovet '
                      'med bravur. Få tillgång till allt du behöver på ett ställe.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/category-selection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Börja nu',
                            style: GoogleFonts.publicSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () => context.push('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        'Jag har redan ett konto',
                        style: GoogleFonts.publicSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 + bottomInset),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
