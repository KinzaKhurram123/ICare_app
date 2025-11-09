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

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
          appBar: AppBar(
            leading: CustomBackButton(),
            automaticallyImplyLeading: false,
            title: CustomText(text:"Top Up")
          ),
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           CustomInputField(
            // margin: EdgeInsets.only(left: ScallingConfig.scale(24)),
            width: Utils.windowWidth(context) * 0.85,
            height: Utils.windowHeight(context) * 0.078,
            title: "Total Balance",
            titleColor: AppColors.darkGreyColor,
            borderRadius: 10,
            keyboardType: TextInputType.number,
            borderColor: AppColors.primaryColor,
            hintText: "Total Balance"),
            SizedBox(height: ScallingConfig.scale(20) ,),
            CustomButton(label: "Transfer", borderRadius: 30, width: Utils.windowWidth(context) * 0.85,
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
              description: "You have successfully tranfer you 3500 in your account.", );
            },
            )
          ],
        
        ),
      ),
    );
  }
}