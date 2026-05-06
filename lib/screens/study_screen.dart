import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/b_license_repository.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 1; // Practice tab is selected
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRepo();
  }

  Future<void> _loadRepo() async {
    await BLicenseRepository.instance.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu coming soon!')),
            );
          },
        ),
        title: Text(
          'Swedish Theory',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => context.push('/category-selection'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'B',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Study Categories',
              style: GoogleFonts.publicSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Master the core topics for the Swedish Theory Test.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryCard(
              icon: Icons.traffic_rounded,
              iconColor: Colors.blue.shade700,
              iconBg: Colors.blue.shade50,
              title: 'Traffic Rules',
              subtitle: 'Priority rules, right-of-way, speed limits, and positioning.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('Traffic Rules'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.signpost_rounded,
              iconColor: Colors.green.shade700,
              iconBg: Colors.green.shade50,
              title: 'Signs & Signals',
              subtitle: 'Road signs, road markings, and traffic light interpretations.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('Signs & Signals'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.pedal_bike_rounded,
              iconColor: Colors.orange.shade700,
              iconBg: Colors.orange.shade50,
              title: 'Safety & Pedestrians',
              subtitle: 'Vulnerable road users, defensive driving, and risk awareness.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('Safety & Pedestrians'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.psychology_rounded,
              iconColor: Colors.purple.shade700,
              iconBg: Colors.purple.shade50,
              title: 'The Human Factor',
              subtitle: 'Tiredness, alcohol, drugs, peer pressure, and driver psychology.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('The Human Factor'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.eco_rounded,
              iconColor: Colors.teal.shade700,
              iconBg: Colors.teal.shade50,
              title: 'Environment & Tech',
              subtitle: 'Eco-driving, emissions, fuel types, and active safety systems.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('Environment & Tech'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              icon: Icons.description_rounded,
              iconColor: Colors.red.shade700,
              iconBg: Colors.red.shade50,
              title: 'Vehicle & Documents',
              subtitle: 'Registration, inspection, insurance, and vehicle parts.',
              completed: 0,
              total: BLicenseRepository.instance.getTotalQuestions('Vehicle & Documents'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required int completed,
    required int total,
  }) {
    double progress = total > 0 ? completed / total : 0.0;
    
    return GestureDetector(
      onTap: () {
        context.push('/category-practice?title=${Uri.encodeComponent(title)}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completed/$total',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: iconBg.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.menu_book_rounded, 'Practice', 1),
              _buildNavItem(Icons.insights_rounded, 'Stats', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) context.go('/dashboard');
        if (index == 1) context.go('/study');
        if (index == 2) context.go('/stats');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
