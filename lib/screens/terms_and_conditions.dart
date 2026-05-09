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
              text: "iCare – RM Health Solutions (Private) Limited\nPlease read these Terms & Conditions carefully before using the Platform.",
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
  ["1. ELIGIBILITY",
    "You must be at least 18 years of age to use the Platform.\n\nBy using the Platform, you represent and warrant that:\n• You possess legal capacity to enter into binding agreements;\n• All information provided by you is accurate and complete;\n• You will comply with all applicable laws and regulations.\n\nThe Platform reserves the right to suspend or terminate access where false, misleading, or fraudulent information is provided."],
  ["2. NATURE OF SERVICES",
    "iCare provides a technology-enabled healthcare platform facilitating:\n• Teleconsultations;\n• Video/audio/chat consultations;\n• Appointment scheduling;\n• Electronic prescriptions;\n• Medical record storage;\n• AI-enabled assistance;\n• Pharmacy coordination;\n• Laboratory integrations;\n• Mental health consultations;\n• Community and engagement features.\n\niCare does not guarantee diagnosis, treatment outcomes, or recovery.\n\nThe Platform is NOT intended for medical emergencies, critical care, or life-threatening conditions. In emergencies, users must immediately contact local emergency services or visit the nearest hospital."],
  ["3. TELEMEDICINE CONSENT",
    "By using the Platform, you expressly consent to telemedicine services.\n\nYou acknowledge and accept:\n• Telemedicine has inherent limitations;\n• Technical disruptions may occur;\n• Diagnosis may be limited without physical examination;\n• Audio/video quality may affect consultation accuracy.\n\nConsultations may be recorded for quality assurance, legal compliance, medical documentation, and security purposes.\n\nYou consent to electronic communication, digital prescriptions, and digital medical documentation."],
  ["4. DOCTOR RELATIONSHIP DISCLAIMER",
    "Healthcare professionals may operate as employees or independent contractors.\n\niCare acts primarily as a technology intermediary platform.\n\nMedical practitioners remain independently responsible for:\n• Clinical judgment;\n• Prescriptions;\n• Diagnoses;\n• Treatment decisions.\n\niCare shall not be liable for medical negligence, clinical misconduct, incorrect diagnosis, prescription complications, or adverse treatment outcomes."],
  ["5. AI & TECHNOLOGY DISCLAIMER",
    "Certain Platform features may utilize automated systems or AI-enabled assistance for appointment routing, chat assistance, administrative support, and symptom triage assistance.\n\nAI tools do NOT replace licensed medical professionals.\n\nUsers must not rely solely upon AI-generated responses for medical decisions."],
  ["6. USER ACCOUNTS",
    "Users may create accounts using mobile verification, social login integrations, or email registration.\n\nUsers are solely responsible for maintaining account confidentiality, password security, and device security.\n\nUsers agree not to:\n• Share accounts;\n• Impersonate others;\n• Upload unlawful content;\n• Abuse healthcare professionals;\n• Use the Platform fraudulently.\n\niCare may suspend or permanently terminate accounts without prior notice for violations of these Terms, abuse, fraudulent activity, or regulatory concerns."],
  ["7. MEDICAL RECORDS & DATA STORAGE",
    "Users authorize iCare to store:\n• Medical histories;\n• Consultation records;\n• Prescriptions;\n• Uploaded reports;\n• Identification documents;\n• Audio/video consultation records.\n\nMedical records may be retained permanently unless deletion is requested and legally permissible.\n\nUsers acknowledge that deletion requests may be limited by regulatory obligations, legal proceedings, and medical record retention requirements."],
  ["8. PRIVACY & DATA PROTECTION",
    "iCare implements reasonable technical and organizational safeguards to protect user data. Data may be encrypted and stored on secure infrastructure.\n\nBy using the Platform, users consent to collection and processing of personal and medical information in accordance with Pakistan PECA laws, applicable data protection regulations, GDPR-style privacy principles, and UK data protection standards.\n\nUsers acknowledge that no electronic system can be guaranteed 100% secure."],
  ["9. PHARMACY & LAB SERVICES",
    "Pharmacy and laboratory services may be provided directly by iCare or through third-party providers.\n\nThird-party pharmacies and laboratories remain independently responsible for medicine quality, lab accuracy, delivery operations, and regulatory compliance.\n\niCare shall not be liable for delayed deliveries, incorrect lab results, medication reactions, or third-party operational failures."],
  ["10. PAYMENTS & REFUNDS",
    "Payments may be processed through banks, payment gateways, EasyPaisa, JazzCash, credit/debit cards, and digital wallets.\n\nConsultation fees are generally non-refundable once services are booked or rendered.\n\nIf a patient misses an appointment: no refund shall apply.\n\nIf a doctor misses an appointment: the consultation may be rescheduled, an alternative doctor may be assigned, or refunds may be granted at Company discretion.\n\nInternet disruptions or technical failures may result in rescheduling without liability."],
  ["11. PRESCRIPTIONS",
    "Electronic prescriptions may be issued through digitally signed systems. Doctors remain solely responsible for prescriptions issued.\n\nNarcotic substances are prohibited unless legally authorized. Users must not misuse prescriptions or controlled medicines."],
  ["12. COMMUNITY FEATURES & USER CONTENT",
    "Users may post reviews, ratings, comments, and other content. Users grant iCare a worldwide, perpetual, royalty-free license to use uploaded content for Platform operations, analytics, research, AI training, and business intelligence.\n\niCare reserves the right to remove any content deemed harmful, defamatory, illegal, misleading, or offensive."],
  ["13. INTELLECTUAL PROPERTY",
    "All Platform content, branding, logos, systems, designs, software, and technology are owned by RM Health Solutions (Private) Limited.\n\n\"iCare\" and associated branding are protected intellectual property.\n\nUsers may not copy, reverse engineer, redistribute, modify, or commercially exploit Platform materials without authorization."],
  ["14. LIMITATION OF LIABILITY",
    "To the maximum extent permitted by law, iCare shall not be liable for indirect damages, medical complications, data loss, service interruptions, cyberattacks, third-party failures, misuse of prescriptions, or unauthorized account access.\n\nUsers use the Platform entirely at their own risk.\n\nTotal Company liability shall not exceed the amount paid by the user for the relevant service."],
  ["15. FORCE MAJEURE",
    "iCare shall not be liable for delays or failures caused by natural disasters, internet outages, government actions, cyberattacks, war, power failures, pandemics, or third-party service disruptions."],
  ["16. COMPLIANCE & LEGAL USE",
    "Users agree not to violate laws, misrepresent medical information, engage in harassment, upload malicious software, or attempt unauthorized access.\n\nThe Platform may cooperate with governmental or regulatory authorities where legally required."],
  ["17. TERMINATION",
    "iCare may suspend or terminate access immediately and without prior notice for security, legal, operational, or policy reasons. Users may stop using the Platform at any time."],
  ["18. DISPUTE RESOLUTION",
    "Any dispute shall first be resolved through arbitration. If arbitration fails, disputes shall fall under the jurisdiction of competent courts in Pakistan."],
  ["19. GOVERNING LAW",
    "These Terms shall be governed in accordance with the laws of Pakistan and applicable international telehealth compliance principles where relevant."],
  ["20. MODIFICATIONS",
    "iCare reserves the right to modify these Terms at any time. Updated versions become effective upon publication on the Platform. Continued use constitutes acceptance of revised Terms."],
  ["21. CONTACT INFORMATION",
    "RM Health Solutions (Private) Limited\nBrand: iCare\n\nOfficial contact details, registered office address, support email, and communication channels are available on the official Platform website."],
  ["22. ACKNOWLEDGMENT",
    "By using iCare, you acknowledge that:\n• You have read these Terms;\n• You understand telemedicine limitations;\n• You consent to electronic healthcare services;\n• You agree to these legally binding Terms & Conditions."],
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
                    "iCare – RM Health Solutions (Private) Limited\n\nBy accessing or using the Platform, you acknowledge that you have read, understood, and agreed to be legally bound by these Terms.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontFamily: "Gilroy-Medium",
                      height: 1.6,
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
