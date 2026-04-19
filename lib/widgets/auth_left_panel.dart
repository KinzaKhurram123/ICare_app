import 'package:flutter/material.dart';

/// Shared branded left panel used on all auth screens.
/// Matches the login screen exactly: iCare logo, RM Health Solution branding,
/// and 4 improved trust badges with subtitles.
class AuthLeftPanel extends StatelessWidget {
  const AuthLeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Container(
      height: h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF001E6C), Color(0xFF0036BC), Color(0xFF035BE5)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -100, right: -50,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo card
                  Container(
                    width: 110, height: 110,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 24),

                  // iCare title
                  const Text(
                    'iCare',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // RM Health Solution subtitle
                  Text(
                    'by RM Health Solution',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // RM Health Solution logo image
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/health.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tagline
                  Text(
                    'Your Trusted Healthcare Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure consultations, prescriptions\n& health records',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  const SizedBox(height: 28),

                  // 4 Trust badges — improved with subtitles
                  _trust(
                    Icons.shield_rounded,
                    'Data Protected & Secure',
                    'End-to-end encrypted health records',
                  ),
                  const SizedBox(height: 18),
                  _trust(
                    Icons.verified_user_rounded,
                    'Verified Doctors Only',
                    'All providers are PMDC credentialed',
                  ),
                  const SizedBox(height: 18),
                  _trust(
                    Icons.medical_services_rounded,
                    'Complete Virtual Hospital',
                    'Consult, prescribe & manage all-in-one',
                  ),
                  const SizedBox(height: 18),
                  _trust(
                    Icons.people_rounded,
                    'Trusted Nationwide',
                    'Thousands of patients across Pakistan',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trust(IconData icon, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42, height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
