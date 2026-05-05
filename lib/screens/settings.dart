import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/about_us.dart';
import 'package:icare/screens/change_password.dart';
import 'package:icare/screens/certificates_screen.dart';
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

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final SecurityService _securityService = SecurityService();

  // Security toggles
  bool _is2FAEnabled = false;
  bool _isBiometricEnabled = true;

  // Tracker toggles (Patient)
  final Map<String, bool> _trackerToggles = {
    'BP': true,
    'Sugar': true,
    'Weight': false,
    'Water': true,
    'Medication': true,
  };

  // Health mode toggles (Patient)
  final Map<String, bool> _healthModes = {
    'Diabetes Mode': false,
    'BP Mode': false,
    'Heart Mode': false,
    'Weight Mode': false,
  };

  // ── Security helpers ────────────────────────────────────────────────────

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enable 2FA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan this QR code with your authenticator app (e.g., Google Authenticator).',
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final verified = await _securityService.verify2FA(codeController.text);
              if (verified) {
                setState(() => _is2FAEnabled = true);
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('2FA Enabled Successfully!')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid code, try again.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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

  // ── Auth helpers ────────────────────────────────────────────────────────

  void _handleLogout() {
    ref.read(authProvider.notifier).setUserLogout();
    context.go('/login');
  }

  // ── Dialog helpers ──────────────────────────────────────────────────────

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
            Text(
              'Report an Issue',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
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
                    content: Text(
                      'Issue reported. Thank you — we will get back to you shortly.',
                    ),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 10),
            Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFFEF4444)),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your health data, history, and preferences will be erased.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted.'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: const Text('Delete My Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
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
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
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

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final role = ref.read(authProvider).userRole ?? '';
    final isPatient = role == 'Patient';
    final isPharmacy = role == 'Pharmacy';
    final isLaboratory = role == 'Laboratory';
    final isDoctor = role == 'Doctor';
    final isStudent = role == 'Student';
    final isInstructor = role == 'Instructor';

    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return _WebSettingsLayout(
        role: role,
        isPatient: isPatient,
        isPharmacy: isPharmacy,
        isLaboratory: isLaboratory,
        isDoctor: isDoctor,
        isStudent: isStudent,
        isInstructor: isInstructor,
        is2FAEnabled: _is2FAEnabled,
        isBiometricEnabled: _isBiometricEnabled,
        trackerToggles: _trackerToggles,
        healthModes: _healthModes,
        onToggle2FA: _toggle2FA,
        onToggleBiometrics: _toggleBiometrics,
        onTrackerToggle: (key, val) => setState(() => _trackerToggles[key] = val),
        onHealthModeToggle: (key, val) => setState(() => _healthModes[key] = val),
        onLogout: _handleLogout,
        onComingSoon: _comingSoon,
        onReportIssue: _showReportIssueDialog,
        onDeleteAccount: _showDeleteAccountDialog,
      );
    }

    return _MobileSettingsLayout(
      role: role,
      isPatient: isPatient,
      isPharmacy: isPharmacy,
      isLaboratory: isLaboratory,
      isDoctor: isDoctor,
      isStudent: isStudent,
      isInstructor: isInstructor,
      is2FAEnabled: _is2FAEnabled,
      isBiometricEnabled: _isBiometricEnabled,
      trackerToggles: _trackerToggles,
      healthModes: _healthModes,
      onToggle2FA: _toggle2FA,
      onToggleBiometrics: _toggleBiometrics,
      onTrackerToggle: (key, val) => setState(() => _trackerToggles[key] = val),
      onHealthModeToggle: (key, val) => setState(() => _healthModes[key] = val),
      onLogout: _handleLogout,
      onComingSoon: _comingSoon,
      onReportIssue: _showReportIssueDialog,
      onDeleteAccount: _showDeleteAccountDialog,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class _SettingsSection {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<_SettingsItem> items;
  final String? subtitle;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.items,
    this.subtitle,
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

// ═══════════════════════════════════════════════════════════════════════════
// SECTION BUILDER MIXIN — shared by mobile and web layouts
// ═══════════════════════════════════════════════════════════════════════════

mixin _SettingsSectionBuilder {
  List<_SettingsSection> buildSections({
    required BuildContext context,
    required String role,
    required bool isPatient,
    required bool isPharmacy,
    required bool isLaboratory,
    required bool isDoctor,
    required bool isStudent,
    required bool isInstructor,
    required bool is2FAEnabled,
    required bool isBiometricEnabled,
    required Map<String, bool> trackerToggles,
    required ValueChanged<bool> onToggle2FA,
    required ValueChanged<bool> onToggleBiometrics,
    required void Function(BuildContext, String) onComingSoon,
    required void Function(BuildContext) onReportIssue,
    required void Function(BuildContext) onDeleteAccount,
  }) {
    final sections = <_SettingsSection>[];

    // ── 1. PROFILE & ACCOUNT ─────────────────────────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Profile & Account',
        icon: Icons.manage_accounts_rounded,
        iconColor: const Color(0xFF6366F1),
        iconBg: const Color(0xFFEEF2FF),
        items: [
          _SettingsItem(
            title: 'Name',
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Age / Gender',
            icon: Icons.cake_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Phone / Email',
            icon: Icons.contact_phone_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Profile Photo',
            icon: Icons.photo_camera_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Emergency Contact',
            icon: Icons.emergency_outlined,
            onTap: () => onComingSoon(context, 'Emergency Contact'),
          ),
          _SettingsItem(
            title: 'Blood Group',
            icon: Icons.bloodtype_outlined,
            onTap: () => onComingSoon(context, 'Blood Group'),
          ),
          _SettingsItem(
            title: 'Existing Conditions',
            icon: Icons.medical_information_outlined,
            onTap: () => onComingSoon(context, 'Existing Conditions'),
          ),
        ],
      ));
    } else {
      // Non-patient: simple edit profile
      sections.add(_SettingsSection(
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
        ],
      ));
    }

    // ── 2. HEALTH PROFILE (Patient only) ─────────────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Health Profile',
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEF2F2),
        subtitle: 'Connects to your health tracker + doctor',
        items: [
          _SettingsItem(
            title: 'Medical Conditions (Diabetes, Hypertension etc.)',
            icon: Icons.monitor_heart_outlined,
            onTap: () => onComingSoon(context, 'Medical Conditions'),
          ),
          _SettingsItem(
            title: 'Allergies',
            icon: Icons.warning_amber_rounded,
            onTap: () => onComingSoon(context, 'Allergies'),
          ),
          _SettingsItem(
            title: 'Current Medications',
            icon: Icons.medication_outlined,
            onTap: () => onComingSoon(context, 'Current Medications'),
          ),
          _SettingsItem(
            title: 'Health Goals (weight loss, BP control etc.)',
            icon: Icons.flag_outlined,
            onTap: () => onComingSoon(context, 'Health Goals'),
          ),
        ],
      ));
    }

    // ── 4. REMINDERS & NOTIFICATIONS ─────────────────────────────────────
    sections.add(_SettingsSection(
      title: 'Reminders & Notifications',
      icon: Icons.notifications_active_rounded,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFEFF6FF),
      items: [
        if (isPatient) ...[
          _SettingsItem(
            title: 'Medication Reminders',
            icon: Icons.medication_liquid_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationSettings()),
            ),
          ),
          _SettingsItem(
            title: 'Water Reminders',
            icon: Icons.water_drop_outlined,
            onTap: () => onComingSoon(context, 'Water Reminders'),
          ),
          _SettingsItem(
            title: 'Health Check Reminders',
            icon: Icons.health_and_safety_outlined,
            onTap: () => onComingSoon(context, 'Health Check Reminders'),
          ),
          _SettingsItem(
            title: 'Appointment Reminders',
            icon: Icons.event_available_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationSettings()),
            ),
          ),
        ] else
          _SettingsItem(
            title: 'Notification Preferences',
            icon: Icons.notifications_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationSettings()),
            ),
          ),
      ],
    ));

    // ── 5. REWARDS & POINTS (Patient only) ───────────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Rewards & Points',
        icon: Icons.stars_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBg: const Color(0xFFFEF3C7),
        items: [
          _SettingsItem(
            title: 'Points Balance',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => onComingSoon(context, 'Points Balance'),
          ),
          _SettingsItem(
            title: 'Rewards History',
            icon: Icons.history_rounded,
            onTap: () => onComingSoon(context, 'Rewards History'),
          ),
          _SettingsItem(
            title: 'Redemption History',
            icon: Icons.redeem_outlined,
            onTap: () => onComingSoon(context, 'Redemption History'),
          ),
        ],
      ));
    }

    // ── 6. PRIVACY & DATA ────────────────────────────────────────────────
    sections.add(_SettingsSection(
      title: 'Privacy & Data',
      icon: Icons.shield_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBg: const Color(0xFFF5F3FF),
      items: [
        if (isPatient) ...[
          _SettingsItem(
            title: 'Download Health Data',
            icon: Icons.download_outlined,
            onTap: () => onComingSoon(context, 'Download Health Data'),
          ),
          _SettingsItem(
            title: 'Delete Account',
            icon: Icons.delete_forever_outlined,
            onTap: () => onDeleteAccount(context),
          ),
        ] else ...[
          _SettingsItem(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PrivacyPolicy()),
            ),
          ),
          _SettingsItem(
            title: 'Data Sharing Preferences',
            icon: Icons.share_outlined,
            onTap: () => onComingSoon(context, 'Data Sharing Preferences'),
          ),
          _SettingsItem(
            title: 'Delete Account',
            icon: Icons.delete_forever_outlined,
            onTap: () => onDeleteAccount(context),
          ),
        ],
      ],
    ));

    // ── 7. PAYMENTS & SUBSCRIPTIONS (Patient only) ───────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Payments & Subscriptions',
        icon: Icons.payment_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
        items: [
          _SettingsItem(
            title: 'Saved Payment Methods',
            icon: Icons.credit_card_outlined,
            onTap: () => onComingSoon(context, 'Saved Payment Methods'),
          ),
          _SettingsItem(
            title: 'Subscription Plans',
            icon: Icons.workspace_premium_outlined,
            onTap: () => onComingSoon(context, 'Subscription Plans'),
          ),
          _SettingsItem(
            title: 'Billing History',
            icon: Icons.receipt_long_outlined,
            onTap: () => onComingSoon(context, 'Billing History'),
          ),
        ],
      ));
    }

    // ── 8. SUPPORT & HELP ────────────────────────────────────────────────
    sections.add(_SettingsSection(
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
          onTap: () => onComingSoon(context, 'FAQs'),
        ),
        _SettingsItem(
          title: 'Report Issue',
          icon: Icons.bug_report_outlined,
          onTap: () => onReportIssue(context),
        ),
      ],
    ));

    // ── 9. ABOUT & LEGAL ─────────────────────────────────────────────────
    sections.add(_SettingsSection(
      title: 'About & Legal',
      icon: Icons.info_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBg: const Color(0xFFFEF3C7),
      items: [
        _SettingsItem(
          title: 'Terms & Conditions',
          icon: Icons.gavel_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TermsAndConditions()),
          ),
        ),
        _SettingsItem(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PrivacyPolicy()),
          ),
        ),
        _SettingsItem(
          title: 'App Version  v1.0.0',
          icon: Icons.info_outline_rounded,
          onTap: null,
        ),
      ],
    ));

    // ── 10. PHARMACY SETTINGS (patient-facing) ───────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Pharmacy Settings',
        icon: Icons.local_pharmacy_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
        items: [
          _SettingsItem(
            title: 'Saved Delivery Addresses',
            icon: Icons.location_on_outlined,
            onTap: () => onComingSoon(context, 'Saved Delivery Addresses'),
          ),
          _SettingsItem(
            title: 'Preferred Pharmacy',
            icon: Icons.store_outlined,
            onTap: () => onComingSoon(context, 'Preferred Pharmacy'),
          ),
          _SettingsItem(
            title: 'Order History',
            icon: Icons.receipt_long_outlined,
            onTap: () => onComingSoon(context, 'Order History'),
          ),
          _SettingsItem(
            title: 'Delivery Preferences',
            icon: Icons.delivery_dining_outlined,
            onTap: () => onComingSoon(context, 'Delivery Preferences'),
          ),
        ],
      ));
    }

    // ── 11. DIAGNOSTICS SETTINGS (Patient only) ──────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Diagnostics Settings',
        icon: Icons.biotech_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBg: const Color(0xFFECFEFF),
        items: [
          _SettingsItem(
            title: 'Test History',
            icon: Icons.science_outlined,
            onTap: () => onComingSoon(context, 'Test History'),
          ),
          _SettingsItem(
            title: 'Home Sample Preferences',
            icon: Icons.home_outlined,
            onTap: () => onComingSoon(context, 'Home Sample Preferences'),
          ),
          _SettingsItem(
            title: 'Report Delivery Method',
            icon: Icons.send_outlined,
            onTap: () => onComingSoon(context, 'Report Delivery Method'),
          ),
        ],
      ));
    }

    // ── 12. LEARNING SETTINGS ────────────────────────────────────────────
    if (isPatient || isStudent || isInstructor) {
      sections.add(_SettingsSection(
        title: 'Learning Settings',
        icon: Icons.school_rounded,
        iconColor: const Color(0xFFF97316),
        iconBg: const Color(0xFFFFF7ED),
        items: [
          _SettingsItem(
            title: 'Enrolled Courses',
            icon: Icons.menu_book_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Courses()),
            ),
          ),
          _SettingsItem(
            title: 'Certificates',
            icon: Icons.workspace_premium_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CertificatesScreen()),
            ),
          ),
          _SettingsItem(
            title: 'Progress Tracking',
            icon: Icons.trending_up_rounded,
            onTap: () => onComingSoon(context, 'Progress Tracking'),
          ),
          _SettingsItem(
            title: 'Notifications for New Courses',
            icon: Icons.notifications_outlined,
            onTap: () => onComingSoon(context, 'Notifications for New Courses'),
          ),
        ],
      ));
    }

    // ── 13. FAMILY PROFILES (Patient only) ───────────────────────────────
    if (isPatient) {
      sections.add(_SettingsSection(
        title: 'Family Profiles',
        icon: Icons.group_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBg: const Color(0xFFF5F3FF),
        items: [
          _SettingsItem(
            title: 'Add Family Member',
            icon: Icons.person_add_outlined,
            onTap: () => onComingSoon(context, 'Add Family Member'),
          ),
          _SettingsItem(
            title: 'Manage Children / Parents',
            icon: Icons.family_restroom_outlined,
            onTap: () => onComingSoon(context, 'Manage Children / Parents'),
          ),
          _SettingsItem(
            title: 'Track Their Health Separately',
            icon: Icons.monitor_heart_outlined,
            onTap: () => onComingSoon(context, 'Track Their Health Separately'),
          ),
        ],
      ));
    }

    // ── 14. SECURITY ─────────────────────────────────────────────────────
    sections.add(_SettingsSection(
      title: 'Security',
      icon: Icons.security_rounded,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFECFDF5),
      items: [
        _SettingsItem(
          title: 'Change Password',
          icon: Icons.lock_outline_rounded,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChangePassword()),
          ),
        ),
        _SettingsItem(
          title: '2FA / OTP',
          icon: Icons.verified_user_outlined,
          isToggle: true,
          toggleValue: is2FAEnabled,
          onToggle: onToggle2FA,
        ),
        _SettingsItem(
          title: 'Login Activity',
          icon: Icons.history_rounded,
          onTap: () => onComingSoon(context, 'Login Activity'),
        ),
      ],
    ));

    // ── 15. LANGUAGE & REGION ────────────────────────────────────────────
    sections.add(_SettingsSection(
      title: 'Language & Region',
      icon: Icons.language_rounded,
      iconColor: const Color(0xFF64748B),
      iconBg: const Color(0xFFF1F5F9),
      items: [
        _SettingsItem(
          title: 'Language Selection',
          icon: Icons.translate_rounded,
          onTap: () => onComingSoon(context, 'Language Selection'),
        ),
        _SettingsItem(
          title: 'Country / Region',
          icon: Icons.public_rounded,
          onTap: () => onComingSoon(context, 'Country / Region'),
        ),
      ],
    ));

    // ── Role-specific professional sections ───────────────────────────────

    if (isDoctor) {
      sections.add(_SettingsSection(
        title: 'Professional Settings',
        icon: Icons.medical_information_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBg: const Color(0xFFF5F3FF),
        items: [
          _SettingsItem(
            title: 'Consultation Fees',
            icon: Icons.attach_money_rounded,
            onTap: () => onComingSoon(context, 'Consultation Fees'),
          ),
          _SettingsItem(
            title: 'Availability & Schedule',
            icon: Icons.event_available_outlined,
            onTap: () => onComingSoon(context, 'Availability & Schedule'),
          ),
          _SettingsItem(
            title: 'Specialization & Qualifications',
            icon: Icons.school_outlined,
            onTap: () => onComingSoon(context, 'Specialization & Qualifications'),
          ),
          _SettingsItem(
            title: 'Clinic Details',
            icon: Icons.local_hospital_outlined,
            onTap: () => onComingSoon(context, 'Clinic Details'),
          ),
          _SettingsItem(
            title: 'Prescription Templates',
            icon: Icons.note_add_outlined,
            onTap: () => onComingSoon(context, 'Prescription Templates'),
          ),
          _SettingsItem(
            title: 'Medical License',
            icon: Icons.badge_outlined,
            onTap: () => onComingSoon(context, 'Medical License'),
          ),
        ],
      ));
    }

    if (isPharmacy) {
      sections.add(_SettingsSection(
        title: 'Pharmacy Business Settings',
        icon: Icons.store_rounded,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFECFDF5),
        items: [
          _SettingsItem(
            title: 'Business Hours',
            icon: Icons.access_time_rounded,
            onTap: () => onComingSoon(context, 'Business Hours'),
          ),
          _SettingsItem(
            title: 'Delivery Settings',
            icon: Icons.local_shipping_outlined,
            onTap: () => onComingSoon(context, 'Delivery Settings'),
          ),
          _SettingsItem(
            title: 'Inventory Alerts',
            icon: Icons.inventory_2_outlined,
            onTap: () => onComingSoon(context, 'Inventory Alerts'),
          ),
          _SettingsItem(
            title: 'Order Notifications',
            icon: Icons.notifications_active_outlined,
            onTap: () => onComingSoon(context, 'Order Notifications'),
          ),
          _SettingsItem(
            title: 'Payment Methods',
            icon: Icons.payment_rounded,
            onTap: () => onComingSoon(context, 'Payment Methods'),
          ),
          _SettingsItem(
            title: 'License & Compliance',
            icon: Icons.verified_outlined,
            onTap: () => onComingSoon(context, 'License & Compliance'),
          ),
        ],
      ));
    }

    if (isLaboratory) {
      sections.add(_SettingsSection(
        title: 'Laboratory Settings',
        icon: Icons.science_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBg: const Color(0xFFECFEFF),
        items: [
          _SettingsItem(
            title: 'Test Catalog',
            icon: Icons.list_alt_rounded,
            onTap: () => onComingSoon(context, 'Test Catalog'),
          ),
          _SettingsItem(
            title: 'Sample Collection Settings',
            icon: Icons.medical_services_outlined,
            onTap: () => onComingSoon(context, 'Sample Collection Settings'),
          ),
          _SettingsItem(
            title: 'Report Delivery Settings',
            icon: Icons.description_outlined,
            onTap: () => onComingSoon(context, 'Report Delivery Settings'),
          ),
          _SettingsItem(
            title: 'Lab Timings',
            icon: Icons.schedule_rounded,
            onTap: () => onComingSoon(context, 'Lab Timings'),
          ),
          _SettingsItem(
            title: 'Equipment Management',
            icon: Icons.biotech_outlined,
            onTap: () => onComingSoon(context, 'Equipment Management'),
          ),
          _SettingsItem(
            title: 'Accreditation & Certifications',
            icon: Icons.workspace_premium_outlined,
            onTap: () => onComingSoon(context, 'Accreditation & Certifications'),
          ),
        ],
      ));
    }

    if (isInstructor) {
      sections.add(_SettingsSection(
        title: 'Instructor Settings',
        icon: Icons.cast_for_education_rounded,
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
            title: 'Student Management',
            icon: Icons.people_outline_rounded,
            onTap: () => onComingSoon(context, 'Student Management'),
          ),
          _SettingsItem(
            title: 'Course Analytics',
            icon: Icons.bar_chart_rounded,
            onTap: () => onComingSoon(context, 'Course Analytics'),
          ),
          _SettingsItem(
            title: 'Certificates Issued',
            icon: Icons.workspace_premium_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CertificatesScreen()),
            ),
          ),
        ],
      ));
    }

    return sections;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT
