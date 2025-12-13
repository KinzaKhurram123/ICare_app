import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/app.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_dialog.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:simple_numpad/simple_numpad.dart';
class EnterAmountScreen extends StatefulWidget {
  const EnterAmountScreen({super.key});

  @override
  State<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends State<EnterAmountScreen> {
  var amount = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
          appBar: AppBar(
            leading: CustomBackButton(),
            automaticallyImplyLeading: false,
            title: CustomText(text:"Enter Amount", fontFamily: "Gilroy-Bold", fontSize: 20,)
          ),
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ScallingConfig.verticalScale(10) ,),
            CustomText(text:"Enter the amount", width: Utils.windowWidth(context) * 0.85,
            fontFamily: "GIlroy-Bold",
            fontSize: 14,
            ),
            Container(
              margin: EdgeInsets.only(top: ScallingConfig.verticalScale(8)),
              padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(5), horizontal: ScallingConfig.scale(5)),
            width: Utils.windowWidth(context) * 0.85,
            height: Utils.windowHeight(context) * 0.06,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.primaryColor
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: CustomText(
               width: double.infinity, 
                text:amount.isEmpty ? "Enter Amount" : amount ,
                fontSize: amount.isEmpty ? 18 : 39,
                fontFamily: "Gilroy-Bold",
                color: amount.isEmpty ? AppColors.tertiaryColor : AppColors.primary500,

              ) ,
              ),
              
              
            ),
            SizedBox(height: ScallingConfig.scale(20) ,),
            SimpleNumpad(
    buttonWidth: 70,
    buttonHeight: 70,
    gridSpacing: 40,

    foregroundColor: AppColors.white,
    backgroundColor: AppColors.veryLightGrey,
    buttonBorderRadius: 35,
    // buttonBorderSide: const BorderSide(
    //     color: Colors.black,
    //     width: 1,
    // ),
    removeBlankButton: true,
    textStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: ScallingConfig.moderateScale(28),
      color: AppColors.darkGray500 
    ),
    useBackspace: true,
    // optionText: 'clear',
    onPressed: (str) {
        setState(() {
          if(str == "BACKSPACE"){
        if (amount.isNotEmpty) {
        amount = amount.substring(0, amount.length - 1);
      }

          }else{
          amount+= str;
          }
        });
        print(str);
    },
),
SizedBox(
  height: ScallingConfig.scale(20),
),
            CustomButton(label: "Done", borderRadius: 30, width: Utils.windowWidth(context) * 0.85,
            onPressed: () {
              CustomDialog.show(
              context: context, 
              title: 'Successful',
              okText: "Enjoy",
              onOk: () {
                Navigator.of(context).pop();
              },
              descriptionMaxLines: 2,
              status: DialogStatus.success, 
              descriptionSize: 14,
              description: "You have Successfully bought full course, Enjoy!", );
            },
            )
          ],
        
        ),
      ),
    );
  }
}