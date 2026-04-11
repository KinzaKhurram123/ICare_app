import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/create_profile.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/pharmacy_profile_setup.dart';
import 'package:icare/screens/lab_profile_setup.dart';
import 'package:icare/screens/instructor_profile_setup.dart';
import 'package:icare/screens/student_profile_setup.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/services/laboratory_service.dart';
import 'package:icare/services/instructor_service.dart';
import 'package:icare/utils/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _roleProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) setState(() => _isLoading = true);
    final role = ref.read(authProvider).userRole;

    try {
      final userResult = await UserService().getUserProfile();
      if (userResult['success'] == true) {
        _profileData = Map<String, dynamic>.from(userResult['user'] as Map);
      }

      try {
        if (role == 'Doctor') {
          final result = await DoctorService().getStats();
          if (result['success'] == true) _roleProfile = Map<String, dynamic>.from(result['stats'] as Map);
        } else if (role == 'Pharmacy') {
          _roleProfile = Map<String, dynamic>.from(await PharmacyService().getPharmacyProfile());
        } else if (role == 'Laboratory') {
          _roleProfile = Map<String, dynamic>.from(await LaboratoryService().getProfile());
        } else if (role == 'Instructor') {
          _roleProfile = Map<String, dynamic>.from(await InstructorService().getMyProfile());
        }
      } catch (_) {}
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _editScreen(String role) {
    switch (role) {
      case 'Doctor': return const DoctorProfileSetup();
      case 'Pharmacy': return const PharmacyProfileSetup();
      case 'Laboratory': return const LabProfileSetup();
      case 'Instructor': return const InstructorProfileSetupScreen();
      case 'Student': return StudentProfileSetup();
      default: return const CreateProfile(isEdit: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).userRole;
    final user = ref.watch(authProvider).user;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profileData == null && user == null) {
      return _CreateProfilePrompt(
        role: role,
        onCreate: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => _editScreen(role)))
            .then((_) => _loadProfile()),
      );
    }

    return _ProfileView(
      profileData: _profileData,
      roleProfile: (role == 'Patient' || role == 'Student') ? _profileData : _roleProfile,
      role: role,
      fallbackName: user?.name ?? '',
      fallbackEmail: user?.email ?? '',
      fallbackPhone: user?.phoneNumber ?? '',
      onEdit: () async {
        final updated = await Navigator.of(context)
            .push<Map<String, dynamic>>(MaterialPageRoute(builder: (_) => _editScreen(role)));
        if (updated != null && mounted) {
          setState(() => _profileData = Map<String, dynamic>.from(updated));
        }
      },
    );
  }
}

// ─── Profile View ─────────────────────────────────────────────────────────────
class _ProfileView extends StatelessWidget {
  final Map<String, dynamic>? profileData;
  final Map<String, dynamic>? roleProfile;
  final String role;
  final String fallbackName;
  final String fallbackEmail;
  final String fallbackPhone;
  final Future<void> Function() onEdit;

  const _ProfileView({
    required this.profileData,
    required this.roleProfile,
    required this.role,
    required this.fallbackName,
    required this.fallbackEmail,
    required this.fallbackPhone,
    required this.onEdit,
  });

  String get _name => (profileData?['name'] as String?)?.isNotEmpty == true ? profileData!['name'] : fallbackName;
  String get _email => (profileData?['email'] as String?) ?? fallbackEmail;
  String get _phone => (profileData?['phoneNumber'] as String?) ?? fallbackPhone;
  String get _bio => (profileData?['bio'] as String?) ?? '';
  String get _age => (profileData?['age'] as String?) ?? '';
  String get _qualification => (profileData?['qualification'] as String?) ?? '';

