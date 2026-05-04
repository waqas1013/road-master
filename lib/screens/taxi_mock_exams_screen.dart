import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/taxi_entitlement_service.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

Future<void> tryStartTaxiSlutprov(BuildContext context, int part) async {
  final svc = TaxiEntitlementService.instance;
  if (!svc.isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logga in för att starta slutprov.')),
    );
    await context.push('/login');
    return;
  }
  if (!await svc.hasActiveTaxiSubscription()) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Du behöver en aktiv prenumeration för att starta slutprov. Köp tillgång på vår webbplats.',
        ),
      ),
    );
    return;
  }
  if (!context.mounted) return;
  await context.push('/taxi-mock-exam?part=$part');
}

/// Stitch screen: **Mock Exams - Dynamic Question Bank Info**.
class TaxiMockExamsScreen extends StatelessWidget {
  const TaxiMockExamsScreen({super.key});

  static const _introBody =
      'Dessa övningsprov simulerar det officiella kunskapsprovet för taxiförarlegitimation (TFL) hos Trafikverket. Du måste vara godkänd på båda delproven för att få utföra taxitrafik.';

  static const _infoBoxBody =
      'Prov genereras dynamiskt från en stor frågebank med nya frågor varje gång, vilket ger dig bättre förberedelse inför det verkliga provet.';

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/taxi-dashboard');
            }
          },
        ),
        title: Text(
          'Mock Exams',
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
                'Slutprov Taxi',
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
                _introBody,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _InfoTipCard(body: _infoBoxBody),
              const SizedBox(height: 24),
              _DelprovCard(
                title: 'Delprov 1: Säkerhet och beteende',
                subtitle: 'Kunskap om fordon, passagerare och säkerhet.',
                headerIcon: Icons.shield_rounded,
                statQuestions: '70 Frågor (65 p)',
                statPass: '48 Krav för godkänt',
                statTime: '50 Minuter',
                topics: const [
                  'GPS/Karta',
                  'Körekonomi',
                  'Säkerhet',
                  'Bemötande',
                  'Fordonskännedom',
                ],
                onStart: () => tryStartTaxiSlutprov(context, 1),
              ),
              const SizedBox(height: 16),
              _DelprovCard(
                title: 'Delprov 2: Lagstiftning',
                subtitle: 'Regelverk för taxitrafik och allmänna trafikregler.',
                headerIcon: Icons.gavel_rounded,
                statQuestions: '50 Frågor (46 p)',
                statPass: '34 Krav för godkänt',
                statTime: '50 Minuter',
                topics: const [
                  'Taxitrafik regler',
                  'Trafikregler',
                  'Vägmärken',
                ],
                onStart: () => tryStartTaxiSlutprov(context, 2),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TaxiShellBottomNav(selectedRoute: '/taxi-mock-exams'),
    );
  }
}

class _InfoTipCard extends StatelessWidget {
  const _InfoTipCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, size: 24, color: AppColors.primaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              body,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DelprovCard extends StatelessWidget {
  const _DelprovCard({
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    required this.statQuestions,
    required this.statPass,
    required this.statTime,
    required this.topics,
    required this.onStart,
  });

  final String title;
  final String subtitle;
  final IconData headerIcon;
  final String statQuestions;
  final String statPass;
  final String statTime;
  final List<String> topics;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.publicSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(headerIcon, size: 24, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatSegment(
                      icon: Icons.article_outlined,
                      line: statQuestions,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _StatSegment(
                      icon: Icons.check_circle_outline_rounded,
                      line: statPass,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: _StatSegment(
                      icon: Icons.timer_outlined,
                      line: statTime,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Innehåller ämnen:',
              style: GoogleFonts.publicSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.02 * 14,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        t,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Starta Prov',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 0.02 * 14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_arrow_rounded, size: 22, color: AppColors.onPrimary),
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

class _StatSegment extends StatelessWidget {
  const _StatSegment({
    required this.icon,
    required this.line,
  });

  final IconData icon;
  final String line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            line,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
