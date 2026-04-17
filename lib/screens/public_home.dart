import 'dart:async';
import 'package:flutter/material.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/work_with_us_signup.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/pharmacy_home.dart';
import 'package:icare/widgets/laboratory.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/screens/pharmacies.dart';
import 'package:icare/screens/lab_list.dart';
import 'package:icare/screens/product_details.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/pulsing_button.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/diagnostic_tests.dart';
import 'package:icare/widgets/whatsapp_button.dart';
import 'package:icare/screens/patient_medical_records.dart';
import 'package:icare/screens/lab_reports_screen.dart';
import 'package:icare/screens/patient_lab_orders.dart';

class PublicHome extends StatelessWidget {
  const PublicHome({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      Image.asset(ImagePaths.logo, width: 44, height: 44),
                      const Spacer(),
                      NavButton(
                        label: 'Sign in',
                        filled: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      NavButton(
                        label: 'Sign Up',
                        filled: true,  
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SelectUserType()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      NavButton(
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
                const PublicBanner(),
                const SizedBox(height: 40),

                // Browse by Specialty Section
                CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Browse by Specialty',
                        subtitle: 'Find the right specialist for your health needs',
                      ),
                      const SizedBox(height: 24),
                      SpecialtyGrid(),
                      const SizedBox(height: 32),
                      Center(
                        child: NavButton(
                          label: 'See All Speciality',
                          filled: false,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DoctorsList()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Pharmacy Section ("Order Medicines")
                OrderMedicinesSection(),
                
                const SizedBox(height: 60),

                // Laboratory Section ("Book a Lab Test")
                BookLabSection(),

                const SizedBox(height: 60),

                // Courses Section
                CoursesSection(),

                const SizedBox(height: 60),

                // How it Works Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: CenteredSection(
                    child: Column(
                      children: [
                        SectionHeader(
                          title: 'How iCare Works',
                          subtitle: 'Get quality healthcare in 4 simple steps',
                        ),
                        const SizedBox(height: 40),
                        HowItWorksSteps(),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 60),
                const TestimonialsSection(),
                const SizedBox(height: 60),
                const AppDownloadBanner(),
                const SizedBox(height: 60),
                Footer(),
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

// ── New Sections — Task 4 & 5 ────────────────────────────────────────────────

class OrderMedicinesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB), // Subtle off-white to make cards pop
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        children: [
          CenteredSection(
            child: Column(
              children: [
                SectionHeader(
                  title: 'Order Medicines',
                  subtitle: 'Get authentic medicines delivered to your doorstep in minutes',
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: _buildSearchOverlay(context, 'Search Medicines (e.g. Panadol, Insulin, Inhalers)'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 54),
          PharmacySlider(),
        ],
      ),
    );
  }
}

class BookLabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F8FF),
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Column(
        children: [
          CenteredSection(
            child: Column(
              children: [
                SectionHeader(
                  title: 'Book a Lab Test',
                  subtitle: 'World-class laboratories providing accurate results for your health',
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const DiagnosticTestsScreen()),
                            ),
                            child: _buildSearchOverlay(context, 'Search for Lab Tests (e.g. Blood Test, MRI, COVID-19)'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        NavButton(
                          label: 'Search Labs',
                          filled: true,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LabsListScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 54),
          LaboratorySlider(),
          const SizedBox(height: 48),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DiagnosticTestsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: "Browse All Diagnostic Tests", 
                        color: AppColors.primaryColor, 
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicalRecordsSection extends StatelessWidget {
  const MedicalRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: CenteredSection(
        child: Column(
          children: [
            SectionHeader(
              title: 'Your Medical Records',
              subtitle: 'Access your complete medical history, doctor recordings, and prescriptions in one place',
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PatientMedicalRecords()),
                  ),
                  child: Container(
                    width: 600,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.folder_shared_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Record Access',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Click here to see what your doctor has recorded',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
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

class CoursesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: CenteredSection(
        child: Column(
          children: [
            const Text(
              "Join Pakistan's First 360° Health Care Platform",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Open for Everyone",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CourseGrid(),
            const SizedBox(height: 32),
            const Text(
              "Live Skill Academy for Everyone",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryColor, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CourseGrid extends StatelessWidget {
  const CourseGrid({super.key});
  static const List<Map<String, dynamic>> items = [
    {'title': 'Diet Plan & Health Related Courses', 'sub': 'For Patients', 'icon': Icons.restaurant_menu_rounded, 'color': Color(0xFF10B981)},
    {'title': 'Health Programs', 'sub': 'For Patients', 'icon': Icons.favorite_rounded, 'color': Color(0xFFEF4444)},
    {'title': 'General Courses', 'sub': 'For Doctors', 'icon': Icons.school_rounded, 'color': Color(0xFF3B82F6)},
    {'title': 'Training Programs for Healthcare', 'sub': 'For Doctors', 'icon': Icons.medical_services_rounded, 'color': Color(0xFFF59E0B)},
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 900;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isDesktop ? 1.2 : 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Courses())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: item['color'].withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(item['icon'], color: item['color'], size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['title'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['sub'],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: item['color']),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildSearchOverlay(BuildContext context, String hint) {
  return Container(
    height: 60, // Taller search bar for flagship feel
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06), 
          blurRadius: 20, 
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        const SizedBox(width: 20),
        const Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8), 
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Card Data Model ───────────────────────────────────────────────────────────
class _CardData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final VoidCallback? onTap;

  const _CardData({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.icon,
    required this.iconColor,
    this.iconBg,
    this.onTap,
  });
}

// ── Card Grid — desktop: Wrap, mobile: horizontal scroll ─────────────────────
class _CardGrid extends StatelessWidget {
  final List<_CardData> items;
  final double cardWidth;
  final double cardHeight;

  const _CardGrid({
    required this.items,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 700;

    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          children: items.map((item) => _AnimatedCard(
            data: item,
            width: cardWidth,
            height: cardHeight,
          )).toList(),
        ),
      );
    }

    // Mobile: horizontal scroll
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _AnimatedCard(
          data: items[i],
          width: cardWidth,
          height: cardHeight,
        ),
      ),
    );
  }
}

// ── Animated Card with hover + click blue effect ──────────────────────────────
class _AnimatedCard extends StatefulWidget {
  final _CardData data;
  final double width;
  final double height;

  const _AnimatedCard({
    required this.data,
    required this.width,
    required this.height,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _hovered || _pressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.data.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..translate(0.0, isActive ? -4.0 : 0.0),
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF0036BC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? const Color(0xFF14B1FF) : const Color(0xFFE8ECF5),
              width: isActive ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFF14B1FF).withOpacity(0.25)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final textColor = _pressed ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = _pressed ? Colors.white70 : Colors.grey;

    if (widget.data.imageUrl != null) {
      // Doctor card with photo
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE8F4FF),
            child: ClipOval(
              child: Image.network(
                widget.data.imageUrl!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: _pressed ? Colors.white : const Color(0xFF0036BC),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.data.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _pressed ? Colors.white : const Color(0xFF0036BC),
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.data.subtitle,
            style: TextStyle(fontSize: 11, color: subtitleColor),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Pharmacy / Lab card with icon
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withOpacity(0.2)
                : (widget.data.iconBg ?? widget.data.iconColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.data.icon,
            color: _pressed ? Colors.white : widget.data.iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.data.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFamily: 'Gilroy-Bold',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          widget.data.subtitle,
          style: TextStyle(fontSize: 11, color: subtitleColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Navbar Button ─────────────────────────────────────────────────────────────
class NavButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool accent;
  final VoidCallback onTap;

  const NavButton({
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
class PublicBanner extends StatefulWidget {
  const PublicBanner({super.key});

  @override
  State<PublicBanner> createState() => _PublicBannerState();
}

class _PublicBannerState extends State<PublicBanner> {
  int _currentImageIndex = 0;
  Timer? _timer;

  final List<String> _bannerImages = [
    'assets/images/doctors/walkthrough1.png',
    'assets/images/doctors/walkthrough2.png',
    'assets/images/doctors/walkthrough3.png',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        if (_currentImageIndex < _bannerImages.length - 1) {
          _currentImageIndex++;
        } else {
          _currentImageIndex = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 800;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
          child: Container(
            width: double.infinity,
            height: isMobile ? 450 : 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0036BC), Color(0xFF14B1FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: isMobile 
                ? _buildMobileLayout() 
                : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        // Right side seamlessly switching image
        Positioned(
          right: 0,
          bottom: 0,
          top: 0,
          width: 550, // Standard width
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                 begin: Alignment.centerLeft,
                 end: Alignment.centerRight,
                 colors: [Colors.transparent, Colors.white],
                 stops: [0.0, 0.3],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Image.asset(
                  _bannerImages[_currentImageIndex],
                  key: ValueKey<int>(_currentImageIndex),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.bottomLeft, // This moves the narrow image flush left against the text search bar
                ),
              ),
            ),
          ),
        ),
        // Foreground Content
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700), // Stop search bar from awkwardly stretching
            child: Padding(
              padding: const EdgeInsets.only(left: 48, top: 40, bottom: 40, right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: 'Talk to a verified ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Specialist Doctor',
                          style: TextStyle(color: Color(0xFFE8F4FF)),
                        ),
                      ],
                    ),
                  ),
                   const SizedBox(height: 24),
                  PulsingButton(
                    label: "Connect to a Doctor Now", 
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DoctorsList()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                      label: const Text(
                        'Book Appointment',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchbar(),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFF4CAF50), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Certified Doctor Access — Complete Heal',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Blended slider constrained to the bottom right
        Positioned(
          right: 0,
          bottom: 0,
          width: 250, // Keep it from overflowing into text
          height: 250,
          child: ShaderMask(
            shaderCallback: (rect) {
               return const LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [Colors.transparent, Colors.white],
                 stops: [0.0, 0.4],
               ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Image.asset(
                  _bannerImages[_currentImageIndex],
                  key: ValueKey<int>(_currentImageIndex),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
        ),
        // Top text and search
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Talk to a verified ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Specialist Doctor',
                      style: TextStyle(color: Color(0xFFE8F4FF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PulsingButton(
                label: "Connect Now", 
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DoctorsList()),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Book Appointment',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSearchbar(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF4CAF50), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'Certified Doctor Access',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchbar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Doctors, Hospital, Conditions',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Material(
            color: const Color(0xFF0036BC),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            child: InkWell(
              onTap: () {
                // Perform search action here
              },
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Centered Section Wrapper ──────────────────────────────────────────────────
class CenteredSection extends StatelessWidget {
  final Widget child;
  const CenteredSection({required this.child});

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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _doctors = [
    {'name': 'Dr. Ahmed Khan', 'spec': 'Cardiologist', 'exp': '15 years experience', 'rating': '4.9', 'reviews': '342', 'fee': 'Rs. 1,200', 'img': 'assets/images/doctors/ahmed.png'},
    {'name': 'Dr. Sara Malik', 'spec': 'Gynecologist', 'exp': '12 years experience', 'rating': '4.8', 'reviews': '289', 'fee': 'Rs. 1,000', 'img': 'assets/images/doctors/sara.png'},
    {'name': 'Dr. Bilal Ahmed', 'spec': 'Neurologist', 'exp': '10 years experience', 'rating': '4.7', 'reviews': '198', 'fee': 'Rs. 1,500', 'img': 'assets/images/doctors/bilal.png'},
    {'name': 'Dr. Hina Raza', 'spec': 'Dermatologist', 'exp': '8 years experience', 'rating': '4.9', 'reviews': '412', 'fee': 'Rs. 900', 'img': 'https://xsgames.co/randomusers/assets/avatars/female/68.jpg'},
    {'name': 'Dr. Usman Ali', 'spec': 'Pediatrician', 'exp': '14 years experience', 'rating': '4.8', 'reviews': '320', 'fee': 'Rs. 800', 'img': 'https://xsgames.co/randomusers/assets/avatars/male/52.jpg'},
    {'name': 'Dr. Ayesha Noor', 'spec': 'Psychiatrist', 'exp': '11 years experience', 'rating': '4.6', 'reviews': '175', 'fee': 'Rs. 1,100', 'img': 'https://xsgames.co/randomusers/assets/avatars/female/22.jpg'},
    {'name': 'Dr. Kamran Baig', 'spec': 'Orthopedic Surgeon', 'exp': '18 years experience', 'rating': '4.9', 'reviews': '511', 'fee': 'Rs. 1,800', 'img': 'https://xsgames.co/randomusers/assets/avatars/male/78.jpg'},
    {'name': 'Dr. Zara Sheikh', 'spec': 'ENT Specialist', 'exp': '9 years experience', 'rating': '4.8', 'reviews': '230', 'fee': 'Rs. 950', 'img': 'https://xsgames.co/randomusers/assets/avatars/female/55.jpg'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _doctors.length - 4) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    
    if (isMobile) {
      return SizedBox(
        height: 300,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _doctors.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, i) => _DoctorCard(doctor: _doctors[i]),
        ),
      );
    }

    // Desktop: Show 4 cards at a time with navigation
    final visibleDoctors = _doctors.skip(_currentPage).take(4).toList();
    final totalPages = (_doctors.length / 4).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Doctor Cards
            Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: visibleDoctors.map((doctor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _DoctorCard(doctor: doctor),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Navigation Buttons
              Positioned(
                left: 0,
                child: _SliderButton(
                  icon: Icons.arrow_back,
                  onTap: _prevPage,
                  enabled: _currentPage > 0,
                ),
              ),
              Positioned(
                right: 0,
                child: _SliderButton(
                  icon: Icons.arrow_forward,
                  onTap: _nextPage,
                  enabled: _currentPage < _doctors.length - 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SliderDots(
            total: totalPages,
            current: (_currentPage / 4).floor(),
          ),
        ],
      ),
    );
  }
}

class _SliderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _SliderButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? const Color(0xFF0036BC) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF0036BC) : Colors.grey[300],
          size: 24,
        ),
      ),
    );
  }
}

class _SliderDots extends StatelessWidget {
  final int total;
  final int current;

  const _SliderDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0036BC) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
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
        width: 235,
        padding: const EdgeInsets.all(18),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? const Color(0xFF14B1FF) : const Color(0xFFE8ECF5),
            width: _hovered ? 2 : 1.5,
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
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF14B1FF), const Color(0xFF0036BC).withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0036BC).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: widget.doctor['img']!.startsWith('http') 
                        ? Image.network(
                            widget.doctor['img']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFE8F4FF),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0036BC)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF0036BC),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Image.asset(
                            widget.doctor['img']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF0036BC),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF14B1FF), size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.doctor['name']!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0036BC),
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.doctor['spec']!,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.doctor['exp']!,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 14),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 14),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 14),
                const Icon(Icons.star, color: Color(0xFFF5A623), size: 14),
                Icon(
                  double.parse(widget.doctor['rating']!) >= 4.8
                      ? Icons.star
                      : Icons.star_border,
                  color: const Color(0xFFF5A623),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.doctor['rating']} (${widget.doctor['reviews']})',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Video Fee',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.doctor['fee']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0036BC),
                      fontFamily: 'Gilroy-Bold',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DoctorsList()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0036BC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Consult Now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

class PharmacySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pharmacies = [
      {'name': 'D-Watson Pharmacy', 'rating': '4.8', 'location': 'Blue Area, Islamabad', 'time': '20-30 min'},
      {'name': 'Shaheen Chemist', 'rating': '4.9', 'location': 'F-10 Markaz, Islamabad', 'time': '15-25 min'},
      {'name': 'Tehzeeb Pharmacy', 'rating': '4.7', 'location': 'G-9 Markaz, Islamabad', 'time': '30-40 min'},
      {'name': 'MedAsk Pharmacy', 'rating': '4.8', 'location': 'Saddar, Rawalpindi', 'time': '25-35 min'},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxContentWidth = 1200.0;
    // Align first card with the start of centered content
    final double startingPadding = screenWidth > maxContentWidth 
        ? (screenWidth - maxContentWidth) / 2 + 20 
        : 20.0;

    return SizedBox(
      height: 440,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: startingPadding, right: 40),
        clipBehavior: Clip.none, // Allow shadows to lift out of bounds
        itemCount: pharmacies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 30),
        itemBuilder: (context, index) {
          return _ServiceCard(
            data: pharmacies[index],
            bgImage: "assets/images/pharmcyLogo.png",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => PharmaciesScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

class LaboratorySlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> labs = [
      {'name': 'Chughtai Lab', 'rating': '4.9', 'location': 'Nationwide', 'time': 'Available 24/7'},
      {'name': 'Essa Laboratory', 'rating': '4.8', 'location': 'Karachi / Lahore', 'time': 'Home Sample'},
      {'name': 'IDC Laboratory', 'rating': '4.7', 'location': 'Twin Cities', 'time': 'PCR Experts'},
      {'name': 'Shifa Laboratory', 'rating': '4.9', 'location': 'Rawalpindi', 'time': 'Fast Results'},
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxContentWidth = 1200.0;
    final double startingPadding = screenWidth > maxContentWidth 
        ? (screenWidth - maxContentWidth) / 2 + 20 
        : 20.0;

    return SizedBox(
      height: 440,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: startingPadding, right: 40),
        clipBehavior: Clip.none,
        itemCount: labs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 30),
        itemBuilder: (context, index) {
          return _ServiceCard(
            data: labs[index],
            bgImage: "assets/images/lab1.png",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => LabsListScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Map<String, String> data;
  final String bgImage;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.data,
    required this.bgImage,
    required this.onTap,
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, _hovered ? -12.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.15 : 0.06),
                blurRadius: _hovered ? 35 : 20,
                offset: Offset(0, _hovered ? 15 : 8),
              ),
              if (_hovered)
                BoxShadow(
                  color: const Color(0xFF0036BC).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Stack(
                  children: [
                    AnimatedScale(
                      scale: _hovered ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: Image.asset(
                        widget.bgImage,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            CustomText(
                              text: widget.data['rating']!,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: widget.data['name']!,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: widget.data['location']!,
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0036BC).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.electric_bolt_rounded, size: 14, color: Color(0xFF0036BC)),
                              const SizedBox(width: 6),
                              CustomText(
                                text: widget.data['time']!,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0036BC),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0036BC).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF0036BC)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Specialty Grid ────────────────────────────────────────────────────────────
class SpecialtyGrid extends StatelessWidget {
  final List<Map<String, dynamic>> _specs = [
    {'title': 'Cardiology', 'sub': 'Heart Specialist', 'icon': Icons.favorite_rounded, 'color': Color(0xFFEF4444)},
    {'title': 'Dermatology', 'sub': 'Skin & Hair', 'icon': Icons.face_rounded, 'color': Color(0xFFF59E0B)},
    {'title': 'Pediatrics', 'sub': 'Child Care', 'icon': Icons.child_care_rounded, 'color': Color(0xFF10B981)},
    {'title': 'Neurology', 'sub': 'Brain & Nerves', 'icon': Icons.psychology_rounded, 'color': Color(0xFF8B5CF6)},
    {'title': 'Orthopedics', 'sub': 'Bone & Joints', 'icon': Icons.fitness_center_rounded, 'color': Color(0xFF64748B)},
    {'title': 'Psychiatry', 'sub': 'Mental Health', 'icon': Icons.self_improvement_rounded, 'color': Color(0xFFEC4899)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchOverlay(context, 'Search by Condition (e.g. Back Pain, Skin Rash)'),
        const SizedBox(height: 24),
        _CardGrid(
          items: _specs.map((s) => _CardData(
            title: s['title'],
            subtitle: s['sub'],
            icon: s['icon'],
            iconColor: s['color'],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DoctorsList()),
            ),
          )).toList(),
          cardWidth: 160,
          cardHeight: 140,
        ),
      ],
    );
  }
}

class _SpecialtyCard extends StatefulWidget {
  final String name;
  final String description;
  final IconData icon;
  final bool isViewAll;
  final double width;

  const _SpecialtyCard({
    required this.name,
    required this.description,
    required this.icon,
    this.isViewAll = false,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -3.0 : 0.0),
        decoration: BoxDecoration(
          color: widget.isViewAll ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered || widget.isViewAll
                ? const Color(0xFF14B1FF)
                : const Color(0xFFE8ECF5),
            width: 1.5,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.isViewAll
                    ? const Color(0xFFD0EEFF)
                    : const Color(0xFFE8F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: const Color(0xFF0036BC),
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.isViewAll
                    ? const Color(0xFF14B1FF)
                    : const Color(0xFF1A1A2E),
                fontFamily: 'Gilroy-Bold',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── How It Works Steps ──────────────────────────────────────────────────────
class HowItWorksSteps extends StatefulWidget {
  const HowItWorksSteps({super.key});

  @override
  State<HowItWorksSteps> createState() => _HowItWorksStepsState();
}

class _HowItWorksStepsState extends State<HowItWorksSteps> with SingleTickerProviderStateMixin {
  static const _steps = [
    {'num': '1', 'title': 'Search & Select', 'desc': 'Find the right doctor by specialty, condition, or name'},
    {'num': '2', 'title': 'Book Appointment', 'desc': 'Choose a convenient time slot and confirm your booking'},
    {'num': '3', 'title': 'Video Consult', 'desc': 'Connect via secure HD video call with your doctor'},
    {'num': '4', 'title': 'Get Prescription', 'desc': 'Receive digital prescriptions and follow-up care plans'},
  ];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 10 seconds total: finishes in about 8s, rests for 2s, repeats.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Map controller value 0..1 to an expanded range 0..5
              // progress 0..4 covers the 4 steps animation, 4..5 is the rest phase
              final double progress = (_controller.value * 5).clamp(0.0, 4.0);
              
              return Column(
                children: List.generate(_steps.length, (index) {
                  final double lineProgress = (progress - index).clamp(0.0, 1.0);
                  final bool isCircleActive = progress >= index;
                  final bool isCirclePassed = progress >= index + 1;
                  
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Timeline Column
                        SizedBox(
                          width: 60,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // Vertical Line (Progress Bar)
                              if (index < _steps.length - 1)
                                Positioned(
                                  top: 48, // start just below the circle
                                  bottom: -12, // stretch to exactly join the next circle below
                                  width: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8ECF5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: lineProgress,
                                        child: Container(
                                          width: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF14B1FF),
                                            borderRadius: BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFF14B1FF).withOpacity(0.5), blurRadius: 4),
                                            ]
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Step Circle
                              Positioned(
                                top: 4,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCircleActive ? const Color(0xFF0036BC) : Colors.white,
                                    border: Border.all(
                                      color: isCircleActive ? const Color(0xFF0036BC) : const Color(0xFFE8ECF5),
                                      width: 2,
                                    ),
                                    boxShadow: isCircleActive
                                        ? [BoxShadow(color: const Color(0xFF14B1FF).withOpacity(0.3), blurRadius: 10, spreadRadius: 3)]
                                        : [],
                                  ),
                                  child: Center(
                                    child: isCirclePassed
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            color: isCircleActive ? Colors.white : const Color(0xFF0F172A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'Gilroy-Bold',
                                          ),
                                          child: Text(_steps[index]['num']!),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Content Column
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: index < _steps.length - 1 ? 40 : 0, top: 12),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: isCircleActive ? 1.0 : 0.3,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                transform: Matrix4.translationValues(0, isCircleActive ? 0 : 10, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _steps[index]['title']!,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: isCircleActive ? const Color(0xFF0036BC) : const Color(0xFF0F172A),
                                        fontFamily: 'Gilroy-Bold',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _steps[index]['desc']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── App Download Banner ────────────────────────────────────────────────────────
// ── Testimonials Section ──────────────────────────────────────────────────────
class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});
  @override
  State<TestimonialsSection> createState() => TestimonialsSectionState();
}

class TestimonialsSectionState extends State<TestimonialsSection> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final List<Widget> _testimonials = _getTestimonialsData();

  @override
  void initState() {
    super.initState();
    // Start in the middle of a very large range to simulate infinite scroll
    _currentPage = 1000;
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 0.9);
    
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  static List<Widget> _getTestimonialsData() {
    return const [
      TestimonialCard(
        name: 'Umer Fayyaz',
        testimonial: 'Great platform, very efficient and works really well on both phone and web. I think this is the most easiest way of booking appointments in Pakistan as it has made the whole process much more efficient.',
        avatar: 'assets/images/testimonials/umer.png',
      ),
      TestimonialCard(
        name: 'Aneeb Ryan',
        testimonial: 'A very helpful app for booking appointments and searching for the required doctors. Has made my life a lot easy. I would strongly recommend this to all',
        avatar: 'assets/images/testimonials/aneeb.png',
      ),
      TestimonialCard(
        name: 'Zainab Tariq',
        testimonial: 'Literally the best website to book the appointments online for Doctors. The service is great, helpline guys are very cooperative and understanding. And I don\'t have to hassle through different hospitals anymore now.',
        isFallback: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 800;
    final viewFraction = isMobile ? 0.9 : 0.4;
    
    // Re-initialize controller if width changes significantly (simple responsive handling)
    if (_pageController.viewportFraction != viewFraction) {
       _pageController = PageController(initialPage: _currentPage, viewportFraction: viewFraction);
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
               RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 34, color: Color(0xFF1E293B), fontFamily: 'Gilroy-Bold', fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: 'Our Customers '),
                    TextSpan(text: 'love us', style: TextStyle(color: Color(0xFF0036BC))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Check out the reviews from our satisfied customers',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 60),
              SizedBox(
                height: 420,
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final itemIndex = index % _testimonials.length;
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                        }
                        return Transform.scale(
                          scale: Curves.easeOut.transform(value),
                          child: Opacity(
                            opacity: value.clamp(0.5, 1.0),
                            child: _testimonials[itemIndex],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_testimonials.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: (_currentPage % _testimonials.length) == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (_currentPage % _testimonials.length) == index 
                          ? const Color(0xFF0036BC) 
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String name;
  final String testimonial;
  final String? avatar;
  final bool isFallback;

  const TestimonialCard({
    required this.name,
    required this.testimonial,
    this.avatar,
    this.isFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
             color: const Color(0xFF0036BC).withOpacity(0.04),
             blurRadius: 20,
             offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 22)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Text(
              '"$testimonial"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF475569),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0036BC).withOpacity(0.1), width: 1),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: (avatar != null && !isFallback) ? AssetImage(avatar!) : null,
              child: isFallback ? const Icon(Icons.person, color: Color(0xFF64748B), size: 30) : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              fontFamily: 'Gilroy-Bold',
            ),
          ),
        ],
      ),
    );
  }
}

class AppDownloadBanner extends StatelessWidget {
  const AppDownloadBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 850;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isMobile ? _buildMobile() : _buildDesktop(),
        ),
      ),
    );
  }

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Centered text block just like the reference
            children: [
               RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 44, color: Color(0xFF1E293B), fontFamily: 'Gilroy-Bold', fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: 'Download the '),
                    TextSpan(text: 'iCare', style: TextStyle(color: Color(0xFF001B54))),
                    TextSpan(text: ' App'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Download iCare app today and avail exclusive\nhealth discounts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Color(0xFF475569), height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _StoreBadge(
                    icon: Icons.play_arrow_rounded, 
                    label: 'Google Play', 
                    subText: 'GET IT ON', 
                    iconColor: Color(0xFF00F176), // Green play tint
                  ),
                  SizedBox(width: 20),
                  _StoreBadge(
                    icon: Icons.apple, 
                    label: 'App Store', 
                    subText: 'Download on the',
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 550,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Diagonal vibrant blue blob matching website theme
                Positioned(
                  right: -150,
                  child: Transform.rotate(
                    angle: -0.55,
                    child: Container(
                      width: 800,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B1FF), Color(0xFF0036BC)],
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                  ),
                ),
                // Phone Mockup floating over it
                const Positioned(
                  top: 0,
                  bottom: 0,
                  child: _ModernPhoneMockup(scale: 1.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 34, color: Color(0xFF1E293B), fontFamily: 'Gilroy-Bold', fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: 'Download the\n'),
                    TextSpan(text: 'iCare', style: TextStyle(color: Color(0xFF001B54))),
                    TextSpan(text: ' App'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Download iCare app today and avail exclusive\nhealth discounts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: const [
                  _StoreBadge(icon: Icons.play_arrow_rounded, label: 'Google Play', subText: 'GET IT ON', iconColor: Color(0xFF00F176)),
                  _StoreBadge(icon: Icons.apple, label: 'App Store', subText: 'Download on the'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 60), // Extra space so the orange shape doesn't overlap text
        SizedBox(
          height: 450,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Transform.rotate(
                  angle: -0.55,
                  child: Container(
                    width: 700,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B1FF), Color(0xFF0036BC)],
                      ),
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                ),
              ),
              const _ModernPhoneMockup(scale: 0.85),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subText;
  final Color? iconColor;

  const _StoreBadge({required this.icon, required this.label, required this.subText, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 32),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subText,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Gilroy-Bold'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ModernPhoneMockup extends StatefulWidget {
  final double scale;
  const _ModernPhoneMockup({this.scale = 1.0});

  @override
  State<_ModernPhoneMockup> createState() => _ModernPhoneMockupState();
}

class _ModernPhoneMockupState extends State<_ModernPhoneMockup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 3 seconds duration for a slow, gentle floating / hovering effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    // Animate up and down by 15 pixels
    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value), // Vertical hovering movement
          child: Transform.scale(
            scale: widget.scale,
            child: Container(
              width: 250,
              height: 520,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: Offset(0, 10 - (_animation.value * 0.3)), // Dynamic shadow matching float
                  ),
                ],
                border: Border.all(color: const Color(0xFF1E293B), width: 8), // Elegant dark phone bezel
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/doctors/walkthrough1.png', 
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Section Header with subtitle ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
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
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class Footer extends StatelessWidget {
  const Footer({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ..._buildMobileFooter() else ..._buildDesktopFooter(),
          const SizedBox(height: 32),
          Divider(color: const Color(0xFF0036BC).withOpacity(0.1), thickness: 1),
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
                Row(
                  children: [
                    Image.asset(ImagePaths.logo, width: 36, height: 36),
                    const SizedBox(width: 10),
                    const Text(
                      'iCare Virtual Hospital',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Pakistan's leading virtual hospital platform. Connecting patients with top specialists for online consultations, lab tests, and digital prescriptions.",
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: _FooterColumn(
              title: 'For Patients',
              items: const [
                'Find a Doctor',
                'Book Lab Tests',
                'Order Medicines',
                'Health Records',
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: _FooterColumn(
              title: 'Support',
              items: const [
                'About Us',
                'Privacy Policy',
                'Terms of Service',
                'Contact Us',
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download iCare App',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Gilroy-Bold'),
                ),
                const SizedBox(height: 16),
                _FooterAppBadge(icon: Icons.apple, label: 'App Store', subText: 'Download on the'),
                const SizedBox(height: 12),
                _FooterAppBadge(icon: Icons.play_arrow_rounded, label: 'Google Play', subText: 'GET IT ON', iconColor: Color(0xFF00F176)),
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
          Image.asset(ImagePaths.logo, width: 32, height: 32),
          const SizedBox(width: 8),
          const Text(
            'iCare Virtual Hospital',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              fontFamily: 'Gilroy-Bold',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        "Pakistan's leading virtual hospital platform. Connecting patients with top specialists for online consultations, lab tests, and digital prescriptions.",
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF64748B),
          height: 1.6,
        ),
      ),
      const SizedBox(height: 24),
      _FooterColumn(
        title: 'For Patients',
        items: const [
          'Find a Doctor',
          'Book Lab Tests',
          'Order Medicines',
          'Health Records',
          'Teleconsultation',
        ],
      ),
      const SizedBox(height: 20),
      const SizedBox(height: 24),
      _FooterColumn(
        title: 'Support',
        items: const ['About Us', 'Privacy Policy', 'Contact Us'],
      ),
      const SizedBox(height: 24),
      const Text(
        'Download iCare App',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontFamily: 'Gilroy-Bold'),
      ),
      const SizedBox(height: 12),
      Row(
        children: const [
          Expanded(child: _FooterAppBadge(icon: Icons.apple, label: 'App Store', subText: 'Download on the')),
          SizedBox(width: 12),
          Expanded(child: _FooterAppBadge(icon: Icons.play_arrow_rounded, label: 'Google Play', subText: 'GET IT ON', iconColor: Color(0xFF00F176))),
        ],
      )
    ];
  }

  Widget _buildFooterBottom(bool isMobile) {
    return Column(
      children: [
        // Trust Badges Row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: isMobile 
            ? Column(
                children: const [
                  _TrustItem(icon: Icons.verified_user_outlined, title: 'Verified Doctors', subtitle: 'Authentic info'),
                  SizedBox(height: 16),
                  _TrustItem(icon: Icons.headset_mic_outlined, title: 'Reliable Support', subtitle: '7 days a week'),
                  SizedBox(height: 16),
                  _TrustItem(icon: Icons.security_outlined, title: 'Secure Payment', subtitle: 'SSL Certified'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _TrustItem(icon: Icons.verified_user_outlined, title: 'Verified Doctors', subtitle: 'Authentic & updated info'),
                  _TrustItem(icon: Icons.headset_mic_outlined, title: 'Reliable Customer Support', subtitle: '7 days a week'),
                  _TrustItem(icon: Icons.security_outlined, title: 'Secure Online Payment', subtitle: 'Secure checkout with SSL'),
                ],
              ),
        ),
        Divider(color: const Color(0xFF0036BC).withOpacity(0.1), thickness: 1),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '© 2015 - 2026 iCare. All Rights Reserved.',
              style: TextStyle(fontSize: 12, color: const Color(0xFF0036BC).withOpacity(0.5)),
            ),
            if (!isMobile)
              Row(
                children: [
                  Text('Connect with us', style: TextStyle(fontSize: 12, color: const Color(0xFF64748B))),
                  const SizedBox(width: 12),
                  ..._buildSocialIcons(),
                ],
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildSocialIcons()),
        ]
      ],
    );
  }

  List<Widget> _buildSocialIcons() {
    return const [
      _SocialIcon(icon: Icons.facebook, color: Color(0xFF1877F2)),
      _SocialIcon(icon: Icons.camera_alt_outlined, color: Color(0xFFE4405F)),
      _SocialIcon(icon: Icons.play_circle_fill_outlined, color: Color(0xFFFF0000)),
      _SocialIcon(icon: Icons.alternate_email, color: Colors.blue),
    ];
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _TrustItem({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF0036BC).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF0036BC), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        )
      ],
    );
  }
}

class _FooterAppBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subText;
  final Color? iconColor;

  const _FooterAppBadge({required this.icon, required this.label, required this.subText, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subText, style: const TextStyle(color: Colors.white, fontSize: 8),),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Gilroy-Bold'),),
            ],
          )
        ],
      ),
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
            color: Color(0xFF0F172A),
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
              color: const Color(0xFF64748B),
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
        const PublicBanner(),
        const SizedBox(height: 40),
        CenteredSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Browse by Specialty',
                subtitle: 'Find the right specialist for your health needs',
              ),
              const SizedBox(height: 24),
              SpecialtyGrid(),
              const SizedBox(height: 32),
              Center(
                child: NavButton(
                  label: 'See All Speciality',
                  filled: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DoctorsList()),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),
        const MedicalRecordsSection(),
        const SizedBox(height: 60),
        OrderMedicinesSection(),
        const SizedBox(height: 60),
        BookLabSection(),
        const SizedBox(height: 60),
        CoursesSection(),
        const SizedBox(height: 60),

        CenteredSection(
          child: Column(
            children: [
              SectionHeader(
                title: 'How iCare Works',
                subtitle: 'Get quality healthcare in 4 simple steps',
              ),
              const SizedBox(height: 40),
              HowItWorksSteps(),
            ],
          ),
        ),
        const SizedBox(height: 60),
        const TestimonialsSection(),
        const SizedBox(height: 60),
        const AppDownloadBanner(),
        const SizedBox(height: 60),
        Footer(),
      ],
    );
  }
}
