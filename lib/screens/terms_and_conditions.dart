import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      return const _WebTermsAndConditions();
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Terms & Conditions",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Utils.windowWidth(context) * 0.075,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "Please read these terms carefully before using the ICare application.",
              fontFamily: "Gilroy-Medium",
              fontSize: 12,
              color: AppColors.themeDarkGrey,
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.02),
            ..._sections.map((s) => _MobileTermsSection(title: s[0], body: s[1])),
          ],
        ),
      ),
    );
  }
}

class _MobileTermsSection extends StatelessWidget {
  final String title;
  final String body;
  const _MobileTermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Utils.windowHeight(context) * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontFamily: "Gilroy-Bold",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary500,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Gilroy-Regular",
              color: AppColors.themeDarkGrey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

const List<List<String>> _sections = [
  [
    "1. Acceptance of Terms",
    "By downloading, registering, or using the ICare application, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must discontinue use of the app immediately. ICare reserves the right to update these terms at any time, and continued use constitutes acceptance of the revised terms.",
  ],
  [
    "2. Medical Disclaimer",
    "ICare is a healthcare facilitation platform and does not provide direct medical advice, diagnosis, or treatment. All consultations, prescriptions, and medical decisions are the sole responsibility of the licensed healthcare professionals on the platform. Always seek the advice of a qualified physician for any medical condition.",
  ],
  [
    "3. User Obligations",
    "You agree to provide accurate and complete information when creating your account and booking services. You must not misuse the platform for fraudulent activities, impersonation, or sharing false medical information. You are responsible for maintaining the confidentiality of your account credentials.",
  ],
  [
    "4. Appointments & Cancellations",
    "Appointments booked through ICare are subject to availability of the healthcare provider. Cancellations must be made at least 2 hours before the scheduled time to avoid a cancellation fee. No-shows may result in a charge and may affect your ability to book future appointments.",
  ],
  [
    "5. Payments & Refunds",
    "All payments are processed securely through our payment partners. Fees for consultations, lab tests, and pharmacy orders are displayed before confirmation. Refunds are processed within 5–7 business days for eligible cancellations. Completed consultations and delivered orders are non-refundable.",
  ],
  [
    "6. Intellectual Property",
    "All content, logos, designs, and software on the ICare platform are the intellectual property of ICare and its licensors. You may not reproduce, distribute, or create derivative works without prior written consent from ICare.",
  ],
  [
    "7. Termination",
    "ICare reserves the right to suspend or terminate your account if you violate these terms, engage in fraudulent activity, or misuse the platform. You may also delete your account at any time through the app settings. Termination does not affect any outstanding obligations.",
  ],
  [
    "8. Contact Us",
    "For any questions regarding these Terms and Conditions, please reach out to us at legal@icare.health or visit the Help & Support section within the app.",
  ],
];

class _WebTermsAndConditions extends StatelessWidget {
  const _WebTermsAndConditions();

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
          text: "Terms & Conditions",
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
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
                boxShadow: const [BoxShadow(color: Color(0x0A000000), offset: Offset(0, 4), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Please read these terms carefully before using the ICare application.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontFamily: "Gilroy-Medium",
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                  const SizedBox(height: 32),
                  ..._sections.map((s) => _buildSection(s[0], s[1])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              fontFamily: "Gilroy-Bold",
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
              fontFamily: "Gilroy-Regular",
            ),
          ),
        ],
      ),
    );
  }
}
