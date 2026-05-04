import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Stitch taxi shell bottom bar: **Hem**, **Prov**, **Statistik** (three tabs only).
class TaxiShellBottomNav extends StatelessWidget {
  const TaxiShellBottomNav({
    super.key,
    this.selectedRoute,
    this.onBeforeNavigate,
  });

  /// Highlights one tab: `/taxi-dashboard`, `/taxi-mock-exams`, or `/taxi-statistik`.
  /// Omit or use another route when no tab should appear active (e.g. category drill-down).
  final String? selectedRoute;

  /// e.g. clear mock exam session before leaving results.
  final VoidCallback? onBeforeNavigate;

  static const double _barHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _item(
                    context,
                    icon: Icons.home_rounded,
                    iconOutlined: Icons.home_outlined,
                    label: 'Hem',
                    route: '/taxi-dashboard',
                  ),
                ),
                Expanded(
                  child: _item(
                    context,
                    icon: Icons.edit_document,
                    iconOutlined: Icons.edit_document,
                    label: 'Prov',
                    route: '/taxi-mock-exams',
                  ),
                ),
                Expanded(
                  child: _item(
                    context,
                    icon: Icons.insert_chart_rounded,
                    iconOutlined: Icons.insert_chart_outlined,
                    label: 'Statistik',
                    route: '/taxi-statistik',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required IconData iconOutlined,
    required String label,
    required String route,
  }) {
    final isSelected = selectedRoute == route;
    final activeColor = AppColors.primaryContainer;
    final inactiveColor = AppColors.onSurfaceVariant.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) return;
          onBeforeNavigate?.call();
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.55) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? icon : iconOutlined,
                size: 26,
                color: isSelected ? activeColor : inactiveColor,
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
                  height: 14 / 12,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
