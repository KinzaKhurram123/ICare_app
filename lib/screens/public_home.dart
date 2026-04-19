import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/whatsapp_button.dart';
import 'package:icare/widgets/doctor_search_bar.dart';

class PublicHome extends StatelessWidget {
  const PublicHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: true,
            toolbarHeight: 72,
            surfaceTintColor: Colors.white,
            shadowColor: const Color(0x1A0036BC),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE8ECF5), width: 1)),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: 14,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center: logo
                      Center(
                        child: SvgPicture.asset(
                          ImagePaths.logo,
                          width: isMobile ? 36 : 48,
                          height: isMobile ? 36 : 48,
                          colorFilter: null,
                        ),
                      ),
                      // Right: nav buttons
                      Positioned(
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMobile) ...[
                              _NavButton(
                                label: 'Sign In',
                                filled: true,
                                onTap: () => context.go('/login'),
                              ),
                              const SizedBox(width: 6),
                              _NavButton(
                                label: 'Sign Up',
                                filled: false,
                                onTap: () => context.go('/signup'),
                              ),
                              const SizedBox(width: 6),
                              _NavButton(
                                label: 'Work With Us',
                                filled: false,
                                accent: true,
                                onTap: () => context.go('/work-with-us'),
                              ),
                            ] else ...[
                              _NavButton(
                                label: 'Sign In',
                                filled: true,
                                onTap: () => context.go('/login'),
                              ),
                              const SizedBox(width: 6),
                              _NavButton(
                                label: 'Sign Up',
                                filled: false,
                                onTap: () => context.go('/signup'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Banner(),
                const SizedBox(height: 40),

                // 1. Connect to a Doctor Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: _CenteredSection(
                    child: Column(
                      children: [
                        _SectionHeader(
                          title: 'Consult Available Doctors',
                          subtitle: 'Talk to a verified doctor within minutes from the comfort of your home',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => const DoctorsList()),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Search bar moved here from banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: DoctorSearchBar(isMobile: MediaQuery.of(context).size.width < 700),
                        ),
                        const SizedBox(height: 40),
                        _DoctorsSlider(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // 2. Browse by Specialty Section (moved before pharmacy/labs)
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _SectionHeader(
                        title: 'Browse by Specialty',
                        subtitle: 'Find the right specialist for your health needs',
                      ),
                      const SizedBox(height: 16),
                      // Search by condition
                      _ConditionSearchBar(),
                      const SizedBox(height: 24),
                      _SpecialtyGrid(),
                      const SizedBox(height: 24),
                      // See All Speciality centered button
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DoctorsList()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF0036BC), width: 1.5),
                            ),
                            child: const Text(
                              'See All Speciality',
                              style: TextStyle(
                                color: Color(0xFF0036BC),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'Gilroy-Bold',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // 3. Order Medicines Section (renamed from Pharmacies)
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _SectionHeader(
                        title: 'Order Medicines',
                        subtitle: 'Order medicines from trusted pharmacies near you',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _MedicineSearchBar(),
                      const SizedBox(height: 24),
                      _PharmaciesGrid(),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // 4. Book a Lab Test Section (renamed from Laboratories)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 60, bottom: 32),
                  child: _CenteredSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _SectionHeader(
                          title: 'Book a Lab Test',
                          subtitle: 'Book lab tests and get results delivered at home',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => LabsListScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabSearchBar(),
                        const SizedBox(height: 24),
                        _LaboratoriesGrid(),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                              ),
                              child: const Text(
                                'Book Lab',
                                style: TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  fontFamily: 'Gilroy-Bold',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Courses Section (new — above How iCare Works)
                _CoursesSection(),

                const SizedBox(height: 24),

                // 6. How iCare Works Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 36, bottom: 60),
                  child: _CenteredSection(
                    child: Column(
                      children: [
                        _SectionHeader(
                          title: 'How iCare Works',
                          subtitle: 'Get quality healthcare in 4 simple steps',
                        ),
                        const SizedBox(height: 40),
                        _HowItWorksSteps(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // App Download Section
                _AppDownloadBanner(),

                // Footer (no gap)
                _Footer(),
              ],
            ),
          ),
        ],
        ),
          const WhatsAppFloatingButton(),
        ],
      ),
    );
  }
}


