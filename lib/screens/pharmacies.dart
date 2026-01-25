import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PharmaciesScreen extends StatelessWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Pharmacies",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.darkGray500,
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
        itemCount: 3,
        itemBuilder: (ctx, i) {
          return (PharmacyWidget());
        },
      ),
    );
  }
}

class PharmacyWidget extends StatelessWidget {
  const PharmacyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(10)),
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(10)),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey100,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                ImagePaths.pharmacyLogo,
                width: ScallingConfig.scale(100),
                height: ScallingConfig.scale(100),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Green Pharmacy",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Gilroy-Bold",
                    color: AppColors.themeDarkGrey,
                  ),
                  SizedBox(height: ScallingConfig.verticalScale(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.location),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: "20 Cooper Square, USA",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.delievry),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: "Home Delievery: 25min",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          CustomButton(
            label: "Visit Pharmacy",
            width: Utils.windowWidth(context) * 0.8,
            borderRadius: 35,
          ),
        ],
      ),
    );
  }
}
