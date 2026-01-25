import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/app_enums.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_circle_icon_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/order_card.dart';

class RecievedOrders extends StatelessWidget {
  const RecievedOrders({super.key});

  @override
  Widget build(BuildContext context) {
    var jsonData = {
  "orders": [
    {
      "id": "ORD-1001",
      "labName": "Quantum Spar Lab",
      "status": "delivered",
      "products": [
        {
          "id": "P1",
          "name": "Capsule",
          "image": ImagePaths.capsule
        },
        {
          "id": "P2",
          "name": "Syrup",
          "image": ImagePaths.capsule2,
        }
      ],
      "patient": {
        "name": "Sadia",
        "age": 32,
        "phone": "0309894375",
        "address": "Shahrah-e-Faisal near KFC Street 1"
      },
      "orderInfo": {
        "date": "21 June 2025",
        "time": "12:00 PM",
        "amount": 6000
      }
    },
    {
      "id": "ORD-1001",
      "labName": "Quantum Spar Lab",
      "status": "delivered",
      "products": [
        {
          "id": "P1",
          "name": "Capsule",
          "image": ImagePaths.capsule
        },
        {
          "id": "P2",
          "name": "Syrup",
          "image": ImagePaths.capsule2,
        }
      ],
      "patient": {
        "name": "Sadia",
        "age": 32,
        "phone": "0309894375",
        "address": "Shahrah-e-Faisal near KFC Street 1"
      },
      "orderInfo": {
        "date": "21 June 2025",
        "time": "12:00 PM",
        "amount": 6000
      }
    },
  ]
};

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: 'Cancelled Orders',
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: jsonData['orders']!.length,
          itemBuilder: (ctx,i) => OrderCard(
            order: jsonData['orders']![i],
            type: OrderType.recent,
          ))
        
        );
  }



}

