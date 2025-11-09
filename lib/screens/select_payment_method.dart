import 'package:flutter/material.dart';
import 'package:icare/widgets/payment_method_card.dart';

class SelectPaymentMethod extends StatefulWidget {
  const SelectPaymentMethod({super.key});

  @override
  State<SelectPaymentMethod> createState() => _SelectPaymentMethodState();
}

class _SelectPaymentMethodState extends State<SelectPaymentMethod> {
  
  final List<Map<String, String>> paymentMethods = [
    {'type': 'VISA', 'number': '**** **** **** 1313', 'expiry': '08/26'},
    {'type': 'MasterCard', 'number': '**** **** **** 1313', 'expiry': '08/26'},
    {'type': 'Amex', 'number': '**** **** **** 1313', 'expiry': '08/26'},
    {'type': 'VISA', 'number': '**** **** **** 1313', 'expiry': '08/26'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: paymentMethods.length,
        itemBuilder: (ctx,i) {
          final item = paymentMethods[i];
           return (
              PaymentMethodCard(
                
              )
           );
      })
    );
  }
}