// ── Search Bars ───────────────────────────────────────────────────────────────
class _ConditionSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search by condition (e.g. Diabetes, Fever...)',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0036BC), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const DoctorsList()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _MedicineSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search for medicines, brands...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF10B981), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const PharmaciesScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _LabSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search test names (e.g. CBC, HbA1c...)',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.biotech_rounded, color: Color(0xFF8B5CF6), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => LabsListScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}

// ── Courses Section ───────────────────────────────────────────────────────────
class _CoursesSection extends StatelessWidget {
  static const _courses = [
    {'title': 'Diet Plan & Health Courses', 'desc': 'For Patients - Learn healthy eating habits', 'icon': Icons.restaurant_menu_rounded, 'color': 0xFF10B981, 'audience': 'patient'},
    {'title': 'Health Programs', 'desc': 'For Patients - Manage your health', 'icon': Icons.health_and_safety_rounded, 'color': 0xFF6366F1, 'audience': 'patient'},
    {'title': 'General Courses', 'desc': 'For Doctors - Medical education', 'icon': Icons.school_rounded, 'color': 0xFFEF4444, 'audience': 'doctor'},
    {'title': 'Training Programs', 'desc': 'For Healthcare - Professional training', 'icon': Icons.medical_services_rounded, 'color': 0xFFF59E0B, 'audience': 'doctor'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: _CenteredSection(
        child: Column(
          children: [
            _SectionHeader(
              title: "Join Pakistan's First 360° Health Care Platform",
              subtitle: 'Open for Everyone • Live Skill Academy for Everyone',
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isMobile
                  ? Column(
                      children: _courses.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CourseCard(course: c),
                      )).toList(),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.8,
                      children: _courses.map((c) => _CourseCard(course: c)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatefulWidget {
  final Map<String, Object> course;
  const _CourseCard({required this.course});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  @override
  Widget build(BuildContext context) {
    final color = Color(widget.course['color'] as int);
    return Tooltip(
      message: 'Coming Soon',
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('LMS coming soon — stay tuned!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Opacity(
          opacity: 0.75,
          child: MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3F3F3), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.course['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.course['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Gilroy-Bold',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Coming Soon',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.course['desc'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card Data Model ───────────────────────────────────────────────────────────
class _CardData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;

  const _CardData({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.icon,
    required this.iconColor,
    this.iconBg,
  });
}

// ── Navbar Button ─────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool accent;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile && label == 'Work With Us') {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981), width: 1.5),
          ),
          child: const Icon(Icons.work_outline_rounded, color: Color(0xFF10B981), size: 18),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 20,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primaryColor
              : accent
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled
                ? AppColors.primaryColor
                : accent
                    ? const Color(0xFF10B981)
                    : AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled
                ? Colors.white
                : accent
                    ? const Color(0xFF10B981)
                    : AppColors.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 12 : 14,
            fontFamily: 'Gilroy-Bold',
          ),
        ),
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────
class _Banner extends StatefulWidget {
  @override
  State<_Banner> createState() => _BannerState();
}

class _BannerState extends State<_Banner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    final h = isMobile ? 380.0 : (w < 900 ? 360.0 : 460.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 8 : 14,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
        child: SizedBox(
          width: double.infinity,
          height: h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0036BC), Color(0xFF0554D4), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // 2. Decorative circles (desktop only)
              if (!isMobile) ...[
                Positioned(
                  right: -30, top: 20,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  right: 50, bottom: 20,
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
              // 3. Row layout: text left | image right
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: text + buttons
                  Expanded(
                    flex: 55,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isMobile ? 16 : 52,
                        right: isMobile ? 8 : 4,
                        top: isMobile ? 20 : 40,
                        bottom: isMobile ? 20 : 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isMobile
                                ? 'Consult Available\nDoctors'
                                : 'Consult Available\nDoctors',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Gilroy-Bold',
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: isMobile ? 10 : 14),
                          Text(
                            isMobile
                                ? 'Book appointments & consult\ntrusted doctors from home.'
                                : 'Book appointments, consult trusted doctors,\nand access healthcare from home.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 16,
                              color: Colors.white.withOpacity(0.88),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : 28),
                          // Two CTA buttons — left aligned
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              // Pulsing Connect button (glow only — text never jerks)
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  final g = (_pulseAnimation.value - 1.0) / 0.06;
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5 * g),
                                          blurRadius: 20,
                                          spreadRadius: 4 * g,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const DoctorsList()),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0036BC),
                                    minimumSize: Size(isMobile ? 150 : 190, isMobile ? 48 : 54),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 16 : 32,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Connect to a Doctor Now',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: isMobile ? 12 : 15,
                                      fontFamily: 'Gilroy-Bold',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // Book Appointment button
                              OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const DoctorsList()),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  minimumSize: Size(isMobile ? 150 : 190, isMobile ? 48 : 54),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 22 : 32,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isMobile ? 13 : 15,
                                    fontFamily: 'Gilroy-Bold',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 16 : 22),
                        ],
                      ),
                    ),
                  ),
                  // Right: doctor image (45%)
                  Expanded(
                    flex: 45,
                    child: Image.asset(
                      'assets/images/new.png',
                      fit: isMobile ? BoxFit.cover : BoxFit.contain,
                      alignment: isMobile ? Alignment.center : const Alignment(0.3, 0.0),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
}

// ── Centered Section Wrapper ──────────────────────────────────────────────────
class _CenteredSection extends StatelessWidget {
  final Widget child;
  const _CenteredSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}

// ── Doctors Slider ───────────────────────────────────────────────────────────
class _DoctorsSlider extends StatefulWidget {
  @override
  State<_DoctorsSlider> createState() => _DoctorsSliderState();
}

class _DoctorsSliderState extends State<_DoctorsSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const _doctors = [
    {'name': 'Dr. Ahmed Khan', 'spec': 'Cardiologist', 'exp': '15 years experience', 'rating': '4.9', 'reviews': '342', 'img': 'assets/images/user5.png'},
    {'name': 'Dr. Sara Malik', 'spec': 'Gynecologist', 'exp': '12 years experience', 'rating': '4.8', 'reviews': '289', 'img': 'assets/images/user1.png'},
    {'name': 'Dr. Bilal Ahmed', 'spec': 'Neurologist', 'exp': '10 years experience', 'rating': '4.7', 'reviews': '198', 'img': 'assets/images/user7.png'},
    {'name': 'Dr. Hina Raza', 'spec': 'Dermatologist', 'exp': '8 years experience', 'rating': '4.9', 'reviews': '412', 'img': 'assets/images/user10.png'},
    {'name': 'Dr. Usman Ali', 'spec': 'Pediatrician', 'exp': '14 years experience', 'rating': '4.8', 'reviews': '320', 'img': 'assets/images/user11.png'},
    {'name': 'Dr. Ayesha Noor', 'spec': 'Psychiatrist', 'exp': '11 years experience', 'rating': '4.6', 'reviews': '175', 'img': 'assets/images/user12.png'},
    {'name': 'Dr. Kamran Baig', 'spec': 'Orthopedic Surgeon', 'exp': '18 years experience', 'rating': '4.9', 'reviews': '511', 'img': 'assets/images/user5.png'},
    {'name': 'Dr. Zara Sheikh', 'spec': 'ENT Specialist', 'exp': '9 years experience', 'rating': '4.8', 'reviews': '230', 'img': 'assets/images/user13.png'},
  ];

  // Mobile: 1 card per page → 8 dots
  // Desktop: 4 cards per page → 2 dots
  int get _totalPages => _isMobile ? _doctors.length : (_doctors.length / 4).ceil();
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _totalPages;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _isMobile = screenWidth < 700;

    if (_isMobile) {
      return Column(
        children: [
          SizedBox(
            height: 270,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (p) => setState(() => _currentPage = p),
              itemCount: _doctors.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DoctorCard(doctor: _doctors[i]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SliderDots(
            total: _doctors.length,
            current: _currentPage,
            onTap: _goTo,
          ),
        ],
      );
    }

    // Desktop: 4 cards per page, smooth PageView slide
    final totalPages = (_doctors.length / 4).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemCount: totalPages,
                    itemBuilder: (_, pageIndex) {
                      final start = pageIndex * 4;
                      final pageDoctors = _doctors.skip(start).take(4).toList();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pageDoctors.map((doctor) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                          child: _DoctorCard(doctor: doctor),
                        )).toList(),
                      );
                    },
                  ),
                ),
              ),
              // Prev button
              Positioned(
                left: 0,
                child: _SliderButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => _goTo(_currentPage - 1),
                  enabled: _currentPage > 0,
                ),
              ),
              // Next button
              Positioned(
                right: 0,
                child: _SliderButton(
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => _goTo(_currentPage + 1),
                  enabled: _currentPage < totalPages - 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SliderDots(
            total: totalPages,
            current: _currentPage,
            onTap: _goTo,
          ),
        ],
      ),
    );
  }
}

