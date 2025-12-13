import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: CustomText(text: "Patient Profile",),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: Utils.windowWidth(context) * 0.45,
              height: Utils.windowWidth(context) * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18)
              ),
              child: Image.asset(
                ImagePaths.user1,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: ScallingConfig.scale(40),),
            CustomText(
              text: "Emily Jordan",
              fontFamily: "Gilroy-Bold",
              fontSize: 16.79,
              ),
             SizedBox(
              height: ScallingConfig.scale(30),
             ),
             Row(
              children: [
                SvgWrapper(assetPath: ImagePaths.sms),
                CustomText(text:"emily@gmail.com"),
              ],
             ),
             Row(
              children: [
                SvgWrapper(assetPath: ImagePaths.calll, color: AppColors.primaryColor,),
                CustomText(text:"+1 234 567 8963"),
              ],
             ),
             CustomText(text: "Bio:", 
             fontSize: 14,
             isBold: true, fontFamily: "Gilroy-Bold",),
             CustomText(
              fontSize: 12,
              text: "Lorem ipsum dolor sit amet consectetur adipiscing elit suscipit commodo enim tellus et nascetur at leo accumsan, odio habitanLorem ipsum dolor...",
             fontFamily: "Gilroy-Regular",
             ),
             SizedBox(height: ScallingConfig.scale(20),),
             CustomText(text: "Medical History & Medical Documents:", fontFamily: "Gilroy-Bold",
             fontSize: 16,
             ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: Utils.windowWidth(context) * 0.34,
                  child: Image.asset('assets/images/medical-doc-1.png'),
                ),
                SizedBox(
                  width: Utils.windowWidth(context) * 0.34,
                  child: Image.asset('assets/images/medical-doc-1.png'),
                ),
                SizedBox(
                  width: Utils.windowWidth(context) * 0.34,
                  child: Image.asset('assets/images/medical-doc-1.png'),
                ),
              ],
             )


          ],
        ),
      ),
    );
  }
}