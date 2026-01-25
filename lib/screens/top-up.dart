import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_dialog.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:simple_numpad/simple_numpad.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  var amount = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Top Up",
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
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ScallingConfig.verticalScale(10)),
            CustomText(
              text: "Total Balance",
              width: Utils.windowWidth(context) * 0.85,
              fontFamily: "GIlroy-Bold",
              fontSize: 14,
            ),
            Container(
              margin: EdgeInsets.only(top: ScallingConfig.verticalScale(8)),
              padding: EdgeInsets.symmetric(
                vertical: ScallingConfig.verticalScale(5),
                horizontal: ScallingConfig.scale(5),
              ),
              width: Utils.windowWidth(context) * 0.85,
              height: Utils.windowHeight(context) * 0.085,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.primary500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CustomText(
                  width: double.infinity,
                  text: amount.isEmpty ? "Total Balance" : amount,
                  fontSize: amount.isEmpty ? 18 : 39,
                  fontFamily: "Gilroy-Bold",
                  color: amount.isEmpty
                      ? AppColors.tertiaryColor
                      : AppColors.primary500,
                ),
              ),
            ),
            SizedBox(height: ScallingConfig.scale(20)),
            SimpleNumpad(
              buttonWidth: 70,
              buttonHeight: 70,
              gridSpacing: 40,

              foregroundColor: AppColors.white,
              backgroundColor: AppColors.secondaryColor,
              buttonBorderRadius: 35,
              // buttonBorderSide: const BorderSide(
              //     color: Colors.black,
              //     width: 1,
              // ),
              removeBlankButton: true,
              textStyle: TextStyle(
                fontSize: ScallingConfig.moderateScale(28),
                color: AppColors.darkGray500,
              ),
              useBackspace: true,
              // optionText: 'clear',
              onPressed: (str) {
                setState(() {
                  if (str == "BACKSPACE") {
                    if (amount.isNotEmpty) {
                      amount = amount.substring(0, amount.length - 1);
                    }
                  } else {
                    amount += str;
                  }
                });
                print(str);
              },
            ),
            SizedBox(height: ScallingConfig.scale(20)),
            CustomButton(
              label: "Transfer",
              borderRadius: 30,
              width: Utils.windowWidth(context) * 0.85,
              onPressed: () {
                CustomDialog.show(
                  context: context,
                  title: 'Success',
                  okText: "Go Back",
                  onOk: () {
                    Navigator.of(context).pop();
                  },
                  descriptionMaxLines: 2,
                  status: DialogStatus.success,
                  descriptionSize: 14,
                  description:
                      "You have successfully tranfer you $amount in your account.",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