class _SliderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _SliderButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  State<_SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<_SliderButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (_hovered ? const Color(0xFF0024A0) : const Color(0xFF0036BC))
                : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF0036BC).withOpacity(_hovered ? 0.45 : 0.25),
                      blurRadius: _hovered ? 22 : 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.enabled ? Colors.white : Colors.grey[500],
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SliderDots extends StatelessWidget {
  final int total;
  final int current;
  final void Function(int) onTap;

  const _SliderDots({
    required this.total,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: isActive ? 32 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0036BC) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Map<String, String> doctor;

  const _DoctorCard({required this.doctor});

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 210,
        padding: const EdgeInsets.all(16),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? const Color(0xFF14B1FF) : const Color(0xFFF3F3F3),
            width: 2,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: const Color(0xFF14B1FF).withOpacity(0.15),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF14B1FF),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.doctor['img']!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF0036BC),
                    child: const Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.doctor['name']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0036BC),
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              widget.doctor['spec']!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              widget.doctor['exp']!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 13),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 13),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 13),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 13),
                Icon(
                  double.parse(widget.doctor['rating']!) >= 4.8
                      ? Icons.star
                      : Icons.star_border,
                  color: const Color(0xFFF5A623),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.doctor['rating']} (${widget.doctor['reviews']})',
                  style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const DoctorsList()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0036BC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Consult Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy-Bold',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pharmacies Grid ──────────────────────────────────────────────────────────
