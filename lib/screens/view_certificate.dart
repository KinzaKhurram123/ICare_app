import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/utils/theme.dart';

class ViewCertificate extends StatelessWidget {
  const ViewCertificate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text:"Certificate",
        fontWeight: FontWeight.bold,
            letterSpacing: -0.31,
            lineHeight: 1.0,
                      fontSize: 16.78, 
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: Center(
        child: Column(

          children: [
            SizedBox(height: ScallingConfig.scale(40),),
           Image.asset(
                ImagePaths.certificate,
              ),
            SizedBox(height: ScallingConfig.scale(30),),
            CustomButton(
              label: "Download", 
              width: Utils.windowWidth(context) * 0.9, 
              borderRadius: 40,
              )
          ],
        ),
      ),
    );
  }
}