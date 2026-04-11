import 'package:flutter/material.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/work_with_us_signup.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';

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
      body: CustomScrollView(
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
                _Banner(),
                const SizedBox(height: 40),

                // Browse by Specialty Section
                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Browse by Specialty',
                        subtitle: 'Find the right specialist for your health needs',
                      ),
                      const SizedBox(height: 24),
                      _SpecialtyGrid(),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // How it Works Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 60),
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

                const SizedBox(height: 40),

                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Connect To Doctor',
                        subtitle: 'Talk to verified doctors within minutes',
                      ),
                      const SizedBox(height: 16),
                      _CardGrid(
                        items: _doctors.map((d) => _CardData(
                          title: d['name']!,
                          subtitle: d['spec']!,
                          imageUrl: d['img'],
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF0036BC),
                        )).toList(),
                        cardWidth: 140,
                        cardHeight: 180,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Pharmacies',
                        subtitle: 'Order medicines from trusted pharmacies',
                      ),
                      const SizedBox(height: 16),
                      _CardGrid(
                        items: _pharmacies.map((p) => _CardData(
                          title: p['name']!,
                          subtitle: p['area']!,
                          icon: Icons.local_pharmacy_rounded,
                          iconColor: const Color(0xFF10B981),
                          iconBg: const Color(0xFFD1FAE5),
                        )).toList(),
                        cardWidth: 160,
                        cardHeight: 120,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                _CenteredSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Laboratories',
                        subtitle: 'Book lab tests from certified laboratories',
                      ),
                      const SizedBox(height: 16),
                      _CardGrid(
                        items: _labs.map((l) => _CardData(
                          title: l['name']!,
                          subtitle: l['area']!,
                          icon: Icons.biotech_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBg: const Color(0xFFEDE9FE),
                        )).toList(),
                        cardWidth: 160,
                        cardHeight: 120,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
                _Footer(),
              ],
            ),
          ),
        ],
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
class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = w < 600 ? 200.0 : (w < 900 ? 300.0 : 480.0);
    return SizedBox(
      width: double.infinity,
      height: h,
      child: Image.asset(
        'assets/images/icare-banenr.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => Container(
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0036BC), Color(0xFF14B1FF)],
            ),
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
    {'name': 'Gynecologist', 'desc': "Women's Health", 'icon': Icons.pregnant_woman},
    {'name': 'View All', 'desc': '50+ Specialties', 'icon': Icons.grid_view, 'isViewAll': true},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: _specialties.map((spec) {
          final isViewAll = spec['isViewAll'] == true;
          return _SpecialtyCard(
            name: spec['name'] as String,
            description: spec['desc'] as String,
            icon: spec['icon'] as IconData,
            isViewAll: isViewAll,
            width: isMobile ? 100 : 120,
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0036BC), Color(0xFF0049E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const Text(
          'Download the iCare App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Gilroy-Bold',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Get instant access to 500+ doctors, lab results, prescriptions, and health records — all in one place.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _AppBadges(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download the iCare App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Gilroy-Bold',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Get instant access to 500+ doctors, lab results,\nprescriptions, and health records — all in one place.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              _AppBadges(),
            ],
          ),
        ),
        const SizedBox(width: 40),
        _PhoneMockups(),
      ],
    );
  }
}

class _AppBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _AppBadge(
          label: 'App Store',
          icon: Icons.apple,
        ),
        _AppBadge(
          label: 'Google Play',
          icon: Icons.play_arrow_rounded,
        ),
      ],
    );
  }
}

class _AppBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AppBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.32),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneMockups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PhoneMock(height: 120),
        const SizedBox(width: 12),
        _PhoneMock(height: 140),
      ],
    );
  }
}

class _PhoneMock extends StatelessWidget {
  final double height;
  const _PhoneMock({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Spacer(),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header with subtitle ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

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
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    
    return Container(
      color: const Color(0xFF0A1A4A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ..._buildMobileFooter() else ..._buildDesktopFooter(),
          const SizedBox(height: 32),
          const Divider(color: Color(0x1AFFFFFF), thickness: 1),
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
                        color: Colors.white,
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
                    color: Colors.white.withOpacity(0.7),
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
                'Teleconsultation',
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: _FooterColumn(
              title: 'For Doctors',
              items: const [
                'Join iCare',
                'Doctor Login',
                'Practice Management',
                'Analytics',
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: _FooterColumn(
              title: 'Company',
              items: const [
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
          Image.asset(ImagePaths.logo, width: 32, height: 32),
          const SizedBox(width: 8),
          const Text(
            'iCare Virtual Hospital',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
          color: Colors.white.withOpacity(0.7),
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
      _FooterColumn(
        title: 'For Doctors',
        items: const [
          'Join iCare',
          'Doctor Login',
          'Practice Management',
          'Analytics',
        ],
      ),
      const SizedBox(height: 20),
      _FooterColumn(
        title: 'Company',
        items: const [
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
            '© 2026 iCare Virtual Hospital. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Karachi, Pakistan',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
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
          '© 2026 iCare Virtual Hospital. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        Text(
          'Karachi, Pakistan',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
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
            color: Colors.white,
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
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        )),
      ],
    );
  }
}