class _PharmaciesGrid extends StatelessWidget {
  static const _pharmacies = [
    {'name': 'MedPlus Pharmacy', 'area': 'Gulshan, Karachi', 'rating': '4.8'},
    {'name': 'HealthCare Pharma', 'area': 'DHA, Lahore', 'rating': '4.7'},
    {'name': 'City Pharmacy', 'area': 'F-7, Islamabad', 'rating': '4.6'},
    {'name': 'Al-Shifa Pharmacy', 'area': 'Saddar, Karachi', 'rating': '4.9'},
    {'name': 'Cure Pharmacy', 'area': 'Model Town, Lahore', 'rating': '4.5'},
    {'name': 'Wellness Pharma', 'area': 'G-11, Islamabad', 'rating': '4.7'},
    {'name': 'Shifaa Pharmacy', 'area': 'Clifton, Karachi', 'rating': '4.8'},
    {'name': 'Apollo Pharmacy', 'area': 'Johar Town, Lahore', 'rating': '4.6'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isMobile ? 1.3 : 1.5,
        children: _pharmacies.map((p) => _ServiceCard(
          name: p['name']!,
          subtitle: p['area']!,
          rating: p['rating']!,
          icon: Icons.local_pharmacy_rounded,
          iconColor: const Color(0xFF10B981),
          width: double.infinity,
        )).toList(),
      ),
    );
  }
}

