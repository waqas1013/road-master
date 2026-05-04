import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_sakerhet_practice_sets.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../data/taxi_karta_practice_sets.dart';
import '../services/sakerhet_practice_repository.dart';
import '../services/lagar_practice_repository.dart';
import '../services/karta_practice_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';

class TaxiDashboardScreen extends StatefulWidget {
  const TaxiDashboardScreen({super.key});

  @override
  State<TaxiDashboardScreen> createState() => _TaxiDashboardScreenState();
}

class _TaxiDashboardScreenState extends State<TaxiDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        shape: const Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 24, color: AppColors.primaryContainer),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Taxi Teori',
          style: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.02 * 20,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => context.push('/category-selection'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car_rounded, size: 20, color: AppColors.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'B',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02 * 14,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.onSecondaryContainer),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Heading ───
              Text(
                'Din taxikurs',
                style: GoogleFonts.publicSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 40 / 32,
                  letterSpacing: -0.02 * 32,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Välj en modul nedan för att starta din teoriträning för taxilegitimation.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // ─── Module 1: Säkerhet & Beteende ───
              _buildModuleCard(
                moduleNumber: 1,
                icon: Icons.verified_user_rounded,
                iconBg: AppColors.secondaryFixed,
                iconColor: AppColors.onSecondaryFixed,
                title: 'Säkerhet & Beteende',
                description: 'Grundläggande säkerhetsrutiner och professionellt bemötande som taxiförare.',
                progress: _sakerhetProgress(),
                onTap: () => context.push('/taxi-sakerhet'),
              ),
              const SizedBox(height: 16),
              // ─── Module 2: Karta ───
              _buildModuleCard(
                moduleNumber: 2,
                icon: Icons.map_rounded,
                iconBg: AppColors.tertiaryFixed,
                iconColor: AppColors.onTertiaryFixed,
                title: 'Karta',
                description: 'Kartläsning, navigering och lokalkännedom för effektiva resor.',
                progress: _kartaProgress(),
                onTap: () => context.push('/taxi-karta'),
              ),
              const SizedBox(height: 16),
              // ─── Module 3: Lagstiftning ───
              _buildModuleCard(
                moduleNumber: 3,
                icon: Icons.gavel_rounded,
                iconBg: AppColors.errorContainer,
                iconColor: AppColors.onErrorContainer,
                title: 'Lagstiftning',
                description: 'Lagar, regler och förordningar som styr taxiverksamhet i Sverige.',
                progress: _lagarProgress(),
                onTap: () => context.push('/taxi-lagstiftning'),
              ),
              const SizedBox(height: 16),
              // ─── Module 4: Vägmärken (coming soon) ───
              _buildModuleCard(
                moduleNumber: 4,
                icon: Icons.traffic_rounded,
                iconBg: AppColors.primaryContainer,
                iconColor: AppColors.onPrimaryContainer,
                title: 'Vägmärken',
                description: 'Fördjupad kunskap om vägmärken och trafiksignaler för yrkesförare.',
                progress: 0.0,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              // ─── Slutprov card ───
              _buildSlutprovCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── Progress helpers ──────────────────────────────────────

  double _sakerhetProgress() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kSakerhetPracticeSetCount; i++) {
      totalQ += sakerhetPracticeSetSize(i);
      final p = SakerhetPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  double _lagarProgress() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kLagstiftningPracticeSetCount; i++) {
      totalQ += lagstiftningPracticeSetSize(i);
      final p = LagarPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  double _kartaProgress() {
    var totalQ = 0;
    var answered = 0;
    for (var i = 1; i <= kKartaPracticeSetCount; i++) {
      totalQ += kartaPracticeSetSize(i);
      final p = KartaPracticeRepository.instance.load(i);
      if (p != null) answered += p.totalAnswered;
    }
    return totalQ > 0 ? answered / totalQ : 0;
  }

  // ─── Module card ───────────────────────────────────────────

  Widget _buildModuleCard({
    required int moduleNumber,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required double progress,
    required VoidCallback onTap,
  }) {
    final pct = (progress * 100).round();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Modul $moduleNumber',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                description,
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
                    'Framsteg',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$pct%',
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
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                clipBehavior: Clip.antiAlias,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Slutprov card ─────────────────────────────────────────

  Widget _buildSlutprovCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/taxi-mock-exams'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.surfaceTint],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                right: -32,
                top: -32,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                left: -32,
                bottom: -32,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school_rounded, size: 24, color: AppColors.onPrimary),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Slutprov',
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Redo för testet?',
                    style: GoogleFonts.publicSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 32 / 24,
                      letterSpacing: -0.01 * 24,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ett simulerat teoriprov med 70 frågor för taxilegitimation. Provet efterliknar Trafikverkets riktiga test.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                      color: AppColors.onPrimary.withValues(alpha: 0.90),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/taxi-mock-exams'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        foregroundColor: AppColors.primary,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Starta Slutprov',
                        style: GoogleFonts.publicSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          letterSpacing: 0.02 * 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom nav ────────────────────────────────────────────

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
              _navItem(context, icon: Icons.home_rounded, label: 'Hem', isSelected: true, route: '/taxi-dashboard'),
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
