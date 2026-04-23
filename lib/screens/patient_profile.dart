import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = Utils.windowWidth(context);

    Widget _infoRow(IconData icon, Color iconColor, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: 'Patient Profile',
          fontSize: 16.78,
          fontFamily: 'Gilroy-Bold',
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: w * 0.3,
                    height: w * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(ImagePaths.user1, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: ScallingConfig.scale(10)),
                  CustomText(
                    text: 'Emily Jordan',
                    fontFamily: 'Gilroy-Bold',
                    fontSize: 16.79,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(20)),

            // Contact info row
            Row(
              children: [
                SvgWrapper(assetPath: ImagePaths.sms),
                SizedBox(width: ScallingConfig.scale(8)),
                CustomText(text: 'emily@gmail.com'),
              ],
            ),
            SizedBox(height: ScallingConfig.scale(8)),
            Row(
              children: [
                SvgWrapper(
                    assetPath: ImagePaths.calll,
                    color: AppColors.primaryColor),
                SizedBox(width: ScallingConfig.scale(8)),
                CustomText(text: '+1 234 567 8963'),
              ],
            ),
            SizedBox(height: ScallingConfig.scale(20)),

            // Profile Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Divider(height: 20),
                  // Role field REMOVED per client spec
                  _infoRow(Icons.cake_rounded, const Color(0xFF6366F1),
                      'Age', '28 years'),
                  _infoRow(Icons.height_rounded, const Color(0xFF0EA5E9),
                      'Height', '5\'7"'),
                  _infoRow(Icons.monitor_weight_rounded, const Color(0xFF10B981),
                      'Weight', '65 kg'),
                  // CNIC field — TODO: backend must add cnic_number field
                  _infoRow(Icons.credit_card_rounded, const Color(0xFFF59E0B),
                      'CNIC Number', '35201-1234567-8'),
                  _infoRow(Icons.location_on_rounded, const Color(0xFFEF4444),
                      'Address', 'House 12, Street 5, Islamabad'),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(16)),

            // Emergency Contacts Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emergency_rounded,
                          color: Color(0xFFDC2626), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Emergency Number 1',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 16, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        const Text(
                          'Robert Jordan (Father): +1 987 654 3210',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Emergency Number 2',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 16, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        const Text(
                          'Not set — tap to add',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(20)),

            CustomText(
              width: w * 0.9,
              text: 'Medical History & Medical Documents:',
              fontFamily: 'Gilroy-Bold',
              fontSize: 16,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
              child: Row(
                children: [
                  SizedBox(
                    width: w * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                  SizedBox(
                    width: w * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                  SizedBox(
                    width: w * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            CustomText(
              width: w * 0.9,
              text: 'Recent Scans:',
              fontFamily: 'Gilroy-Bold',
              fontSize: 16,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
              child: Align(
                alignment: AlignmentGeometry.topLeft,
                child: SizedBox(
                  width: w * 0.3,
                  child: Image.asset('assets/images/medical-doc-1.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
