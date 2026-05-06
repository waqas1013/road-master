import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PracticeSetModel {
  final String title;
  final String state; // 'completed', 'current', 'not_started'
  final int scorePercent;
  final int progress;
  final int total;

  PracticeSetModel({
    required this.title,
    required this.state,
    this.scorePercent = 0,
    this.progress = 0,
    required this.total,
  });
}

class CategoryPracticeScreen extends StatefulWidget {
  final String categoryTitle;

  const CategoryPracticeScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<CategoryPracticeScreen> createState() => _CategoryPracticeScreenState();
}

class _CategoryPracticeScreenState extends State<CategoryPracticeScreen> {
  late final String _studyTip;
  late final List<PracticeSetModel> _sets;
  late final int _overallProgress;
  late final IconData _categoryIcon;

  @override
  void initState() {
    super.initState();
    // Generate mock data relevant to the chosen category
    _setupMockData();
  }

  void _setupMockData() {
    if (widget.categoryTitle == 'Traffic Rules') {
      _studyTip = 'Focus on the differences between give-way and stop rules. Pay attention to who has the right of way in unmarked intersections.';
      _overallProgress = 45;
      _categoryIcon = Icons.traffic_rounded;
      _sets = [
        PracticeSetModel(title: 'Priority & Right-of-way', state: 'completed', scorePercent: 92, progress: 50, total: 50),
        PracticeSetModel(title: 'Speed Limits & Positioning', state: 'current', progress: 20, total: 50),
        PracticeSetModel(title: 'Overtaking Rules', state: 'not_started', total: 40),
      ];
    } else if (widget.categoryTitle == 'Signs & Signals') {
      _studyTip = 'Focus on the subtle differences between warning signs and prohibition signs. Pay attention to colors and shapes.';
      _overallProgress = 33;
      _categoryIcon = Icons.traffic_rounded; // Or signpost
      _sets = [
        PracticeSetModel(title: 'Warning & Priority Signs', state: 'completed', scorePercent: 95, progress: 60, total: 60),
        PracticeSetModel(title: 'Prohibition & Mandatory', state: 'current', progress: 40, total: 75),
        PracticeSetModel(title: 'Information & Direction', state: 'not_started', total: 75),
        PracticeSetModel(title: 'Traffic Signals & Markings', state: 'not_started', total: 50),
      ];
    } else if (widget.categoryTitle == 'Safety & Pedestrians') {
      _studyTip = 'Always anticipate the unexpected. Vulnerable road users like children and cyclists can act unpredictably.';
      _overallProgress = 20;
      _categoryIcon = Icons.pedal_bike_rounded;
      _sets = [
        PracticeSetModel(title: 'Vulnerable Road Users', state: 'current', progress: 12, total: 60),
        PracticeSetModel(title: 'Defensive Driving Strategies', state: 'not_started', total: 50),
      ];
    } else if (widget.categoryTitle == 'The Human Factor') {
      _studyTip = 'Remember that tiredness affects reaction time just as much as low levels of alcohol.';
      _overallProgress = 10;
      _categoryIcon = Icons.psychology_rounded;
      _sets = [
        PracticeSetModel(title: 'Tiredness & Distractions', state: 'current', progress: 4, total: 40),
        PracticeSetModel(title: 'Alcohol & Drugs', state: 'not_started', total: 30),
      ];
    } else if (widget.categoryTitle == 'Environment & Tech') {
      _studyTip = 'Eco-driving saves fuel and the environment. Keep a steady speed and engine brake when possible.';
      _overallProgress = 50;
      _categoryIcon = Icons.eco_rounded;
      _sets = [
        PracticeSetModel(title: 'Eco-driving Principles', state: 'completed', scorePercent: 88, progress: 30, total: 30),
        PracticeSetModel(title: 'Vehicle Technologies', state: 'current', progress: 10, total: 20),
      ];
    } else {
      // Default / Vehicle & Documents
      _studyTip = 'Make sure you know the difference between registration certificate part 1 and part 2.';
      _overallProgress = 0;
      _categoryIcon = Icons.description_rounded;
      _sets = [
        PracticeSetModel(title: 'Registration & Inspection', state: 'not_started', total: 15),
        PracticeSetModel(title: 'Insurance & Liability', state: 'not_started', total: 15),
      ];
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.onBackground,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.categoryTitle,
                    style: GoogleFonts.publicSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Study Tip Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFFF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC4F2E3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD3F9ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF0F7A6A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Study Tip',
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F7A6A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _studyTip,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF265D53),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Overall Progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OVERALL PROGRESS',
                        style: GoogleFonts.publicSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_overallProgress% Complete',
                        style: GoogleFonts.publicSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F7A6A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: _overallProgress / 100,
                            strokeWidth: 4,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F7A6A)),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Icon(
                          _categoryIcon,
                          size: 20,
                          color: const Color(0xFF0F7A6A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Sets list
            ...List.generate(_sets.length, (index) {
              final setModel = _sets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSetCard(index + 1, setModel),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSetCard(int setNumber, PracticeSetModel setModel) {
    if (setModel.state == 'completed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set $setNumber',
                  style: GoogleFonts.publicSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: const Color(0xFF0F7A6A),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              setModel.title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: ${setModel.scorePercent}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(
                value: 1.0,
                minHeight: 4,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F7A6A)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF0F7A6A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Review Results',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F7A6A),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (setModel.state == 'current') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Set $setNumber',
                            style: GoogleFonts.publicSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackground,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Current',
                              style: GoogleFonts.publicSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        setModel.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${setModel.progress} / ${setModel.total}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: setModel.progress / setModel.total,
                          minHeight: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Continue Practice',
                            style: GoogleFonts.publicSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // not_started
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set $setNumber',
              style: GoogleFonts.publicSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              setModel.title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Not started',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '0 / ${setModel.total}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start Set',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBottomNav() {
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
    // 1 is selected
    final isSelected = 1 == index;
    return GestureDetector(
      onTap: () {
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