// ── Laboratories Grid ─────────────────────────────────────────────────────────
class _LaboratoriesGrid extends StatelessWidget {
  static const _labs = [
    {'name': 'Chughtai Lab', 'area': 'Lahore', 'rating': '4.9'},
    {'name': 'Essa Lab', 'area': 'Karachi', 'rating': '4.7'},
    {'name': 'Excel Labs', 'area': 'Islamabad', 'rating': '4.8'},
    {'name': 'Shaukat Khanum Lab', 'area': 'Lahore', 'rating': '4.9'},
    {'name': 'Agha Khan Lab', 'area': 'Karachi', 'rating': '4.8'},
    {'name': 'Islamabad Diagnostic', 'area': 'Islamabad', 'rating': '4.6'},
    {'name': 'Doctors Lab', 'area': 'Rawalpindi', 'rating': '4.5'},
    {'name': 'Metropole Lab', 'area': 'Karachi', 'rating': '4.7'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isMobile ? 1.3 : 1.5,
        children: _labs.map((l) => _ServiceCard(
          name: l['name']!,
          subtitle: l['area']!,
          rating: l['rating']!,
          icon: Icons.biotech_rounded,
          iconColor: const Color(0xFF8B5CF6),
          width: double.infinity,
        )).toList(),
      ),
    );
  }
}

// ── Service Card (Pharmacy / Lab) ─────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final String rating;
  final IconData icon;
  final Color iconColor;
  final double width;

  const _ServiceCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.icon,
    required this.iconColor,
    required this.width,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -3.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? widget.iconColor : const Color(0xFFF3F3F3),
            width: 2,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: widget.iconColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              widget.subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 13),
                const SizedBox(width: 3),
                Text(
                  widget.rating,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Specialty Grid ────────────────────────────────────────────────────────────
class _SpecialtyGrid extends StatelessWidget {
  static const _specialties = [
    {'name': 'Cardiologist', 'desc': 'Heart & Vascular', 'icon': Icons.favorite},
    {'name': 'Neurologist', 'desc': 'Brain & Nerves', 'icon': Icons.psychology},
    {'name': 'Orthopedic', 'desc': 'Bones & Joints', 'icon': Icons.accessibility_new},
    {'name': 'Pediatrician', 'desc': 'Child Specialist', 'icon': Icons.child_care},
    {'name': 'Dentist', 'desc': 'Oral & Dental', 'icon': Icons.medical_services},
    {'name': 'Eye Specialist', 'desc': 'Ophthalmology', 'icon': Icons.remove_red_eye},
    {'name': 'Pulmonologist', 'desc': 'Lungs & Chest', 'icon': Icons.air},
    {'name': 'Dermatologist', 'desc': 'Skin & Hair', 'icon': Icons.face},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isMobile ? 1.3 : 1.5,
        children: _specialties.map((spec) {
          return _SpecialtyCard(
            name: spec['name'] as String,
            description: spec['desc'] as String,
            icon: spec['icon'] as IconData,
            width: double.infinity,
          );
        }).toList(),
      ),
    );
  }
}

class _SpecialtyCard extends StatefulWidget {
  final String name;
  final String description;
  final IconData icon;
  final double width;

  const _SpecialtyCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.width,
  });

  @override
  State<_SpecialtyCard> createState() => _SpecialtyCardState();
}

