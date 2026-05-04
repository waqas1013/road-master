import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/taxi_karta_practice_sets.dart';
import '../data/taxi_lagstiftning_practice_sets.dart';
import '../data/taxi_sakerhet_practice_sets.dart';
import '../services/karta_practice_repository.dart';
import '../services/lagar_practice_repository.dart';
import '../services/sakerhet_practice_repository.dart';
import '../services/taxi_entitlement_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_drawer.dart';
import '../widgets/taxi_shell_bottom_nav.dart';

/// Stitch **Taxi Dashboard — Updated Nav & Switcher** (driver portal home).
class TaxiDashboardScreen extends StatefulWidget {
  const TaxiDashboardScreen({super.key});

  @override
  State<TaxiDashboardScreen> createState() => _TaxiDashboardScreenState();
}

class _TaxiDashboardScreenState extends State<TaxiDashboardScreen> {
  late final VoidCallback _onProgressChanged;

  @override
  void initState() {
    super.initState();
    _onProgressChanged = () {
      if (mounted) setState(() {});
    };
    SakerhetPracticeRepository.instance.progressRevision.addListener(_onProgressChanged);
    LagarPracticeRepository.instance.progressRevision.addListener(_onProgressChanged);
    KartaPracticeRepository.instance.progressRevision.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    SakerhetPracticeRepository.instance.progressRevision.removeListener(_onProgressChanged);
    LagarPracticeRepository.instance.progressRevision.removeListener(_onProgressChanged);
    KartaPracticeRepository.instance.progressRevision.removeListener(_onProgressChanged);
    super.dispose();
  }

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

  /// Overall “taximodul” — mean of study categories (vägmärken included as 0 until content exists).
  int _overallPercent() {
    const vagmarken = 0.0;
    final p = (_sakerhetProgress() + _kartaProgress() + _lagarProgress() + vagmarken) / 4;
    return ((p * 100).round()).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = TaxiEntitlementService.instance.canViewPersonalTaxiProgress;
    final sakerhetP = loggedIn ? _sakerhetProgress() : 0.0;
    final kartaP = loggedIn ? _kartaProgress() : 0.0;
    final lagarP = loggedIn ? _lagarProgress() : 0.0;
    const vagmarkenP = 0.0;
    final overall = loggedIn ? _overallPercent() : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        // Stitch `node-id=6f008d1c0dd64dd7be398efc70471f99`: [menu] + taxi + Förarportal | switcher
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        centerTitle: false,
        titleSpacing: 12,
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: const Border(
          bottom: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
        title: Builder(
          builder: (context) => Row(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primaryContainer,
                  iconSize: 24,
                ),
                icon: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: 4),
              Icon(Icons.local_taxi_rounded, size: 26, color: AppColors.primaryContainer),
              const SizedBox(width: 8),
              Text(
                'Förarportal',
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _LicenseModeSwitch(
              onSelectCar: () => context.go('/category-selection'),
              onSelectTaxi: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Välkommen tillbaka',
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
                'Fortsätt din väg mot taxilegitimationen.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 24 / 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (!loggedIn) ...[
                const SizedBox(height: 16),
                Material(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => context.push('/login'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.login_rounded, color: AppColors.primaryContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Logga in för att spara och se din riktiga framsteg.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 20 / 14,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _ProgressCard(overallPercent: overall),
              const SizedBox(height: 32),
              Text(
                'Studiekategorier',
                style: GoogleFonts.publicSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 28 / 20,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.02,
                children: [
                  _CategoryTile(
                    title: 'Säkerhet & Beteende',
                    progress: sakerhetP,
                    icon: Icons.security_rounded,
                    iconBackground: AppColors.primaryLight,
                    iconColor: AppColors.onPrimaryFixed,
                    barColor: AppColors.primaryContainer,
                    onTap: () => context.push('/taxi-sakerhet'),
                  ),
                  _CategoryTile(
                    title: 'Karta & Ruttplanering',
                    progress: kartaP,
                    icon: Icons.map_rounded,
                    iconBackground: AppColors.secondaryFixed,
                    iconColor: AppColors.onSecondaryFixed,
                    barColor: AppColors.secondary,
                    onTap: () => context.push('/taxi-karta'),
                  ),
                  _CategoryTile(
                    title: 'Lagstiftning',
                    progress: lagarP,
                    icon: Icons.gavel_rounded,
                    iconBackground: AppColors.surfaceContainerHighest,
                    iconColor: AppColors.onSurfaceVariant,
                    barColor: AppColors.outline,
                    onTap: () => context.push('/taxi-lagstiftning'),
                  ),
                  _CategoryTile(
                    title: 'Vägmärken',
                    progress: vagmarkenP,
                    icon: Icons.traffic_rounded,
                    iconBackground: AppColors.surfaceContainerHighest,
                    iconColor: AppColors.onSurfaceVariant,
                    barColor: AppColors.surfaceVariant,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _SlutprovCta(onStart: () => context.push('/taxi-mock-exams')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TaxiShellBottomNav(selectedRoute: '/taxi-dashboard'),
    );
  }
}

class _LicenseModeSwitch extends StatelessWidget {
  const _LicenseModeSwitch({
    required this.onSelectCar,
    required this.onSelectTaxi,
  });

  final VoidCallback onSelectCar;
  final VoidCallback onSelectTaxi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundModeButton(
            icon: Icons.directions_car_rounded,
            selected: false,
            onTap: onSelectCar,
          ),
          _RoundModeButton(
            icon: Icons.local_taxi_rounded,
            selected: true,
            onTap: onSelectTaxi,
          ),
        ],
      ),
    );
  }
}

class _RoundModeButton extends StatelessWidget {
  const _RoundModeButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.overallPercent});

  final int overallPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dina framsteg',
                      style: GoogleFonts.publicSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 28 / 20,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Du har slutfört $overallPercent% av taximodulen.',
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
              Text(
                '$overallPercent%',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 32 / 24,
                  letterSpacing: -0.01 * 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overallPercent / 100,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.progress,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.barColor,
    required this.onTap,
  });

  final String title;
  final double progress;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color barColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black.withValues(alpha: 0.02),
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
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    '$pct%',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.02 * 14,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  color: barColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlutprovCta extends StatelessWidget {
  const _SlutprovCta({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryFixedDim),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Redo för testet?',
            style: GoogleFonts.publicSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.onPrimaryFixed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gör ett simulerat slutprov för att se din nivå.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.onPrimaryFixedVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Starta Slutprov',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.02 * 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
