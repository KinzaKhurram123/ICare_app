import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/about_us.dart';
import 'package:icare/screens/change_password.dart';
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

  @override
  Widget build(BuildContext context) {
    final role = ref.read(authProvider).userRole ?? '';
    final isPatient = role == 'Patient';

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

      // Privacy & Data
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

      // About & Legal
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
