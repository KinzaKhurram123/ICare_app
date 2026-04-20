import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/about_us.dart';
import 'package:icare/screens/change_password.dart';
import 'package:icare/screens/courses.dart' show Courses;
import 'package:icare/screens/help_and_support.dart';
import 'package:icare/screens/notification_settings.dart';
import 'package:icare/screens/privacy_policy.dart';
import 'package:icare/screens/profile_edit.dart';
import 'package:icare/screens/terms_and_conditions.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/services/security_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SecurityService _securityService = SecurityService();
  bool _is2FAEnabled = false;
  bool _isBiometricEnabled = true;

  Future<void> _toggle2FA(bool value) async {
    try {
      if (value) {
        final data = await _securityService.enable2FA();
        _show2FAConfirmationDialog(data['qrCodeUrl'] ?? '');
      } else {
        await _securityService.disable2FA();
        setState(() => _is2FAEnabled = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  void _show2FAConfirmationDialog(String qrUrl) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable 2FA', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan this QR code with your authenticator app (e.g., Google Authenticator).'),
            const SizedBox(height: 16),
            Container(
              width: 150, height: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.qr_code_2_rounded, size: 100),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter 6-digit code',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final verified = await _securityService.verify2FA(codeController.text);
              if (verified) {
                setState(() => _is2FAEnabled = true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA Enabled Successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid code, try again.')),
                );
              }
            },
            child: const Text('Verify & Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometrics(bool value) async {
    try {
      await _securityService.updateBiometricPreference(value);
      setState(() => _isBiometricEnabled = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).setUserLogout();
    context.go('/login');
  }

  void _showReportIssueDialog(BuildContext ctx) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.bug_report_outlined, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text('Report an Issue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Describe the issue you encountered. Our team will review it shortly.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Issue Title',
                    hintText: 'e.g. Login not working',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell us what happened and how to reproduce it...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Issue reported. Thank you — we will get back to you shortly.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0036BC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext ctx, String feature) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFFF59E0B), size: 22),
            const SizedBox(width: 10),
            Text(feature, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: const Text('This feature is coming soon. Stay tuned for updates!'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.read(authProvider).userRole ?? '';
    final isPatient = role == 'Patient';
    final isPharmacy = role == 'Pharmacy';
    final isLaboratory = role == 'Laboratory';
    final isDoctor = role == 'Doctor';

    // Sections: each section has a title + list of items
    final List<_SettingsSection> sections = [
      // Profile & Account
      _SettingsSection(
        title: 'Profile & Account',
        icon: Icons.manage_accounts_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBg: const Color(0xFFEEF2FF),
        items: [
          _SettingsItem(
            title: 'Edit Profile',
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Change Password',
            icon: Icons.lock_outline_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChangePassword()),
            ),
          ),
        ],
      ),

      // Reminders & Notifications
      _SettingsSection(
        title: 'Reminders & Notifications',
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBg: const Color(0xFFEFF6FF),
        items: [
          _SettingsItem(
            title: 'Notification Preferences',
            icon: Icons.notifications_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationSettings()),
            ),
          ),
        ],
      ),

      // Security
      _SettingsSection(
        title: 'Security',
        icon: Icons.security_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
        items: [
          _SettingsItem(
            title: 'Two-Factor Authentication',
            icon: Icons.verified_user_outlined,
            isToggle: true,
            toggleValue: _is2FAEnabled,
            onToggle: _toggle2FA,
          ),
          _SettingsItem(
            title: 'Biometric Authentication',
            icon: Icons.fingerprint_rounded,
            isToggle: true,
            toggleValue: _isBiometricEnabled,
            onToggle: _toggleBiometrics,
          ),
        ],
      ),

      // Privacy & Data (removed Privacy Policy for patients per client request)
      if (!isPatient)
        _SettingsSection(
          title: 'Privacy & Data',
          icon: Icons.shield_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFF5F3FF),
          items: [
            _SettingsItem(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PrivacyPolicy()),
              ),
            ),
          ],
        ),

      // About & Legal (removed for patients per client request)
      if (!isPatient)
        _SettingsSection(
          title: 'About & Legal',
          icon: Icons.info_rounded,
          iconColor: const Color(0xFFF59E0B),
          iconBg: const Color(0xFFFEF3C7),
          items: [
            _SettingsItem(
              title: 'About iCare',
              icon: Icons.info_outline_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AboutUs()),
              ),
            ),
            _SettingsItem(
              title: 'Terms & Conditions',
              icon: Icons.gavel_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TermsAndConditions()),
              ),
            ),
          ],
        ),

      // Health Profile — Patient only
      if (isPatient)
        _SettingsSection(
          title: 'Health Profile',
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFEF4444),
          iconBg: const Color(0xFFFEF2F2),
          items: [
            _SettingsItem(
              title: 'Medical Conditions',
              icon: Icons.medical_information_outlined,
              onTap: () => _comingSoon(context, 'Medical Conditions'),
            ),
            _SettingsItem(
              title: 'Allergies',
              icon: Icons.warning_amber_rounded,
              onTap: () => _comingSoon(context, 'Allergies'),
            ),
            _SettingsItem(
              title: 'Current Medications',
              icon: Icons.medication_outlined,
              onTap: () => _comingSoon(context, 'Current Medications'),
            ),
            _SettingsItem(
              title: 'Health Goals',
              icon: Icons.flag_outlined,
              onTap: () => _comingSoon(context, 'Health Goals'),
            ),
          ],
        ),

      // Pharmacy Business Settings — Pharmacy only
      if (isPharmacy)
        _SettingsSection(
          title: 'Pharmacy Business Settings',
          icon: Icons.store_rounded,
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFFECFDF5),
          items: [
            _SettingsItem(
              title: 'Business Hours',
              icon: Icons.access_time_rounded,
              onTap: () => _comingSoon(context, 'Business Hours'),
            ),
            _SettingsItem(
              title: 'Delivery Settings',
              icon: Icons.local_shipping_outlined,
              onTap: () => _comingSoon(context, 'Delivery Settings'),
            ),
            _SettingsItem(
              title: 'Inventory Alerts',
              icon: Icons.inventory_2_outlined,
              onTap: () => _comingSoon(context, 'Inventory Alerts'),
            ),
            _SettingsItem(
              title: 'Order Notifications',
              icon: Icons.notifications_active_outlined,
              onTap: () => _comingSoon(context, 'Order Notifications'),
            ),
            _SettingsItem(
              title: 'Payment Methods',
              icon: Icons.payment_rounded,
              onTap: () => _comingSoon(context, 'Payment Methods'),
            ),
            _SettingsItem(
              title: 'License & Compliance',
              icon: Icons.verified_outlined,
              onTap: () => _comingSoon(context, 'License & Compliance'),
            ),
          ],
        ),

      // Laboratory Settings — Laboratory only
      if (isLaboratory)
        _SettingsSection(
          title: 'Laboratory Settings',
          icon: Icons.science_rounded,
          iconColor: const Color(0xFF06B6D4),
          iconBg: const Color(0xFFECFEFF),
          items: [
            _SettingsItem(
              title: 'Test Catalog',
              icon: Icons.list_alt_rounded,
              onTap: () => _comingSoon(context, 'Test Catalog'),
            ),
            _SettingsItem(
              title: 'Sample Collection Settings',
              icon: Icons.medical_services_outlined,
              onTap: () => _comingSoon(context, 'Sample Collection Settings'),
            ),
            _SettingsItem(
              title: 'Report Delivery Settings',
              icon: Icons.description_outlined,
              onTap: () => _comingSoon(context, 'Report Delivery Settings'),
            ),
            _SettingsItem(
              title: 'Lab Timings',
              icon: Icons.schedule_rounded,
              onTap: () => _comingSoon(context, 'Lab Timings'),
            ),
            _SettingsItem(
              title: 'Equipment Management',
              icon: Icons.biotech_outlined,
              onTap: () => _comingSoon(context, 'Equipment Management'),
            ),
            _SettingsItem(
              title: 'Accreditation & Certifications',
              icon: Icons.workspace_premium_outlined,
              onTap: () => _comingSoon(context, 'Accreditation & Certifications'),
            ),
          ],
        ),

      // Doctor Professional Settings — Doctor only
      if (isDoctor)
        _SettingsSection(
          title: 'Professional Settings',
          icon: Icons.medical_information_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFF5F3FF),
          items: [
            _SettingsItem(
              title: 'Consultation Fees',
              icon: Icons.attach_money_rounded,
              onTap: () => _comingSoon(context, 'Consultation Fees'),
            ),
            _SettingsItem(
              title: 'Availability & Schedule',
              icon: Icons.event_available_outlined,
              onTap: () => _comingSoon(context, 'Availability & Schedule'),
            ),
            _SettingsItem(
              title: 'Specialization & Qualifications',
              icon: Icons.school_outlined,
              onTap: () => _comingSoon(context, 'Specialization & Qualifications'),
            ),
            _SettingsItem(
              title: 'Clinic Details',
              icon: Icons.local_hospital_outlined,
              onTap: () => _comingSoon(context, 'Clinic Details'),
            ),
            _SettingsItem(
              title: 'Prescription Templates',
              icon: Icons.note_add_outlined,
              onTap: () => _comingSoon(context, 'Prescription Templates'),
            ),
            _SettingsItem(
              title: 'Medical License',
              icon: Icons.badge_outlined,
              onTap: () => _comingSoon(context, 'Medical License'),
            ),
          ],
        ),

      // Support & Help
      _SettingsSection(
        title: 'Support & Help',
        icon: Icons.support_agent_rounded,
        iconColor: const Color(0xFF0EA5E9),
        iconBg: const Color(0xFFE0F2FE),
        items: [
          _SettingsItem(
            title: 'Contact Support',
            icon: Icons.headset_mic_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HelpAndSupport()),
            ),
          ),
          _SettingsItem(
            title: 'FAQs',
            icon: Icons.help_outline_rounded,
            onTap: () => _comingSoon(context, 'FAQs'),
          ),
          _SettingsItem(
            title: 'Report an Issue',
            icon: Icons.bug_report_outlined,
            onTap: () => _showReportIssueDialog(context),
          ),
        ],
      ),

      // Consultation Settings — Patient and Doctor only
      if (isPatient || isDoctor)
        _SettingsSection(
          title: 'Consultation Settings',
          icon: Icons.video_call_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFF5F3FF),
          items: [
            _SettingsItem(
              title: 'Preferred Doctor Type',
              icon: Icons.person_search_outlined,
              onTap: () => _comingSoon(context, 'Preferred Doctor Type'),
            ),
            _SettingsItem(
              title: 'Consultation History Access',
              icon: Icons.history_outlined,
              onTap: () => _comingSoon(context, 'Consultation History Access'),
            ),
            _SettingsItem(
              title: 'Medical Records Upload',
              icon: Icons.upload_file_outlined,
              onTap: () => _comingSoon(context, 'Medical Records Upload'),
            ),
            _SettingsItem(
              title: 'Video/Audio Preferences',
              icon: Icons.settings_outlined,
              onTap: () => _comingSoon(context, 'Video/Audio Preferences'),
            ),
          ],
        ),

      // Pharmacy Settings (patient-facing) — Patient only
      if (isPatient)
        _SettingsSection(
          title: 'Pharmacy Settings',
          icon: Icons.local_pharmacy_rounded,
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFFECFDF5),
          items: [
            _SettingsItem(
              title: 'Saved Delivery Addresses',
              icon: Icons.location_on_outlined,
              onTap: () => _comingSoon(context, 'Saved Delivery Addresses'),
            ),
            _SettingsItem(
              title: 'Preferred Pharmacy',
              icon: Icons.store_outlined,
              onTap: () => _comingSoon(context, 'Preferred Pharmacy'),
            ),
            _SettingsItem(
              title: 'Order History',
              icon: Icons.receipt_long_outlined,
              onTap: () => _comingSoon(context, 'Order History'),
            ),
            _SettingsItem(
              title: 'Delivery Preferences',
              icon: Icons.delivery_dining_outlined,
              onTap: () => _comingSoon(context, 'Delivery Preferences'),
            ),
          ],
        ),

      // Diagnostics Settings — Patient only
      if (isPatient)
        _SettingsSection(
          title: 'Diagnostics Settings',
          icon: Icons.biotech_rounded,
          iconColor: const Color(0xFF06B6D4),
          iconBg: const Color(0xFFECFEFF),
          items: [
            _SettingsItem(
              title: 'Test History',
              icon: Icons.science_outlined,
              onTap: () => _comingSoon(context, 'Test History'),
            ),
            _SettingsItem(
              title: 'Home Sample Preferences',
              icon: Icons.home_outlined,
              onTap: () => _comingSoon(context, 'Home Sample Preferences'),
            ),
            _SettingsItem(
              title: 'Report Delivery Method',
              icon: Icons.send_outlined,
              onTap: () => _comingSoon(context, 'Report Delivery Method'),
            ),
          ],
        ),

      // Learning Settings — Patient, Student, Instructor only
      if (!isPharmacy && !isLaboratory && !isDoctor)
        _SettingsSection(
          title: 'Learning Settings',
          icon: Icons.school_rounded,
          iconColor: const Color(0xFFF97316),
          iconBg: const Color(0xFFFFF7ED),
          items: [
            _SettingsItem(
              title: 'My Courses',
              icon: Icons.menu_book_outlined,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Courses()),
              ),
            ),
            _SettingsItem(
              title: 'Certificates',
              icon: Icons.workspace_premium_outlined,
              onTap: () => _comingSoon(context, 'Certificates'),
            ),
            _SettingsItem(
              title: 'Course Notifications',
              icon: Icons.notifications_outlined,
              onTap: () => _comingSoon(context, 'Course Notifications'),
            ),
          ],
        ),

      // Language & Region
      _SettingsSection(
        title: 'Language & Region',
        icon: Icons.language_rounded,
        iconColor: const Color(0xFF64748B),
        iconBg: const Color(0xFFF1F5F9),
        items: [
          _SettingsItem(
            title: 'Language',
            icon: Icons.translate_rounded,
            onTap: () => _comingSoon(context, 'Language Selection'),
          ),
          _SettingsItem(
            title: 'Country / Region',
            icon: Icons.public_rounded,
            onTap: () => _comingSoon(context, 'Country / Region'),
          ),
        ],
      ),
    ];

    if (MediaQuery.of(context).size.width > 600) {
      return _WebSettingsScreen(
        sections: sections,
        onLogout: _handleLogout,
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: CustomText(
          text: "Settings",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(16), vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sections.map((section) => _MobileSectionCard(
              section: section,
              onToggleChanged: setState,
            )),
            const SizedBox(height: 24),
            // Logout button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Data models ────────────────────────────────────────────────────────────

class _SettingsSection {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.items,
  });
}

class _SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggle;

  const _SettingsItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggle,
  });
}

