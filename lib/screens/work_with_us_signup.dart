import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';

class WorkWithUsSignup extends ConsumerWidget {
  const WorkWithUsSignup({super.key});

  static const List<Map<String, dynamic>> _roles = [
    {
      'role': 'Doctor',
      'title': 'Join as Doctor',
      'subtitle': 'Manage patients & conduct consultations',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF0036BC),
    },
    {
      'role': 'Pharmacy',
      'title': 'Join as Pharmacy',
      'subtitle': 'Manage prescriptions & medicine orders',
      'icon': Icons.local_pharmacy_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'role': 'Laboratory',
      'title': 'Join as Lab',
      'subtitle': 'Manage lab tests & upload reports',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0036BC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(ImagePaths.logo, width: 32, height: 32),
            const SizedBox(width: 8),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your role',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                fontFamily: 'Gilroy-Bold',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select how you want to join the iCare platform',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Gilroy-Medium'),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final r = _roles[i];
                  final color = r['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(initialSignup: true, initialRole: r['role'] as String),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(r['icon'] as IconData, color: color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                    fontFamily: 'Gilroy-Bold',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontFamily: 'Gilroy-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
