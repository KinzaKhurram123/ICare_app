import 'package:flutter/material.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/work_with_us_signup.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';

class PublicHome extends StatelessWidget {
  const PublicHome({super.key});

  // ── Dummy data ──────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _doctors = [
    {'name': 'Dr. Ahmed Khan', 'spec': 'Cardiologist', 'img': 'https://randomuser.me/api/portraits/men/32.jpg'},
    {'name': 'Dr. Sara Malik', 'spec': 'Gynecologist', 'img': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'name': 'Dr. Bilal Ahmed', 'spec': 'Neurologist', 'img': 'https://randomuser.me/api/portraits/men/45.jpg'},
    {'name': 'Dr. Hina Raza', 'spec': 'Dermatologist', 'img': 'https://randomuser.me/api/portraits/women/68.jpg'},
    {'name': 'Dr. Usman Ali', 'spec': 'Pediatrician', 'img': 'https://randomuser.me/api/portraits/men/52.jpg'},
    {'name': 'Dr. Ayesha Noor', 'spec': 'Psychiatrist', 'img': 'https://randomuser.me/api/portraits/women/22.jpg'},
    {'name': 'Dr. Kamran Baig', 'spec': 'Orthopedic', 'img': 'https://randomuser.me/api/portraits/men/78.jpg'},
    {'name': 'Dr. Zara Sheikh', 'spec': 'ENT Specialist', 'img': 'https://randomuser.me/api/portraits/women/55.jpg'},
  ];

  static const List<Map<String, String>> _pharmacies = [
    {'name': 'MedPlus Pharmacy', 'area': 'Gulshan, Karachi'},
    {'name': 'HealthCare Pharma', 'area': 'DHA, Lahore'},
    {'name': 'City Pharmacy', 'area': 'F-7, Islamabad'},
    {'name': 'Al-Shifa Pharmacy', 'area': 'Saddar, Karachi'},
    {'name': 'Cure Pharmacy', 'area': 'Model Town, Lahore'},
    {'name': 'Wellness Pharma', 'area': 'G-11, Islamabad'},
    {'name': 'Shifaa Pharmacy', 'area': 'Clifton, Karachi'},
    {'name': 'Apollo Pharmacy', 'area': 'Johar Town, Lahore'},
  ];

  static const List<Map<String, String>> _labs = [
    {'name': 'Chughtai Lab', 'area': 'Lahore'},
    {'name': 'Essa Lab', 'area': 'Karachi'},
    {'name': 'Excel Labs', 'area': 'Islamabad'},
    {'name': 'Shaukat Khanum Lab', 'area': 'Lahore'},
    {'name': 'Agha Khan Lab', 'area': 'Karachi'},
    {'name': 'Islamabad Diagnostic', 'area': 'Islamabad'},
    {'name': 'Doctors Lab', 'area': 'Rawalpindi'},
    {'name': 'Metropole Lab', 'area': 'Karachi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Sticky Navbar ──────────────────────────────────────────────────
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      // Logo only — no text
                      Image.asset(ImagePaths.logo, width: 44, height: 44),
                      const Spacer(),
                      // 3 buttons
                      _NavButton(
                        label: 'Sign In',
                        filled: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _NavButton(
                        label: 'Sign Up',
                        filled: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SelectUserType()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _NavButton(
                        label: 'Work With Us',
                        filled: false,
                        accent: true,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WorkWithUsSignup()),
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
                // ── Banner ──────────────────────────────────────────────────
                _Banner(),

                const SizedBox(height: 40),

                // ── Connect To Doctor carousel ───────────────────────────────
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Connect To Doctor'),
                      const SizedBox(height: 16),
                      _DoctorCarousel(doctors: _doctors),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Pharmacies carousel ──────────────────────────────────────
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Pharmacies'),
                      const SizedBox(height: 16),
                      _PharmacyCarousel(pharmacies: _pharmacies),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Laboratories carousel ────────────────────────────────────
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Laboratories'),
                      const SizedBox(height: 16),
                      _LabCarousel(labs: _labs),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // ── Footer ───────────────────────────────────────────────────
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
      // On mobile show compact icon button
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
class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = w < 600 ? 200.0 : (w < 900 ? 280.0 : 420.0);
    return SizedBox(
      width: double.infinity,
      height: h,
      child: Image.asset(
        ImagePaths.banner,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0036BC), Color(0xFF035BE5), Color(0xFF14B1FF)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Your Health, Expert Care',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Gilroy-Bold',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Anytime, Anywhere',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Centered Section Wrapper ─────────────────────────────────────────────────
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

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0036BC),
          fontFamily: 'Gilroy-Bold',
        ),
      ),
    );
  }
}

// ── Doctor Carousel ───────────────────────────────────────────────────────────
class _DoctorCarousel extends StatelessWidget {
  final List<Map<String, String>> doctors;
  const _DoctorCarousel({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final d = doctors[i];
          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(d['img']!),
                  backgroundColor: const Color(0xFFE8F4FF),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    d['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0036BC),
                      fontFamily: 'Gilroy-Bold',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d['spec']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'Gilroy-Medium',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Pharmacy Carousel ─────────────────────────────────────────────────────────
class _PharmacyCarousel extends StatelessWidget {
  final List<Map<String, String>> pharmacies;
  const _PharmacyCarousel({required this.pharmacies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: pharmacies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final p = pharmacies[i];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    p['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Gilroy-Bold',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  p['area']!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Lab Carousel ──────────────────────────────────────────────────────────────
class _LabCarousel extends StatelessWidget {
  final List<Map<String, String>> labs;
  const _LabCarousel({required this.labs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final l = labs[i];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.biotech_rounded, color: Color(0xFF8B5CF6), size: 24),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Gilroy-Bold',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  l['area']!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1A4A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImagePaths.logo, width: 36, height: 36),
              const SizedBox(width: 10),
              const Text(
                'iCare Virtual Hospital',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Gilroy-Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026 iCare. All rights reserved.',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
