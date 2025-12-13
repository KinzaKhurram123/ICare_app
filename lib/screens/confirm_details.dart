import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/enter_amount.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class ConfirmDetails extends StatelessWidget {
  const ConfirmDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Confirm Details"),
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(12)),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              text: "Confirmation",
              width: Utils.windowWidth(context),
              fontFamily: "Gilroy-Bold",
              fontSize: 14,
              color: AppColors.primary500,
            ),

            SizedBox(height: Utils.windowHeight(context) * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Platform Fee",
                  fontFamily: "Gilroy-Regular",
                  fontSize: 12,
                  color: AppColors.darkGreyColor,
                ),
                CustomText(
                  text: "100",
                  fontFamily: "Gilroy-Bold",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyColor,
                ),
              ],
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Coure Amount",
                  fontFamily: "Gilroy-Regular",
                  fontSize: 12,
                  color: AppColors.darkGreyColor,
                ),
                CustomText(
                  text: "2000",
                  fontFamily: "Gilroy-Bold",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyColor,
                ),
              ],
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Discounted Offer",
                  fontFamily: "Gilroy-Regular",
                  fontSize: 12,
                  color: AppColors.darkGreyColor,
                ),
                CustomText(
                  text: "5%",
                  fontFamily: "Gilroy-Bold",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyColor,
                ),
              ],
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Total Amount",
                  fontFamily: "Gilroy-Regular",
                  fontSize: 12,
                  color: AppColors.darkGreyColor,
                ),
                CustomText(
                  text: "2100",
                  fontFamily: "Gilroy-Bold",
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreyColor,
                ),
              ],
            ),
            SizedBox(height: Utils.windowHeight(context) * 0.45),
            CustomButton(label: "Confirm", borderRadius: 40, onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => EnterAmountScreen() ));
            },),
          ],
        ),
      ),
    );
  }
}
