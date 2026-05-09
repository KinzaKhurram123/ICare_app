import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 600) {
      return const _WebPrivacyPolicy();
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Privacy Policy",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
          letterSpacing: -0.31,
          lineHeight: 1.0,
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
              text: "iCare – RM Health Solutions (Private) Limited",
              fontFamily: "Gilroy-Medium",
              fontSize: 12,
              color: AppColors.themeDarkGrey,
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.02),
            ..._sections.map((s) => _MobilePolicySection(title: s[0], body: s[1])),
          ],
        ),
      ),
    );
  }
}

class _MobilePolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _MobilePolicySection({required this.title, required this.body});

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
  ["1. SCOPE OF POLICY",
    "This Privacy Policy applies to:\n• Patients;\n• Doctors;\n• Clinics;\n• Pharmacies;\n• Laboratories;\n• Visitors;\n• Healthcare professionals;\n• Business partners;\n• All users interacting with iCare services."],
  ["2. INFORMATION WE COLLECT",
    "Personal Information: full name, CNIC/passport information, date of birth, gender, contact details, address, emergency contacts, and profile photographs.\n\nMedical Information: medical history, prescriptions, diagnostic reports, lab reports, mental health information, consultation notes, audio/video consultation recordings, uploaded medical records, symptoms and treatment history.\n\nTechnical Information: device information, browser type, IP address, operating system, login activity, app usage information, crash logs, and communication metadata.\n\nPayment Information: transaction references, billing information, and payment confirmations. Sensitive payment credentials are processed by authorized third-party payment processors."],
  ["3. HOW WE COLLECT INFORMATION",
    "Information may be collected:\n• Directly from users;\n• During account registration;\n• During consultations;\n• Through uploaded documents;\n• Through customer support;\n• Via cookies or analytics technologies;\n• Through third-party integrations."],
  ["4. PURPOSE OF DATA COLLECTION",
    "We may use collected information for:\n• Providing telemedicine services;\n• Appointment management;\n• Medical consultations;\n• E-prescriptions;\n• Identity verification;\n• Regulatory compliance;\n• Customer support;\n• Platform security;\n• Fraud prevention;\n• AI system training;\n• Analytics and business intelligence;\n• Research and development;\n• Improving healthcare services;\n• Communication and notifications."],
  ["5. TELEMEDICINE & RECORDING CONSENT",
    "By using the Platform, users expressly consent to electronic healthcare delivery, audio/video consultations, electronic prescriptions, storage of consultation records, and recording of consultations for legal, operational, security, medical, and quality assurance purposes.\n\nUsers acknowledge that telemedicine involves technological limitations and potential risks."],
  ["6. AI & AUTOMATED SYSTEMS",
    "The Platform may utilize AI-enabled systems for appointment routing, chat assistance, administrative support, and symptom triage support.\n\nAI systems do not replace professional medical judgment. Users must not rely solely on automated responses for medical decisions."],
  ["7. LEGAL BASIS FOR PROCESSING",
    "We process data based upon:\n• User consent;\n• Contractual necessity;\n• Healthcare service obligations;\n• Legal and regulatory compliance;\n• Legitimate business interests;\n• Public health obligations where applicable."],
  ["8. DATA SHARING & DISCLOSURE",
    "We may share information with licensed doctors, pharmacies, laboratories, payment processors, technology vendors, regulatory authorities, legal advisors, and government agencies where legally required.\n\nWe do not sell personal medical information to unauthorized third parties."],
  ["9. INTERNATIONAL COMPLIANCE",
    "iCare aims to align with applicable principles under:\n• Pakistan PECA laws;\n• Pakistan data protection principles;\n• GDPR principles;\n• UK GDPR principles;\n• International telehealth privacy standards;\n• Electronic consent regulations."],
  ["10. DATA RETENTION",
    "Medical and operational records may be retained permanently unless deletion is requested and legally permissible.\n\nCertain records may remain archived for legal compliance, fraud prevention, audit obligations, and medical continuity."],
  ["11. DATA SECURITY",
    "We implement reasonable safeguards including encryption technologies, access restrictions, authentication systems, administrative controls, secure servers, and monitoring mechanisms.\n\nHowever, no system can guarantee absolute security. Users acknowledge inherent cybersecurity risks associated with online services."],
  ["12. USER RIGHTS",
    "Subject to applicable laws, users may have rights to:\n• Access their information;\n• Correct inaccurate information;\n• Request account deletion;\n• Request restriction of processing;\n• Withdraw consent where applicable.\n\nCertain requests may be restricted due to legal obligations, medical record requirements, and regulatory compliance."],
  ["13. ACCOUNT DELETION",
    "Users may request deletion of their accounts. iCare may retain certain information where necessary for legal compliance, medical obligations, fraud prevention, security investigations, and regulatory requirements."],
  ["14. COOKIES & TRACKING TECHNOLOGIES",
    "The Platform may utilize cookies, session tracking, analytics technologies, and device identifiers for authentication, performance, security, and user experience optimization.\n\nUsers may limit certain tracking features through browser settings."],
  ["15. THIRD-PARTY SERVICES",
    "The Platform may integrate third-party services including payment gateways, laboratories, pharmacies, cloud providers, communication tools, and authentication services.\n\niCare is not responsible for independent privacy practices of third-party providers."],
  ["16. PHARMACY & LABORATORY SERVICES",
    "Third-party pharmacies and laboratories remain independently responsible for product quality, medication authenticity, lab accuracy, delivery operations, and regulatory compliance.\n\niCare acts primarily as a facilitating technology platform."],
  ["17. CHILDREN'S PRIVACY",
    "The Platform is not intended for users under 18 years of age. We do not knowingly collect personal data from minors without lawful authorization."],
  ["18. COMMUNITY FEATURES",
    "Users posting reviews, ratings, comments, or public content acknowledge that such information may become publicly visible. iCare reserves the right to moderate or remove content violating laws or policies."],
  ["19. INTELLECTUAL PROPERTY & DATA USE",
    "Users grant iCare a non-exclusive, worldwide, royalty-free license to use anonymized and aggregated information for analytics, research, AI training, platform improvement, healthcare innovation, and business intelligence."],
  ["20. DATA BREACH RESPONSE",
    "In the event of significant security incidents, iCare may investigate the breach, notify affected users where legally required, engage cybersecurity experts, and cooperate with regulatory authorities."],
  ["21. LIMITATION OF LIABILITY",
    "To the maximum extent permitted by law, iCare shall not be liable for cyberattacks, unauthorized access, technical failures, third-party breaches, data interception, internet disruptions, or user negligence."],
  ["22. CROSS-BORDER OPERATIONS",
    "Users acknowledge that technical infrastructure or service providers may involve systems operating across jurisdictions subject to applicable legal protections."],
  ["23. POLICY CHANGES",
    "We reserve the right to update this Privacy Policy at any time. Updated versions become effective immediately upon publication on the Platform. Continued use constitutes acceptance of revised policies."],
  ["24. CONTACT INFORMATION",
    "RM Health Solutions (Private) Limited\nBrand: iCare\n\nOfficial contact information, registered office address, legal email, and support details are available on the official website."],
  ["25. USER ACKNOWLEDGMENT",
    "By accessing or using iCare, you acknowledge that:\n• You have read this Privacy Policy;\n• You understand how your information is processed;\n• You consent to electronic healthcare operations;\n• You agree to the collection and processing practices described herein."],
];

class _WebPrivacyPolicy extends StatelessWidget {
  const _WebPrivacyPolicy();

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
          text: "Privacy Policy",
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
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "iCare – RM Health Solutions (Private) Limited",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
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
