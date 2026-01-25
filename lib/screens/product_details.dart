import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/row_text.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Product Detail",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
              letterSpacing: -0.31,
            lineHeight: 1.0,
          color: AppColors.primary500,
        ),
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
              Image.asset(ImagePaths.capsule),
              SizedBox(height: ScallingConfig.scale(10),),
              RowText(
                leadingText: "Liver Cleanse Capsule", 
                trailingText: "Rs 2000",
                leadingColor: AppColors.darkGray300,
                 trailingColor: AppColors.primary500,
                 leadingFontSize: 16.78,
                 leadingFontFamily: "Gilroy-Bold",
                 trailingFontFamily: "Gilroy-Bold",
                 trailingFontSize: 16.78,
                ),
              SizedBox(height: ScallingConfig.scale(10),),
              CustomText(
                width: Utils.windowWidth(context) * 0.9,
                // maxLines: 30,
                color: AppColors.darkGray600,
                fontSize: 10,
                fontFamily: "Gilroy-Regular",
                text: "250gm",
              ),
              SizedBox(height: ScallingConfig.scale(10),),
                 SizedBox(
                  width: Utils.windowWidth(context) * 0.9,
                  child: Row(
                    spacing: ScallingConfig.scale(5),
                  children: [
                    CustomText(
                      text: "Visit:",
                      color: AppColors.darkGray500,
                      letterSpacing: -0.6,
                      lineHeight: 1.0,
                    ),
                    
                    CustomText(
                      text: "Pharma",
                      color: AppColors.primaryColor,
                      underline: true,
                      letterSpacing: -0.6,
                      lineHeight: 1.0,
                    ),
                  ],
                )),
              SizedBox(height: ScallingConfig.scale(20),),
              CustomText(
                width: Utils.windowWidth(context) * 0.9,
                maxLines: 30,
                color: AppColors.grayColor,
                fontSize: 10.59,
                fontFamily: "Gilroy-SemiBold",
                text: "Our Pharmacy combines advanced diagnostic technology with the expertise of highly qualified professionals, ensuring every test is conducted with precision, accuracy, and reliability to support better healthcare outcomes. Our Pharmacy combines advanced diagnostic technology with the expertise of highly qualified professionals, ensuring every test is conducted with precision, accuracy, and reliability to support better healthcare outcomes.",
              ),
              SizedBox(height: ScallingConfig.scale(20),),
              CustomText(
                width: Utils.windowWidth(context) * 0.9,
                // maxLines: 30,
                color: AppColors.darkGray300,
                fontSize: 16.89,
                fontFamily: "Gilroy-Bold",
                fontWeight: FontWeight.bold,
                text: "Precautions",
              ),
              SizedBox(height: ScallingConfig.scale(20),),
              CustomText(
                width: Utils.windowWidth(context) * 0.9,
                maxLines: 30,
                color: AppColors.grayColor,
                fontSize: 10.59,
                fontFamily: "Gilroy-SemiBold",
                text: "Our Pharmacy combines advanced diagnostic technology with the expertise of highly qualified professionals, ensuring every test is conducted with precision, accuracy.",
              ),
              SizedBox(height: ScallingConfig.scale(20),),
              CustomButton(
                label: "Checkout",
                width: Utils.windowWidth(context) * 0.9,
                borderRadius: 40,
              )
          ],
        ),
      ),
    );
  }
}