import 'package:flutter/material.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';

class PublicHome extends StatelessWidget {
  const PublicHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Sign In button
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: true,
            toolbarHeight: 80,
            flexibleSpace: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1920),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 60 : 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Logo
                    Row(
                      children: [
                        Image.asset(ImagePaths.logo, width: 45, height: 45),
                        const SizedBox(width: 12),
                        const Text(
                          'iCare',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryColor,
                            fontFamily: 'Gilroy-Bold',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Sign In Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : 24,
                          vertical: isDesktop ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy-Bold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1920),
                child: Column(
                  children: [
                    // Hero Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: isDesktop ? 80 : 40,
                      ),
                      child: isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
                    ),

                    // Services Section
                    Container(
                      color: const Color(0xFFF8FAFC),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: isDesktop ? 80 : 40,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Our Services',
                            style: TextStyle(
                              fontSize: isDesktop ? 36 : 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              fontFamily: 'Gilroy-Bold',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Complete healthcare ecosystem at your fingertips',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.grey[600],
                              fontFamily: 'Gilroy-Medium',
                            ),
                          ),
                          SizedBox(height: isDesktop ? 60 : 40),
                          isDesktop
                              ? Row(
                                  children: [
                                    Expanded(child: _buildServiceCard(
                                      Icons.medical_services_rounded,
                                      'Doctor Consultations',
                                      'Connect with qualified doctors via video calls',
                                      const Color(0xFF3B82F6),
                                    )),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildServiceCard(
                                      Icons.science_rounded,
                                      'Lab Tests',
                                      'Book lab tests and get reports online',
                                      const Color(0xFF8B5CF6),
                                    )),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildServiceCard(
                                      Icons.local_pharmacy_rounded,
                                      'Pharmacy',
                                      'Order medicines with prescription',
                                      const Color(0xFF10B981),
                                    )),
                                    const SizedBox(width: 24),
                                    Expanded(child: _buildServiceCard(
                                      Icons.school_rounded,
                                      'Learning',
                                      'Access health courses and programs',
                                      const Color(0xFFF59E0B),
                                    )),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildServiceCard(
                                      Icons.medical_services_rounded,
                                      'Doctor Consultations',
                                      'Connect with qualified doctors via video calls',
                                      const Color(0xFF3B82F6),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildServiceCard(
                                      Icons.science_rounded,
                                      'Lab Tests',
                                      'Book lab tests and get reports online',
                                      const Color(0xFF8B5CF6),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildServiceCard(
                                      Icons.local_pharmacy_rounded,
                                      'Pharmacy',
                                      'Order medicines with prescription',
                                      const Color(0xFF10B981),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildServiceCard(
                                      Icons.school_rounded,
                                      'Learning',
                                      'Access health courses and programs',
                                      const Color(0xFFF59E0B),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),

                    // CTA Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: isDesktop ? 80 : 40,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to get started?',
                            style: TextStyle(
                              fontSize: isDesktop ? 36 : 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              fontFamily: 'Gilroy-Bold',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Join thousands of users managing their health with iCare',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.grey[600],
                              fontFamily: 'Gilroy-Medium',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isDesktop ? 40 : 32),
                          SizedBox(
                            width: isDesktop ? 300 : double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const SelectUserType()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Gilroy-Bold',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      color: const Color(0xFF0F172A),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: 40,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(ImagePaths.logo, width: 40, height: 40),
                              const SizedBox(width: 12),
                              const Text(
                                'iCare',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'Gilroy-Bold',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '© 2026 iCare. All rights reserved.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                              fontFamily: 'Gilroy-Medium',
                            ),
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
      ),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Complete',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Gilroy-Bold',
                  height: 1.1,
                ),
              ),
              const Text(
                'Healthcare Platform',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                  fontFamily: 'Gilroy-Bold',
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Connect with doctors, book lab tests, order medicines, and access health programs - all in one place.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontFamily: 'Gilroy-Medium',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SelectUserType()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy-Bold',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Scroll to services section
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Gilroy-Bold',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF001E6C),
                  Color(0xFF0036BC),
                  Color(0xFF035BE5),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                Icons.medical_services_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Your Complete Healthcare Platform',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Connect with doctors, book lab tests, order medicines, and access health programs.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Gilroy-Medium',
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectUserType()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy-Bold',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              fontFamily: 'Gilroy-Bold',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontFamily: 'Gilroy-Medium',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
