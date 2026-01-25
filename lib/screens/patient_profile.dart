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
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Patient Profile",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: Utils.windowWidth(context) * 0.34,
              height: Utils.windowWidth(context) * 0.34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(ImagePaths.user1, fit: BoxFit.cover),
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            CustomText(
              text: "Emily Jordan",
              fontFamily: "Gilroy-Bold",
              fontSize: 16.79,
            ),
            SizedBox(height: ScallingConfig.scale(30)),
            SizedBox(
              width: Utils.windowWidth(context) * 0.9,
              child: Row(
                children: [
                  SvgWrapper(assetPath: ImagePaths.sms),
                  SizedBox(width: ScallingConfig.scale(10)),
                  CustomText(text: "emily@gmail.com"),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(10)),
            SizedBox(
              width: Utils.windowWidth(context) * 0.9,

              child: Row(
                children: [
                  SvgWrapper(
                    assetPath: ImagePaths.calll,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: ScallingConfig.scale(10)),
                  CustomText(text: "+1 234 567 8963"),
                ],
              ),
            ),
            SizedBox(height: ScallingConfig.scale(15)),
            CustomText(
              text: "Bio:",
              fontSize: 14,
              width: Utils.windowWidth(context) * 0.9,
              isBold: true,
              fontFamily: "Gilroy-Bold",
            ),
            CustomText(
              fontSize: 12,
              width: Utils.windowWidth(context) * 0.9,
              maxLines: 5,
              text:
                  "Lorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitanLorem ipsum dolor...",
              fontFamily: "Gilroy-Regular",
            ),
            SizedBox(height: ScallingConfig.scale(20)),
            CustomText(
              width: Utils.windowWidth(context) * 0.9,
              text: "Medical History & Medical Documents:",
              fontFamily: "Gilroy-Bold",
              fontSize: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(10),
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                  SizedBox(
                    width: Utils.windowWidth(context) * 0.3,
                    child: Image.asset('assets/images/medical-doc-1.png'),
                  ),
                ],
              ),
            ),

            SizedBox(height: ScallingConfig.scale(10)),
            CustomText(
              width: Utils.windowWidth(context) * 0.9,
              text: "Medical History & Medical Documents:",
              fontFamily: "Gilroy-Bold",
              fontSize: 16,
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.scale(10),
              ),
              child: Align(
                alignment: AlignmentGeometry.topLeft,
                child: SizedBox(
                  width: Utils.windowWidth(context) * 0.3,
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
