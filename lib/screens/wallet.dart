import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/top-up.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(
          text: "Wallet",
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          color: AppColors.primary500,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              TotalBalanceCard(),
              PaymentMethods(),
              SizedBox(height: ScallingConfig.scale(20)),
              CustomButton(
                borderRadius: 30,
                trailingIcon: SvgWrapper(assetPath: ImagePaths.topUp),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (ctx) => TopUpScreen()));
                },
                label: "Top Up",
                width: Utils.windowWidth(context) * 0.85,
              ),
              SizedBox(height: ScallingConfig.scale(20)),
              CustomText(
                text: "Recieved Amounts",
                textAlign: TextAlign.start,
                width: Utils.windowWidth(context) * 0.8,
              ),
              SizedBox(
                height: Utils.windowHeight(context) * 0.4,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemCount: 3,
                  itemBuilder: (ctx, i) {
                    return (ListTile(
                      leading: SizedBox(
                        width: Utils.windowWidth(context) * 0.15,
                        height: Utils.windowWidth(context) * 0.25,
                        child: Image.asset(ImagePaths.user7, fit: BoxFit.cover),
                      ),
                      title: CustomText(
                        text: "Lorem Ipsum",
                        width: Utils.windowWidth(context) * 0.65,
                        fontWeight: FontWeight.bold,
                      ),
                      subtitle: CustomText(text: "Today 12:02"),

                      trailing: SizedBox(
                        width: Utils.windowWidth(context) * 0.17,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgWrapper(assetPath: ImagePaths.recievedAmount),
                            CustomText(text: "2,000"),
                          ],
                        ),
                      ),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.85,
      padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(20)),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            fontSize: 16,
            fontFamily: "Gilroy-Medium",
            text: "Total Balance",
            color: AppColors.white,
          ),
          CustomText(
            text: "30,000",
            fontSize: 39,
            fontFamily: "Gilroy-Bold",
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.only(top: ScallingConfig.scale(20)),
      padding: EdgeInsets.symmetric(
        horizontal: ScallingConfig.scale(10),
        vertical: ScallingConfig.scale(10),
      ),
      width: Utils.windowWidth(context) * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkGreyColor.withAlpha(50)),
        gradient: LinearGradient(
          begin: AlignmentGeometry.topLeft,
          end: AlignmentGeometry.bottomRight,
          colors: [
            AppColors.veryLightGrey,
            AppColors.veryLightGrey.withAlpha(0),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgWrapper(assetPath: ImagePaths.wallet),
                  SizedBox(width: ScallingConfig.scale(10)),

                  CustomText(
                    text: "Payment Method",
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: AppColors.primary500,
                    fontFamily: "Gilroy-Bold",
                  ),
                ],
              ),
              // SizedBox(width: Utils.windowWidth(context) * 0.24,),
              CustomText(
                text: "Change Now",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryColor,
                fontFamily: "Gilroy-Bold",
                underline: true,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgWrapper(assetPath: ImagePaths.payMethod),
                  SizedBox(width: ScallingConfig.scale(10)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "MasterCard",
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: AppColors.primary500,
                        fontFamily: "Gilroy-Bold",
                      ),

                      CustomText(
                        text: "****1892",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.grayColor,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: Utils.windowWidth(context) * 0.34),
              CustomText(
                text: "30,000",
                fontSize: 12,
                height: ScallingConfig.scale(40),
                fontWeight: FontWeight.w400,
                color: AppColors.grayColor,
                fontFamily: "Gilroy-Bold",
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
