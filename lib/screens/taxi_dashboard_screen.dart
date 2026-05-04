import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';

/// Hem (taxi) — matches Stitch screen "Taxi License Dashboard"
/// (Tailwind tokens: background, primary-container card, module shadows, bottom nav).
class TaxiDashboardScreen extends StatefulWidget {
  const TaxiDashboardScreen({super.key});

  @override
  State<TaxiDashboardScreen> createState() => _TaxiDashboardScreenState();
}

class _TaxiDashboardScreenState extends State<TaxiDashboardScreen> {
  static const double _horizontalPadding = 20;
  static const double _sectionVerticalPadding = 24;

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
        shadowColor: Colors.black.withValues(alpha: 0.05),
        automaticallyImplyLeading: false,
        shape: Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, size: 24, color: AppColors.primaryContainer),
            onPressed: () => Scaffold.of(context).openDrawer(),
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              hoverColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Text(
          'Taxi Teori',
          style: GoogleFonts.publicSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 40 / 32,
            letterSpacing: -0.02 * 32,
            color: AppColors.primaryContainer,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => context.push('/category-selection'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_taxi_rounded, size: 14, color: AppColors.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Text(
                    'Taxi',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.onSecondaryContainer),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, size: 26, color: AppColors.primaryContainer),
            onPressed: () {},
            style: IconButton.styleFrom(
              foregroundColor: AppColors.primaryContainer,
              hoverColor: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            _sectionVerticalPadding,
            _horizontalPadding,
            88,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, Alex',
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
                "You're making great progress towards your Taxi License.",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildReadinessCard(),
              const SizedBox(height: 40),
              _buildModuleCard(
                moduleNumber: 1,
                icon: Icons.security_rounded,
                iconColor: AppColors.onSecondaryContainer,
                iconBg: AppColors.secondaryContainer,
                title: 'Säkerhet & Beteende',
                description:
                    'Understand passenger safety, conflict resolution, and professional conduct.',
                progress: 0.85,
                progressColor: AppColors.primary,
                onTap: () => context.push('/taxi-sakerhet'),
              ),
              const SizedBox(height: 16),
              _buildModuleCard(
                moduleNumber: 2,
                icon: Icons.map_rounded,
                iconColor: AppColors.onSecondaryContainer,
                iconBg: AppColors.secondaryContainer,
                title: 'Karta',
                description:
                    'Master navigation, reading maps, and efficient route planning in urban environments.',
                progress: 0.42,
                progressColor: AppColors.secondary,
                onTap: () => context.push('/taxi-karta'),
              ),
              const SizedBox(height: 16),
              _buildModuleCard(
                moduleNumber: 3,
                icon: Icons.gavel_rounded,
                iconColor: AppColors.onTertiary,
                iconBg: AppColors.tertiaryContainer,
                title: 'Lagstiftning',
                description:
                    'Learn the specific laws and regulations governing taxi operations in Sweden.',
                progress: 0.12,
                progressColor: AppColors.tertiary,
                onTap: () => context.push('/taxi-lagstiftning'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildReadinessCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Icon(
              Icons.local_taxi_rounded,
              size: 120,
              color: AppColors.onPrimary.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Readiness',
                  style: GoogleFonts.publicSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '68%',
                      style: GoogleFonts.publicSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 40 / 32,
                        letterSpacing: -0.02 * 32,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Mastery',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.68,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.all(Radius.circular(9999)),
                        ),
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

  Widget _buildModuleCard({
    required int moduleNumber,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required double progress,
    required Color progressColor,
    required VoidCallback onTap,
  }) {
    final pct = (progress * 100).round();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Module $moduleNumber',
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
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
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(9999),
                ),
                clipBehavior: Clip.antiAlias,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
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
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Hem',
                isSelected: true,
                route: '/taxi-dashboard',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.map_outlined,
                label: 'Karta',
                isSelected: false,
                route: '/taxi-karta',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.security_outlined,
                label: 'Säkerhet',
                isSelected: false,
                route: '/taxi-sakerhet',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.gavel_outlined,
                label: 'Lagar',
                isSelected: false,
                route: '/taxi-lagstiftning',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required String route,
    required int index,
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
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
              ),
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
