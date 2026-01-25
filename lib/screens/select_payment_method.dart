import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/add_card.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/payment_method_card.dart';
import 'package:icare/widgets/back_button.dart';

class SelectPaymentMethod extends StatefulWidget {
  const SelectPaymentMethod({super.key});

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  final List<Map<String, String>> paymentMethods = [
    {
      'type': 'VISA',
      'logo': ImagePaths.apple,
      'number': '**** **** **** 1313',
      'expiry': '08/26',
    },
    {
      'type': 'MasterCard',
      'logo': ImagePaths.mc,
      'number': '**** **** **** 1313',
      'expiry': '08/26',
    },
    {
      'type': 'Amex',
      'logo': ImagePaths.gpay,
      'number': '**** **** **** 1313',
      'expiry': '08/26',
    },
    {
      'type': 'VISA',
      'logo': ImagePaths.visa,
      'number': '**** **** **** 1313',
      'expiry': '08/26',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Select Payment MMethod",
          fontWeight: FontWeight.bold,
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScallingConfig.scale(15),
          vertical: ScallingConfig.verticalScale(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "Choose Platform ",
              fontFamily: "Gilroy-Bold",
              fontSize: 14,
              color: AppColors.primary500,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (ctx, i) {
                  final item = paymentMethods[i];
                  log('logo == >  ${item['logo']}');
                  return (PaymentMethodCard(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => AddCard()));
                    },
                    expiry: item['expiry'],
                    number: item['number'],
                    type: item['type'],
                    logo: item['logo'],
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
