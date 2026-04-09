import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/about_us.dart';
import 'package:icare/screens/certificates_screen.dart';
import 'package:icare/screens/change_password.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/notification_settings.dart';
import 'package:icare/screens/privacy_policy.dart';
import 'package:icare/screens/reset_password.dart';
import 'package:icare/screens/terms_and_conditions.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/services/security_service.dart';
import 'package:icare/widgets/app_modals.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
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

  @override
  void initState() {
    super.initState();
    // In a real app, fetch initial states from backend/local storage
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
    }
  }

  void _show2FAConfirmationDialog(String qrUrl) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 100,
              ), // Placeholder for real QR
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
              final verified = await _securityService.verify2FA(
                codeController.text,
              );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Something went wrong. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.read(authProvider).userRole ?? '';
    final isStudent = role == 'Student';
    final List<Map<String, dynamic>> _settingsList = [
      {
        "id": "1",
        "title": "Notifications",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => NotificationSettings()));
        },
      },
      {
        "id": "2",
        "title": isStudent ? "My Certificates" : "Subscription Plans",
        "onPress": () {
          if (isStudent) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const CertificatesScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Subscription Plans coming soon!")),
            );
          }
        },
      },
      {
        "id": "3",
        "title": "Change Passwords",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ChangePassword()));
        },
      },
      {
        "id": "4",
        "title": "Two-Factor Authentication",
        "isToggle": true,
        "value": _is2FAEnabled,
        "onChanged": (val) => _toggle2FA(val),
      },
      {
        "id": "5",
        "title": "Biometric Authentication",
        "isToggle": true,
        "value": _isBiometricEnabled,
        "onChanged": (val) => _toggleBiometrics(val),
      },
      {
        "id": "6",
        "title": "Privacy Policy",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => PrivacyPolicy()));
        },
      },
      {
        "id": "7",
        "title": "About Us",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => AboutUs()));
        },
      },
      {
        "id": "8",
        "title": "Terms & Conditions",
        "onPress": () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => TermsAndConditions()));
        },
      },
    ];

    if (MediaQuery.of(context).size.width > 600) {
      return _WebSettingsScreen(settingsList: _settingsList);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: _settingsList.map((item) {
                    final bool isToggle = item['isToggle'] ?? false;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: item["title"],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary500,
                                fontFamily: "Gilroy-SemiBold",
                              ),
                              isToggle
                                  ? Switch(
                                      value: item['value'],
                                      onChanged: (val) =>
                                          item['onChanged'](val),
                                      activeColor: AppColors.primaryColor,
                                    )
                                  : IconButton(
                                      onPressed: item["onPress"],
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColors.primaryColor,
                                        size: 16,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        if (item['id'] != "8")
                          const Divider(
                            color: AppColors.darkGreyColor,
                            thickness: 0.1,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                borderRadius: 30,
                onPressed: () {
                  // Logout logic
                },
                label: "Logout",
              ),
              const SizedBox(height: 12),
              CustomButton(
                borderRadius: 30,
                onPressed: () {
                  // Delete logic
                },
                label: "Delete Account",
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW STUNNING WEB VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _WebSettingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> settingsList;

  const _WebSettingsScreen({required this.settingsList});

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
        title: CustomText(
          text: "Account Settings",
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
                  // ── Left Side: Profile Sidebar / Header ──
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Preferences & Security",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Gilroy-Bold",
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Manage your account settings, view legal documents, and configure your notification preferences.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Delete Account Zone
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Danger Zone",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Gilroy-Bold",
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Permanently delete your account and all associated data.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(
                                      color: Color(0xFFDC2626),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    AppDialogs.showWarningDialog(
                                      context,
                                      "Are you sure you want to delete your account?",
                                      null,
                                      [
                                        "I don’t need it anymore",
                                        "I don’t find it useful",
                                        "Other",
                                      ],
                                      numOfActions: 2,
                                      onPrimaryButtonPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => LoginScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    "Delete Account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // ── Right Side: Settings List ──
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF1F4F9),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            offset: Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: settingsList.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Color(0xFFF1F5F9),
                          height: 1,
                          thickness: 1.5,
                          indent: 24,
                          endIndent: 24,
                        ),
                        itemBuilder: (context, index) {
                          final item = settingsList[index];
                          final isLast = index == settingsList.length - 1;
                          final isFirst = index == 0;

                          // Map specific icons to settings
                          IconData iconData = Icons.settings_rounded;
                          Color iconColor = const Color(0xFF64748B);
                          Color bgColor = const Color(0xFFF8FAFC);

                          if (item['title'].toString().contains(
                            "Notification",
                          )) {
                            iconData = Icons.notifications_active_rounded;
                            iconColor = const Color(0xFF3B82F6);
                            bgColor = const Color(0xFFEFF6FF);
                          } else if (item['title'].toString().contains(
                            "Password",
                          )) {
                            iconData = Icons.lock_rounded;
                            iconColor = const Color(0xFF8B5CF6);
                            bgColor = const Color(0xFFF5F3FF);
                          } else if (item['title'].toString().contains(
                            "Privacy",
                          )) {
                            iconData = Icons.shield_rounded;
                            iconColor = const Color(0xFF10B981);
                            bgColor = const Color(0xFFECFDF5);
                          } else if (item['title'].toString().contains(
                            "About",
                          )) {
                            iconData = Icons.info_rounded;
                            iconColor = const Color(0xFFF59E0B);
                            bgColor = const Color(0xFFFEF3C7);
                          } else if (item['title'].toString().contains(
                            "Terms",
                          )) {
                            iconData = Icons.gavel_rounded;
                            iconColor = const Color(0xFF64748B);
                            bgColor = const Color(0xFFF1F5F9);
                          }

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: item["onPress"],
                              borderRadius: BorderRadius.vertical(
                                top: isFirst
                                    ? const Radius.circular(20)
                                    : Radius.zero,
                                bottom: isLast
                                    ? const Radius.circular(20)
                                    : Radius.zero,
                              ),
                              hoverColor: const Color(0xFFF8FAFC),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: iconColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        item["title"] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                          fontFamily: "Gilroy-SemiBold",
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
