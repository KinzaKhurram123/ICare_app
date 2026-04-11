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

                // Consult Online Section (Doctors Slider)
                Container(
                  color: const Color(0xFFF4F8FF),
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: _CenteredSection(
                    child: Column(
                      children: [
                        _SectionHeader(
                          title: 'Consult Online',
                          subtitle: 'Talk to verified doctors within minutes from the comfort of your home',
                        ),
                        const SizedBox(height: 40),
                        _DoctorsSlider(),
                      ],
                    ),
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

// ── Doctors Slider ───────────────────────────────────────────────────────────
class _DoctorsSlider extends StatefulWidget {
  @override
  State<_DoctorsSlider> createState() => _DoctorsSliderState();
}

class _DoctorsSliderState extends State<_DoctorsSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _doctors = [
    {'name': 'Dr. Ahmed Khan', 'spec': 'Cardiologist', 'exp': '15 years experience', 'rating': '4.9', 'reviews': '342', 'fee': 'Rs. 1,200', 'img': 'https://xsgames.co/randomusers/assets/avatars/male/32.jpg'},
    {'name': 'Dr. Sara Malik', 'spec': 'Gynecologist', 'exp': '12 years experience', 'rating': '4.8', 'reviews': '289', 'fee': 'Rs. 1,000', 'img': 'https://xsgames.co/randomusers/assets/avatars/female/44.jpg'},
    {'name': 'Dr. Bilal Ahmed', 'spec': 'Neurologist', 'exp': '10 years experience', 'rating': '4.7', 'reviews': '198', 'fee': 'Rs. 1,500', 'img': 'https://xsgames.co/randomusers/assets/avatars/male/45.jpg'},
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
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: visibleDoctors.map((doctor) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
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
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF0036BC) : Colors.grey[300],
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF0036BC).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey[500],
          size: 20,
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
        width: 220,
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF14B1FF),
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: Image.network(
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
                ),
              ),
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
                onPressed: () {},
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
                    fontSize: 12.5,
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
        alignment: isMobile ? WrapAlignment.center : WrapAlignment.center,
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
        Container(
          color: const Color(0xFFF4F8FF),
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: _CenteredSection(
            child: Column(
              children: [
                _SectionHeader(
                  title: 'Consult Online',
                  subtitle:
                      'Talk to verified doctors within minutes from the comfort of your home',
                ),
                const SizedBox(height: 40),
                _DoctorsSlider(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 60),
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
        _AppDownloadBanner(),
        const SizedBox(height: 40),
        _Footer(),
      ],
    );
  }
}