  @override
  Widget build(BuildContext context) {
    final Color roleColor = _roleColor(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [roleColor, roleColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    backgroundImage: (profileData?['profileImage'] as String?)?.isNotEmpty == true
                        ? MemoryImage(_tryDecodeBase64(profileData!['profileImage']))
                        : null,
                    child: (profileData?['profileImage'] as String?)?.isNotEmpty == true
                        ? null
                        : Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_roleLabel(role),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 180, height: 44,
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                      label: const Text('Edit Profile',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: const BorderSide(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact card — always shown
                  _card('Contact Information', [
                    if (_email.isNotEmpty) _row(Icons.email_outlined, 'Email', _email),
                    if (_phone.isNotEmpty) _row(Icons.phone_outlined, 'Phone', _phone),
                  ]),

                  // Patient/Student extra details
                  if (role == 'Patient' || role == 'Student') ...[
                    const SizedBox(height: 16),
                    _card('Profile Details', [
                      if (_bio.isNotEmpty) _row(Icons.description_outlined, 'Bio', _bio),
                      if (_age.isNotEmpty) _row(Icons.cake_outlined, 'Age', _age),
                      if (_qualification.isNotEmpty) _row(Icons.school_outlined, 'Qualification', _qualification),
                      if (_bio.isEmpty && _age.isEmpty && _qualification.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Tap Edit Profile to add your details.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        ),
                    ]),
                  ],

                  // Role-specific details for other roles
                  if (role != 'Patient' && role != 'Student' && roleProfile != null && roleProfile!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _card('${_roleLabel(role)} Details', _buildRoleRows(role, roleProfile!)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleRows(String role, Map<String, dynamic> rp) {
    final rows = <Widget>[];
    switch (role) {
      case 'Doctor':
        if (_str(rp['specialization']).isNotEmpty) rows.add(_row(Icons.medical_services_outlined, 'Specialization', _str(rp['specialization'])));
        if (_str(rp['experience']).isNotEmpty) rows.add(_row(Icons.work_outline, 'Experience', '${_str(rp['experience'])} years'));
        if (_str(rp['clinicName']).isNotEmpty) rows.add(_row(Icons.local_hospital_outlined, 'Clinic', _str(rp['clinicName'])));
        if (_str(rp['clinicAddress']).isNotEmpty) rows.add(_row(Icons.location_on_outlined, 'Address', _str(rp['clinicAddress'])));
        if (_str(rp['licenseNumber']).isNotEmpty) rows.add(_row(Icons.badge_outlined, 'License', _str(rp['licenseNumber'])));
        break;
      case 'Pharmacy':
        if (_str(rp['ownerName']).isNotEmpty) rows.add(_row(Icons.person_outline, 'Owner', _str(rp['ownerName'])));
        if (_str(rp['address']).isNotEmpty) rows.add(_row(Icons.location_on_outlined, 'Address', _str(rp['address'])));
        if (_str(rp['city']).isNotEmpty) rows.add(_row(Icons.location_city_outlined, 'City', _str(rp['city'])));
        if (_str(rp['licenseNumber']).isNotEmpty) rows.add(_row(Icons.badge_outlined, 'License', _str(rp['licenseNumber'])));
        if (rp['openHours'] != null) {
          final oh = rp['openHours'] as Map;
          rows.add(_row(Icons.access_time_outlined, 'Hours', '${oh['from']} – ${oh['to']}'));
        }
        if (rp['deliveryAvailable'] == true) rows.add(_row(Icons.delivery_dining_outlined, 'Delivery', 'Available'));
        break;
      case 'Laboratory':
        if (_str(rp['labName']).isNotEmpty) rows.add(_row(Icons.science_outlined, 'Lab Name', _str(rp['labName'])));
        if (_str(rp['ownerName']).isNotEmpty) rows.add(_row(Icons.person_outline, 'Owner', _str(rp['ownerName'])));
        if (_str(rp['city']).isNotEmpty) rows.add(_row(Icons.location_city_outlined, 'City', _str(rp['city'])));
        if (_str(rp['address']).isNotEmpty) rows.add(_row(Icons.location_on_outlined, 'Address', _str(rp['address'])));
        if (rp['workingHours'] != null) {
          final wh = rp['workingHours'] as Map;
          rows.add(_row(Icons.access_time_outlined, 'Hours', '${wh['from']} – ${wh['to']}'));
        }
        if (rp['homeSampleAvailable'] == true) rows.add(_row(Icons.home_outlined, 'Home Sample', 'Available'));
        break;
      case 'Instructor':
        if (_str(rp['bio']).isNotEmpty) rows.add(_row(Icons.description_outlined, 'Bio', _str(rp['bio'])));
        if (_str(rp['expertise']).isNotEmpty) rows.add(_row(Icons.school_outlined, 'Expertise', _str(rp['expertise'])));
        if (rp['totalCourses'] != null) rows.add(_row(Icons.menu_book_outlined, 'Programs', '${rp['totalCourses']}'));
        break;
    }
    if (rows.isEmpty) {
      rows.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No details available.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
      ));
    }
    return rows;
  }

  String _str(dynamic v) => v?.toString() ?? '';

  Uint8List _tryDecodeBase64(String data) {
    try {
      final base64Str = data.contains(',') ? data.split(',').last : data;
      return base64Decode(base64Str);
    } catch (_) {
      return Uint8List(0);
    }
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Doctor': return const Color(0xFF3B82F6);
      case 'Pharmacy': return const Color(0xFF10B981);
      case 'Laboratory': return const Color(0xFF0B2D6E);
      case 'Instructor': return const Color(0xFF8B5CF6);
      case 'Student': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6366F1);
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'Laboratory': return 'LAB TECHNICIAN';
      case 'Pharmacy': return 'PHARMACIST';
      default: return role.toUpperCase();
    }
  }
}

// ─── Create Profile Prompt ────────────────────────────────────────────────────
class _CreateProfilePrompt extends StatelessWidget {
  final String role;
  final VoidCallback onCreate;
  const _CreateProfilePrompt({required this.role, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.account_circle_rounded, size: 72, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 32),
              const Text('Complete Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Set up your profile to get the most out of iCare.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B)), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: onCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Create Profile',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
