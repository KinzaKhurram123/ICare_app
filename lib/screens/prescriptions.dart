import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/notifications.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Prescriptions",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: ScallingConfig.scale(10)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NotificationScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                child: SvgWrapper(assetPath: ImagePaths.notification),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: ScallingConfig.scale(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: ScallingConfig.scale(10),
            children: [
              Image.asset(ImagePaths.prescription1),
              Image.asset(ImagePaths.prescription2),
            ],
          ),
        ],
      ),
    );
  }
}
