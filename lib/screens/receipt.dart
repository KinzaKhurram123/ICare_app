import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class REceiptScreen extends StatelessWidget {
  const REceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Receipt",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: ScallingConfig.scale(50)),
            Image.asset(ImagePaths.receipt),

            SizedBox(height: ScallingConfig.scale(20)),
            CustomButton(
              label: "Pay Now",
              width: Utils.windowWidth(context) * 0.9,
              borderRadius: 35,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