// ═══════════════════════════════════════════════════════════════════════════

class _MobileSettingsLayout extends StatelessWidget with _SettingsSectionBuilder {
  final String role;
  final bool isPatient;
  final bool isPharmacy;
  final bool isLaboratory;
  final bool isDoctor;
  final bool isStudent;
  final bool isInstructor;
  final bool is2FAEnabled;
  final bool isBiometricEnabled;
  final Map<String, bool> trackerToggles;
  final Map<String, bool> healthModes;
  final ValueChanged<bool> onToggle2FA;
  final ValueChanged<bool> onToggleBiometrics;
  final void Function(String key, bool val) onTrackerToggle;
  final void Function(String key, bool val) onHealthModeToggle;
  final VoidCallback onLogout;
  final void Function(BuildContext, String) onComingSoon;
  final void Function(BuildContext) onReportIssue;
  final void Function(BuildContext) onDeleteAccount;

  const _MobileSettingsLayout({
    required this.role,
    required this.isPatient,
    required this.isPharmacy,
    required this.isLaboratory,
    required this.isDoctor,
    required this.isStudent,
    required this.isInstructor,
    required this.is2FAEnabled,
    required this.isBiometricEnabled,
    required this.trackerToggles,
    required this.healthModes,
    required this.onToggle2FA,
    required this.onToggleBiometrics,
    required this.onTrackerToggle,
    required this.onHealthModeToggle,
    required this.onLogout,
    required this.onComingSoon,
    required this.onReportIssue,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final sections = buildSections(
      context: context,
      role: role,
      isPatient: isPatient,
      isPharmacy: isPharmacy,
      isLaboratory: isLaboratory,
      isDoctor: isDoctor,
      isStudent: isStudent,
      isInstructor: isInstructor,
      is2FAEnabled: is2FAEnabled,
      isBiometricEnabled: isBiometricEnabled,
      trackerToggles: trackerToggles,
      onToggle2FA: onToggle2FA,
      onToggleBiometrics: onToggleBiometrics,
      onComingSoon: onComingSoon,
      onReportIssue: onReportIssue,
      onDeleteAccount: onDeleteAccount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackButton(),
        title: CustomText(
          text: 'Settings',
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: 'Gilroy-Bold',
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ScallingConfig.scale(16),
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sections ──────────────────────────────────────────────────
            ...sections.map((section) => _MobileSectionCard(
                  section: section,
                  sectionIconColor: section.iconColor,
                  sectionIconBg: section.iconBg,
                )),

            // ── 3. TRACKER SETTINGS (Patient only) ────────────────────────
            if (isPatient) ...[
              _mobileSectionHeader('Tracker Settings'),
              _MobileTrackerCard(
                trackerToggles: trackerToggles,
                onToggle: onTrackerToggle,
                onComingSoon: onComingSoon,
              ),
            ],

            // ── 16. HEALTH MODE TOGGLE (Patient only) ─────────────────────
            if (isPatient) ...[
              _mobileSectionHeader('Health Mode'),
              _MobileHealthModeCard(
                healthModes: healthModes,
                onToggle: onHealthModeToggle,
              ),
            ],

            const SizedBox(height: 32),

            // ── LOGOUT BUTTON ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy-Bold',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _mobileSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Mobile section card ──────────────────────────────────────────────────────

class _MobileSectionCard extends StatelessWidget {
  final _SettingsSection section;
  final Color sectionIconColor;
  final Color sectionIconBg;

  const _MobileSectionCard({
    required this.section,
    required this.sectionIconColor,
    required this.sectionIconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
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
        // Subtitle if present
        if (section.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              section.subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        // Card
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
                              color: sectionIconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, color: sectionIconColor, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                fontFamily: 'Gilroy-SemiBold',
                              ),
                            ),
                          ),
                          if (item.isToggle)
                            Switch(
                              value: item.toggleValue,
                              onChanged: item.onToggle,
                              activeColor: AppColors.primaryColor,
                            )
                          else if (item.onTap != null)
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
                    const Divider(
                      height: 1,
                      color: Color(0xFFF1F5F9),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Mobile Tracker Settings card ─────────────────────────────────────────────

class _MobileTrackerCard extends StatelessWidget {
  final Map<String, bool> trackerToggles;
  final void Function(String key, bool val) onToggle;
  final void Function(BuildContext, String) onComingSoon;

  const _MobileTrackerCard({
    required this.trackerToggles,
    required this.onToggle,
    required this.onComingSoon,
  });

  static const _trackerIcons = <String, IconData>{
    'BP': Icons.monitor_heart_outlined,
    'Sugar': Icons.bloodtype_outlined,
    'Weight': Icons.scale_outlined,
    'Water': Icons.water_drop_outlined,
    'Medication': Icons.medication_outlined,
  };

  static const _trackerColors = <String, Color>{
    'BP': Color(0xFFEF4444),
    'Sugar': Color(0xFFF59E0B),
    'Weight': Color(0xFF10B981),
    'Water': Color(0xFF3B82F6),
    'Medication': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final toggleKeys = trackerToggles.keys.toList();
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What to Track header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'WHAT TO TRACK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...toggleKeys.asMap().entries.map((entry) {
            final idx = entry.key;
            final key = entry.value;
            final isLast = idx == toggleKeys.length - 1;
            final color = _trackerColors[key] ?? AppColors.primaryColor;
            final icon = _trackerIcons[key] ?? Icons.track_changes_outlined;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Gilroy-SemiBold',
                          ),
                        ),
                      ),
                      Switch(
                        value: trackerToggles[key] ?? false,
                        onChanged: (val) => onToggle(key, val),
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
              ],
            );
          }),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Daily Goals sub-section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'DAILY GOALS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          _goalRow(
            context: context,
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF3B82F6),
            title: 'Water Goal',
            onTap: () => onComingSoon(context, 'Water Goal'),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
          _goalRow(
            context: context,
            icon: Icons.directions_walk_rounded,
            color: const Color(0xFF10B981),
            title: 'Steps Goal',
            onTap: () => onComingSoon(context, 'Steps Goal'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _goalRow({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(16))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  fontFamily: 'Gilroy-SemiBold',
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Mobile Health Mode card ───────────────────────────────────────────────────

class _MobileHealthModeCard extends StatelessWidget {
  final Map<String, bool> healthModes;
  final void Function(String key, bool val) onToggle;

  const _MobileHealthModeCard({
    required this.healthModes,
    required this.onToggle,
  });

  static const _modeIcons = <String, IconData>{
    'Diabetes Mode': Icons.bloodtype_outlined,
    'BP Mode': Icons.monitor_heart_outlined,
    'Heart Mode': Icons.favorite_outlined,
    'Weight Mode': Icons.scale_outlined,
  };

  static const _modeColors = <String, Color>{
    'Diabetes Mode': Color(0xFFF59E0B),
    'BP Mode': Color(0xFFEF4444),
    'Heart Mode': Color(0xFFEC4899),
    'Weight Mode': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final keys = healthModes.keys.toList();
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: const [
                Icon(Icons.tune_rounded, color: AppColors.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Personalizes your tracker and dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...keys.asMap().entries.map((entry) {
            final idx = entry.key;
            final key = entry.value;
            final isLast = idx == keys.length - 1;
            final color = _modeColors[key] ?? AppColors.primaryColor;
            final icon = _modeIcons[key] ?? Icons.toggle_on_outlined;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Gilroy-SemiBold',
                          ),
                        ),
                      ),
                      Switch(
                        value: healthModes[key] ?? false,
                        onChanged: (val) => onToggle(key, val),
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: Color(0xFFE2E8F0),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB LAYOUT
// ═══════════════════════════════════════════════════════════════════════════

class _WebSettingsLayout extends StatelessWidget with _SettingsSectionBuilder {
  final String role;
  final bool isPatient;
  final bool isPharmacy;
  final bool isLaboratory;
  final bool isDoctor;
  final bool isStudent;
  final bool isInstructor;
  final bool is2FAEnabled;
  final bool isBiometricEnabled;
  final Map<String, bool> trackerToggles;
  final Map<String, bool> healthModes;
  final ValueChanged<bool> onToggle2FA;
  final ValueChanged<bool> onToggleBiometrics;
  final void Function(String key, bool val) onTrackerToggle;
  final void Function(String key, bool val) onHealthModeToggle;
  final VoidCallback onLogout;
  final void Function(BuildContext, String) onComingSoon;
  final void Function(BuildContext) onReportIssue;
  final void Function(BuildContext) onDeleteAccount;

  const _WebSettingsLayout({
    required this.role,
    required this.isPatient,
    required this.isPharmacy,
    required this.isLaboratory,
    required this.isDoctor,
    required this.isStudent,
    required this.isInstructor,
    required this.is2FAEnabled,
    required this.isBiometricEnabled,
    required this.trackerToggles,
    required this.healthModes,
    required this.onToggle2FA,
    required this.onToggleBiometrics,
    required this.onTrackerToggle,
    required this.onHealthModeToggle,
    required this.onLogout,
    required this.onComingSoon,
    required this.onReportIssue,
    required this.onDeleteAccount,
  });

  String get _settingsSubtitle {
    switch (role) {
      case 'Patient':
        return 'Manage your health profile, appointments, notifications, privacy, and account preferences.';
      case 'Doctor':
        return 'Manage your professional profile, availability, consultation settings, and account preferences.';
      case 'Pharmacy':
        return 'Manage your business details, inventory alerts, delivery settings, and account preferences.';
      case 'Laboratory':
        return 'Manage your lab profile, test catalog, sample collection, and account preferences.';
      case 'Student':
        return 'Manage your learning progress, certificates, notifications, and account preferences.';
      case 'Instructor':
        return 'Manage your courses, students, analytics, and account preferences.';
      default:
        return 'Manage your profile, security, notifications, and legal preferences all in one place.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = buildSections(
      context: context,
      role: role,
      isPatient: isPatient,
      isPharmacy: isPharmacy,
      isLaboratory: isLaboratory,
      isDoctor: isDoctor,
      isStudent: isStudent,
      isInstructor: isInstructor,
      is2FAEnabled: is2FAEnabled,
      isBiometricEnabled: isBiometricEnabled,
      trackerToggles: trackerToggles,
      onToggle2FA: onToggle2FA,
      onToggleBiometrics: onToggleBiometrics,
      onComingSoon: onComingSoon,
      onReportIssue: onReportIssue,
      onDeleteAccount: onDeleteAccount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: const CustomBackButton(),
        title: const CustomText(
          text: 'Settings',
          fontFamily: 'Gilroy-Bold',
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
                  // ── Left sidebar ──────────────────────────────────────
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
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Gilroy-Bold',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _settingsSubtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Logout button in sidebar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onLogout,
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Gilroy-Bold',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // ── Right: sections ───────────────────────────────────
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...sections.map((s) => _WebSectionCard(section: s)),

                        // ── Tracker Settings (Patient only) ───────────
                        if (isPatient) ...[
                          _webSectionLabel('Tracker Settings'),
                          _WebTrackerCard(
                            trackerToggles: trackerToggles,
                            onToggle: onTrackerToggle,
                            onComingSoon: onComingSoon,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── Health Mode (Patient only) ─────────────────
                        if (isPatient) ...[
                          _webSectionLabel('Health Mode'),
                          _WebHealthModeCard(
                            healthModes: healthModes,
                            onToggle: onHealthModeToggle,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
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

  Widget _webSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Web section card ──────────────────────────────────────────────────────────

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
          // Section header row
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
                    fontFamily: 'Gilroy-Bold',
                  ),
                ),
                if (section.subtitle != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    '— ${section.subtitle}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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
                                    fontFamily: 'Gilroy-SemiBold',
                                  ),
                                ),
                              ),
                              if (item.isToggle)
                                Switch(
                                  value: item.toggleValue,
                                  onChanged: item.onToggle,
                                  activeColor: AppColors.primaryColor,
                                )
                              else if (item.onTap != null)
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
                        height: 1,
                        color: Color(0xFFF1F5F9),
                        thickness: 1.5,
                        indent: 24,
                        endIndent: 24,
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

// ── Web Tracker Settings card ─────────────────────────────────────────────────

class _WebTrackerCard extends StatelessWidget {
  final Map<String, bool> trackerToggles;
  final void Function(String key, bool val) onToggle;
  final void Function(BuildContext, String) onComingSoon;

  const _WebTrackerCard({
    required this.trackerToggles,
    required this.onToggle,
    required this.onComingSoon,
  });

  static const _trackerIcons = <String, IconData>{
    'BP': Icons.monitor_heart_outlined,
    'Sugar': Icons.bloodtype_outlined,
    'Weight': Icons.scale_outlined,
    'Water': Icons.water_drop_outlined,
    'Medication': Icons.medication_outlined,
  };

  static const _trackerColors = <String, Color>{
    'BP': Color(0xFFEF4444),
    'Sugar': Color(0xFFF59E0B),
    'Weight': Color(0xFF10B981),
    'Water': Color(0xFF3B82F6),
    'Medication': Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final toggleKeys = trackerToggles.keys.toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Text(
              'WHAT TO TRACK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...toggleKeys.asMap().entries.map((entry) {
            final idx = entry.key;
            final key = entry.value;
            final isLast = idx == toggleKeys.length - 1;
            final color = _trackerColors[key] ?? AppColors.primaryColor;
            final icon = _trackerIcons[key] ?? Icons.track_changes_outlined;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Gilroy-SemiBold',
                          ),
                        ),
                      ),
                      Switch(
                        value: trackerToggles[key] ?? false,
                        onChanged: (val) => onToggle(key, val),
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                    thickness: 1.5,
                    indent: 24,
                    endIndent: 24,
                  ),
              ],
            );
          }),
          const Divider(height: 1, color: Color(0xFFF1F5F9), thickness: 1.5),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Text(
              'DAILY GOALS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          _webGoalRow(
            context: context,
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF3B82F6),
            title: 'Water Goal',
            onTap: () => onComingSoon(context, 'Water Goal'),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
            thickness: 1.5,
            indent: 24,
            endIndent: 24,
          ),
          _webGoalRow(
            context: context,
            icon: Icons.directions_walk_rounded,
            color: const Color(0xFF10B981),
            title: 'Steps Goal',
            onTap: () => onComingSoon(context, 'Steps Goal'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _webGoalRow({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF8FAFC),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Gilroy-SemiBold',
                  ),
                ),
              ),
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
    );
  }
}

// ── Web Health Mode card ──────────────────────────────────────────────────────

class _WebHealthModeCard extends StatelessWidget {
  final Map<String, bool> healthModes;
  final void Function(String key, bool val) onToggle;

  const _WebHealthModeCard({
    required this.healthModes,
    required this.onToggle,
  });

  static const _modeIcons = <String, IconData>{
    'Diabetes Mode': Icons.bloodtype_outlined,
    'BP Mode': Icons.monitor_heart_outlined,
    'Heart Mode': Icons.favorite_outlined,
    'Weight Mode': Icons.scale_outlined,
  };

  static const _modeColors = <String, Color>{
    'Diabetes Mode': Color(0xFFF59E0B),
    'BP Mode': Color(0xFFEF4444),
    'Heart Mode': Color(0xFFEC4899),
    'Weight Mode': Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final keys = healthModes.keys.toList();
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2FE), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Row(
              children: const [
                Icon(Icons.tune_rounded, color: AppColors.primaryColor, size: 20),
                SizedBox(width: 10),
                Text(
                  'Personalizes your tracker and dashboard',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          ...keys.asMap().entries.map((entry) {
            final idx = entry.key;
            final key = entry.value;
            final isLast = idx == keys.length - 1;
            final color = _modeColors[key] ?? AppColors.primaryColor;
            final icon = _modeIcons[key] ?? Icons.toggle_on_outlined;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                            fontFamily: 'Gilroy-SemiBold',
                          ),
                        ),
                      ),
                      Switch(
                        value: healthModes[key] ?? false,
                        onChanged: (val) => onToggle(key, val),
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: Color(0xFFE2E8F0),
                    thickness: 1.5,
                    indent: 24,
                    endIndent: 24,
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