// ─── Mobile section card ────────────────────────────────────────────────────

class _MobileSectionCard extends StatelessWidget {
  final _SettingsSection section;
  final void Function(void Function()) onToggleChanged;

  const _MobileSectionCard({
    required this.section,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: section.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == section.items.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: item.isToggle ? null : item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: idx == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: isLast ? const Radius.circular(16) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: section.iconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, color: section.iconColor, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (item.isToggle)
                            Switch(
                              value: item.toggleValue,
                              onChanged: item.onToggle,
                              activeColor: AppColors.primaryColor,
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFCBD5E1),
                              size: 14,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _WebSettingsScreen extends StatelessWidget {
  final List<_SettingsSection> sections;
  final VoidCallback onLogout;

  const _WebSettingsScreen({
    required this.sections,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: const CustomText(
          text: "Settings",
          fontFamily: "Gilroy-Bold",
          fontSize: 20,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left sidebar ──
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Account Settings",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Gilroy-Bold",
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Manage your profile, security, notifications, and legal preferences all in one place.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: onLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.redAccent,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // ── Right: Sectioned settings ──
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections.map((section) => _WebSectionCard(section: section)).toList(),
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

class _WebSectionCard extends StatelessWidget {
  final _SettingsSection section;

  const _WebSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: section.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(section.icon, color: section.iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    fontFamily: "Gilroy-Bold",
                  ),
                ),
              ],
            ),
          ),
          // Items card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  offset: Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              children: section.items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isLast = idx == section.items.length - 1;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: item.isToggle ? null : item.onTap,
                        borderRadius: BorderRadius.vertical(
                          top: idx == 0 ? const Radius.circular(16) : Radius.zero,
                          bottom: isLast ? const Radius.circular(16) : Radius.zero,
                        ),
                        hoverColor: const Color(0xFFF8FAFC),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: section.iconBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon, color: section.iconColor, size: 20),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                    fontFamily: "Gilroy-SemiBold",
                                  ),
                                ),
                              ),
                              if (item.isToggle)
                                Switch(
                                  value: item.toggleValue,
                                  onChanged: item.onToggle,
                                  activeColor: AppColors.primaryColor,
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1, color: Color(0xFFF1F5F9),
                        thickness: 1.5, indent: 24, endIndent: 24,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
