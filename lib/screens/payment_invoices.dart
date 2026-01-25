import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';

class PaymentInvoices extends StatelessWidget {
  const PaymentInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(text: "Receipt" , 
        fontFamily: "Gilroy-Bold",
        fontSize: 16.78,
        fontWeight: FontWeight.bold,
            letterSpacing: -0.31,
            lineHeight: 1.0,
        color: AppColors.primary500,),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20)),
        itemCount: 2,
        itemBuilder: (ctx, i) {
        return Padding(
          padding: EdgeInsets.only(bottom:ScallingConfig.scale(10)),
          child: (
             Image.asset(ImagePaths.receipt,
             width: Utils.windowWidth(context) * 0.8,
             height: Utils.windowHeight(context) * 0.65,
             fit: BoxFit.contain,
             )
            // )
          ),
        );
      }) ,
    );
  }
}