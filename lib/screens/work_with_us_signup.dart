import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/screens/signup.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/auth_left_panel.dart';

class WorkWithUsSignup extends StatelessWidget {
  const WorkWithUsSignup({super.key});

  static const List<Map<String, dynamic>> _roles = [
    {
      'role': 'Doctor',
      'title': 'Doctor',
      'subtitle': 'Manage Patients & Prescriptions',
      'desc': 'Join as a verified healthcare provider',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF0036BC),
    },
    {
      'role': 'Pharmacy',
      'title': 'Pharmacy',
      'subtitle': 'Prescription Fulfillment',
      'desc': 'Serve patients with medicines & healthcare products',
      'icon': Icons.local_pharmacy_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'role': 'Laboratory',
      'title': 'Laboratory',
      'subtitle': 'Diagnostics & Reports',
      'desc': 'Provide diagnostic tests and lab services',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  // ── Desktop: split panel ─────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 5, child: AuthLeftPanel()),
        Expanded(flex: 5, child: _buildRightPanel(context)),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFD),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Container(
            width: 480,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0036BC).withOpacity(0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go('/home');
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF0B2D6E),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Join as a Provider',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B2D6E),
                    fontFamily: 'Gilroy-Bold',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select how you want to join the iCare platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Gilroy-Medium',
                  ),
                ),
                const SizedBox(height: 32),
                ..._roles.map((r) => _roleCard(context, r)),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Gilroy-Medium',
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Gilroy-Bold',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, Map<String, dynamic> r) {
    final color = r['color'] as Color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SignupScreen(role: r['role'] as String),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(r['icon'] as IconData, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                        fontFamily: 'Gilroy-SemiBold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r['desc'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontFamily: 'Gilroy-Medium',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile: simple scrollable layout ─────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go('/home');
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0B2D6E)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Work With Us',
                  style: TextStyle(
                    color: Color(0xFF0036BC),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Gilroy-Bold',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose your role',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Gilroy-Bold',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select how you want to join the iCare platform',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500], fontFamily: 'Gilroy-Medium'),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: _roles.map((r) => _roleCard(context, r)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
