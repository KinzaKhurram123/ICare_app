import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/confirm_details.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  var _cardType= "";
  var _nameOnCard= "";
  var _cardNumber= "";
  var _expiry ="";
  var _cvv = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text: "Add Card"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: ScallingConfig.scale(8),),
              CustomText(text: "Add CreditCard ",
              width: Utils.windowWidth(context) * 0.9,
              color: AppColors.primary500,
              fontFamily: "Gilroy-Bold",
              fontWeight: FontWeight.bold,
              
              ),
              SizedBox(height: ScallingConfig.scale(8),),
              CustomInputField(
                title: "Card Type",
                hintText: "Card Type",
                titleColor: AppColors.tertiaryColor,
                titleFontSize: ScallingConfig.moderateScale(14.78),
                hintStyle: TextStyle(
                  color: AppColors.grayColor,
                  fontFamily: "Gilroy-SemiBold",
                  fontSize: 14,
                ),
                onChanged: (value) {
                setState(() {
                  _cardType=value;
                });
                },
                borderRadius: 30,
                borderColor: AppColors.grayColor.withAlpha(70),
                width: Utils.windowWidth(context) * 0.9,
              ),
              CustomInputField(
                title: "Name on Card",
                hintText: "Name on Card",
                titleColor: AppColors.tertiaryColor,
                titleFontSize: ScallingConfig.moderateScale(14.78),
                hintStyle: TextStyle(
                  color: AppColors.grayColor,
                  fontFamily: "Gilroy-SemiBold",
                  fontSize: 14,
                ),
                onChanged: (value) {
                setState(() {
                  _nameOnCard=value;
                });
                },
                borderRadius: 30,
                borderColor: AppColors.grayColor.withAlpha(70),
                width: Utils.windowWidth(context) * 0.9,
              ),
              CustomInputField(
                title: "Card Number",
                hintText: "9900 **07 *7550",
                titleColor: AppColors.tertiaryColor,
                titleFontSize: ScallingConfig.moderateScale(14.78),
                hintStyle: TextStyle(
                  color: AppColors.darkGreyColor,
                  fontFamily: "Gilroy-SemiBold",
                  fontSize: 14,
                ),
                onChanged: (value) {
                setState(() {
                  _cardNumber=value;
                });
                },
                borderRadius: 30,
                borderColor: AppColors.grayColor.withAlpha(70),
                width: Utils.windowWidth(context) * 0.9,
              ),
              SizedBox(height: ScallingConfig.scale(7),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

              CustomInputField(
                title: "Expriy",
                hintText: "MM/YY",
                hintStyle: TextStyle(
                  color: AppColors.grayColor,
                  fontFamily: "Gilroy-SemiBold",
                  fontSize: 14,
                ),
                titleColor: AppColors.tertiaryColor,
                titleFontSize: ScallingConfig.moderateScale(14.78),
                onChanged: (value) {
                setState(() {
                  _expiry=value;
                });
                },
                borderRadius: 30,
                borderColor: AppColors.grayColor.withAlpha(70),
                width: Utils.windowWidth(context) * 0.44,
                                // height: Utils.windowHeight(context) * 0.05,
              ),
              SizedBox(width: ScallingConfig.scale(8),),
              CustomInputField(
                title: "CVV",
                titleColor: AppColors.tertiaryColor,
                titleFontSize: ScallingConfig.moderateScale(14.78),
                hintText: "CVV",
                hintStyle: TextStyle(
                  color: AppColors.grayColor,
                  fontFamily: "Gilroy-SemiBold",
                  fontSize: 14,
                ),
                onChanged: (value) {
                setState(() {
                  _cvv=value;
                });
                },
                borderRadius: 30,
                borderColor: AppColors.grayColor.withAlpha(70),
                width: Utils.windowWidth(context) * 0.44,
                // height: Utils.windowHeight(context) * 0.05,
              ),
                ],
              ),
       
              SizedBox(height: ScallingConfig.scale(30),),
              CustomButton(label: "Add Card", 
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ConfirmDetails()));
              },
              borderRadius: 30, width: Utils.windowWidth(context) * 0.9,)
            ],
          ),
        ),
      ),
    );
  }
}