class _SpecialtyCardState extends State<_SpecialtyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DoctorsList()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          transform: Matrix4.identity()..translate(0.0, _hovered ? -3.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? const Color(0xFF14B1FF) : const Color(0xFFF3F3F3),
              width: 2,
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: const Color(0xFF14B1FF).withOpacity(0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: const Color(0xFF0036BC), size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  fontFamily: 'Gilroy-Bold',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                widget.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── How It Works Steps ──────────────────────────────────────────────────────
class _HowItWorksSteps extends StatelessWidget {
  static const _steps = [
    {'num': '1', 'title': 'Search & Select', 'desc': 'Find the right doctor by specialty, condition, or name'},
    {'num': '2', 'title': 'Book Appointment', 'desc': 'Choose a convenient time slot and confirm your booking'},
    {'num': '3', 'title': 'Video Consult', 'desc': 'Connect via secure HD video call with your doctor'},
    {'num': '4', 'title': 'Get Prescription', 'desc': 'Receive digital prescriptions and follow-up care plans'},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: _steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _StepCard(
              number: step['num']!,
              title: step['title']!,
              description: step['desc']!,
            ),
          )).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        children: [
          // Connecting line
          Positioned(
            top: 28,
            left: 80,
            right: 80,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF14B1FF), Color(0xFF0036BC)],
                ),
              ),
            ),
          ),
          // Steps
          Row(
            children: _steps.map((step) => Expanded(
              child: _StepCard(
                number: step['num']!,
                title: step['title']!,
                description: step['desc']!,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0036BC),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B1FF).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Gilroy-Bold',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0036BC),
            fontFamily: 'Gilroy-Bold',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── App Download Banner ────────────────────────────────────────────────────────
class _AppDownloadBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    const decoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0036BC), Color(0xFF0049E6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    if (isMobile) {
      return Container(
        width: double.infinity,
        decoration: decoration,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(
          children: [
            Image.asset(
              'assets/images/mockup.png',
              height: 300,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 200,
                child: Icon(Icons.phone_android, size: 80, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Download the iCare App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Get instant access to 500+ doctors, lab results, prescriptions, and health records — all in one place.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _AppBadges(),
          ],
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: Container(
        width: double.infinity,
        decoration: decoration,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Download the iCare App',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Gilroy-Bold',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Get instant access to 500+ doctors, lab results,\nprescriptions, and health records — all in one place.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _AppBadges(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 520,
                  child: OverflowBox(
                    maxHeight: 780,
                    alignment: Alignment.center,
                    child: _PhoneMockups(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StoreBadgeButton(
          onTap: () {},
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.apple, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Download on the',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      'App Store',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _StoreBadgeButton(
          onTap: () {},
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GET IT ON',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Google Play',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreBadgeButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _StoreBadgeButton({required this.onTap, required this.child});

  @override
  State<_StoreBadgeButton> createState() => _StoreBadgeButtonState();
}

class _StoreBadgeButtonState extends State<_StoreBadgeButton> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Coming Soon',
      child: Opacity(
        opacity: 0.65,
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App coming soon — stay tuned!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PhoneMockups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mockup.png',
      height: 750,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Container(
        height: 600,
        width: 440,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Mobile Screens',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header with subtitle ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SectionHeader({required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0036BC),
              fontFamily: 'Gilroy-Bold',
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      );
    }
    return content;
  }
}

// ── Footer (white bg + blue theme) ────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ..._buildMobileFooter() else ..._buildDesktopFooter(),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE8ECF5), thickness: 1),
          const SizedBox(height: 20),
          _buildFooterBottom(isMobile),
        ],
      ),
    );
  }

  List<Widget> _buildDesktopFooter() {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(ImagePaths.logo, width: 64, height: 64, colorFilter: null),
                const SizedBox(height: 12),
                Text(
                  "Pakistan's leading virtual hospital platform. Connecting patients with top specialists for online consultations, lab tests, and digital prescriptions.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          const Expanded(
            child: _FooterColumn(
              title: 'For Patients',
              items: [
                'Find a Doctor',
                'Book Lab Tests',
                'Order Medicines',
                'Health Records',
                'Teleconsultation',
              ],
            ),
          ),
          const SizedBox(width: 40),
          const Expanded(
            child: _FooterColumn(
              title: 'Company',
              items: [
                'About Us',
                'Careers',
                'Privacy Policy',
                'Terms of Service',
                'Contact Us',
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMobileFooter() {
    return [
      Row(
        children: [
          SvgPicture.asset(ImagePaths.logo, width: 56, height: 56, colorFilter: null),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        "Pakistan's leading virtual hospital platform. Connecting patients with top specialists for online consultations, lab tests, and digital prescriptions.",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          height: 1.6,
        ),
      ),
      const SizedBox(height: 24),
      const _FooterColumn(
        title: 'For Patients',
        items: [
          'Find a Doctor',
          'Book Lab Tests',
          'Order Medicines',
          'Health Records',
          'Teleconsultation',
        ],
      ),
      const SizedBox(height: 20),
      const _FooterColumn(
        title: 'Company',
        items: [
          'About Us',
          'Careers',
          'Privacy Policy',
          'Terms of Service',
          'Contact Us',
        ],
      ),
    ];
  }

  Widget _buildFooterBottom(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Text(
            '© 2026 iCare. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '© 2026 iCare. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FooterColumn({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0036BC),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        )),
      ],
    );
  }
}

/// The scrollable body content of the public home page, without the top navbar.
/// Used on the logged-in patient home page so the layout matches the public home.
class PublicHomeBody extends StatelessWidget {
  const PublicHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Banner(),
        const SizedBox(height: 40),
        // 1. Connect to a Doctor
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: _CenteredSection(
            child: Column(
              children: [
                _SectionHeader(
                  title: 'Consult Available Doctors',
                  subtitle: 'Talk to a verified doctor within minutes from the comfort of your home',
                ),
                const SizedBox(height: 24),
                // Search bar moved here from banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DoctorSearchBar(isMobile: MediaQuery.of(context).size.width < 700),
                ),
                const SizedBox(height: 40),
                _DoctorsSlider(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 60),
        // 2. Browse by Specialty (before pharmacy/labs)
        _CenteredSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SectionHeader(
                title: 'Browse by Specialty',
                subtitle: 'Find the right specialist for your health needs',
              ),
              const SizedBox(height: 16),
              _ConditionSearchBar(),
              const SizedBox(height: 24),
              _SpecialtyGrid(),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DoctorsList()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0036BC), width: 1.5),
                    ),
                    child: const Text(
                      'See All Speciality',
                      style: TextStyle(
                        color: Color(0xFF0036BC),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        // 3. Order Medicines
        _CenteredSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SectionHeader(
                title: 'Order Medicines',
                subtitle: 'Order medicines from trusted pharmacies near you',
              ),
              const SizedBox(height: 16),
              _MedicineSearchBar(),
              const SizedBox(height: 24),
              _PharmaciesGrid(),
            ],
          ),
        ),
        const SizedBox(height: 60),
        // 4. Book a Lab Test
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 60, bottom: 32),
          child: _CenteredSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SectionHeader(
                  title: 'Book a Lab Test',
                  subtitle: 'Book lab tests and get results delivered at home',
                ),
                const SizedBox(height: 16),
                _LabSearchBar(),
                const SizedBox(height: 24),
                _LaboratoriesGrid(),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                      ),
                      child: const Text(
                        'Book Lab',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'Gilroy-Bold',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // 5. Courses Section
        _CoursesSection(),
        const SizedBox(height: 24),
        // 6. How iCare Works
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 36, bottom: 60),
          child: _CenteredSection(
            child: Column(
              children: [
                _SectionHeader(
                  title: 'How iCare Works',
                  subtitle: 'Get quality healthcare in 4 simple steps',
                ),
                const SizedBox(height: 40),
                _HowItWorksSteps(),
              ],
            ),
          ),
        ),
        // App Download Section (no gap)
        _AppDownloadBanner(),
        // Footer (no gap)
        _Footer(),
      ],
    );
  }
}
