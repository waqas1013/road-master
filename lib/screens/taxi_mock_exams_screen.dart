import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/taxi_entitlement_service.dart';
import '../theme/app_colors.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

Future<void> tryStartTaxiSlutprov(BuildContext context, int part) async {
  final svc = TaxiEntitlementService.instance;
  if (!svc.isLoggedIn) {
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

/// Stitch node: 67289e7bf089418095478a91e53cf243
class TaxiMockExamsScreen extends StatelessWidget {
  const TaxiMockExamsScreen({super.key});

  static const _introBody =
      'Simulera det riktiga provet hos Trafikverket.\nDu måste klara båda delproven för att få ditt taxiförarlegitimation.';

  static const _infoTitle = 'Om Slutprovet';
  static const _infoBody =
      'Proven genereras dynamiskt från en stor frågebank med nya frågor varje gång, vilket ger dig bättre förberedelse inför det verkliga provet.';

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
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: AppColors.primaryContainer,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/taxi-dashboard');
            }
          },
        ),
        title: Text(
          'Taxi Teoriprov',
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Slutprov',
                style: GoogleFonts.publicSans(
                  fontSize: 48 / 2,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _introBody,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _InfoCard(title: _infoTitle, body: _infoBody),
              const SizedBox(height: 18),
              _ExamCard(
                title: 'Delprov 1',
                subtitle: 'Kartläsning & Säkerhet',
                icon: Icons.directions_car_filled_outlined,
                iconColor: const Color(0xFF2F6DB5),
                iconBackground: const Color(0xFFDCE9FF),
                statTime: '50 minuter',
                statQuestions: '70 frågor (65 p)',
                statPass: 'Krav: 48 rätt',
                onTap: () => tryStartTaxiSlutprov(context, 1),
              ),
              const SizedBox(height: 14),
              _ExamCard(
                title: 'Delprov 2',
                subtitle: 'Lagstiftning & Regler',
                icon: Icons.gavel_rounded,
                iconColor: const Color(0xFF9146CE),
                iconBackground: const Color(0xFFF1E4FF),
                statTime: '50 minuter',
                statQuestions: '50 frågor (46 p)',
                statPass: 'Krav: 34 rätt',
                onTap: () => tryStartTaxiSlutprov(context, 2),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TaxiShellBottomNav(
        selectedRoute: '/taxi-mock-exams',
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC0D6F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 24,
            color: AppColors.primaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.publicSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.statTime,
    required this.statQuestions,
    required this.statPass,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String statTime;
  final String statQuestions;
  final String statPass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.publicSans(
                            fontSize: 36 / 2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 30 / 2,
                            fontWeight: FontWeight.w400,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 28,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InlineStat(
                      icon: Icons.access_time_rounded,
                      text: statTime,
                    ),
                  ),
                  Expanded(
                    child: _InlineStat(
                      icon: Icons.format_list_bulleted_rounded,
                      text: statQuestions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _InlineStat(icon: Icons.military_tech_outlined, text: statPass),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 28 / 2,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
