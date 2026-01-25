import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/order_tracking.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Manage Orders",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
      ),
      body: Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
             OrderCard(),
             OrderCard(),
          CustomText(
          text: "Delievered Orders",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),   
             OrderCard(delievered: true,),
             OrderCard(delievered: true,),
          ],
        ),
      ) ,
    );
  }
}



class OrderCard extends StatelessWidget {
  const OrderCard({super.key, this.delievered = false});
final bool delievered;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScallingConfig.verticalScale(10)),
      padding: EdgeInsets.symmetric(vertical: ScallingConfig.verticalScale(7)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey10,
            offset: Offset(1.3, 0.7),
            blurRadius: ScallingConfig.scale(6),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      width: Utils.windowWidth(context) * 0.9,
      child: Column(
        children: [
          Row(
            spacing: ScallingConfig.scale(25),
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(20),
                child: Image.asset(
                ImagePaths.capsule,
                  width: ScallingConfig.scale(70),
                  height: ScallingConfig.scale(70),
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 if(delievered)...[ 
                  CustomText(
                    text: "Delivered by 22/9/205",
                    fontFamily: "Gilroy-Medium",
                    fontSize: 12.78,
                    letterSpacing: -0.3,
                    lineHeight: 1.0,
                    color: AppColors.themeGreen,
                    fontWeight: FontWeight.w400,
                  ),
          SizedBox(height: ScallingConfig.scale(10) ,),
                  ],
                  CustomText(
                    text: "Liver Cleanse Capsule",
                    fontFamily: "Gilroy-Bold",
                    fontSize: 14.78,
                    letterSpacing: -0.3,
                    lineHeight: 1.0,
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w400,
                  ),
                  CustomText(
                    text: "Pharma",
                    fontFamily: "Gilroy-Regular",
                    fontSize: 14.78,
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w400,
                  ),
                  Row(
                    spacing: ScallingConfig.scale(80),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Qty 1',
                        fontFamily: "Gilroy-Regular",
                        fontSize: 14,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w400,
                      ),
                      CustomText(
                        text: 'RS ${2000}',
                        fontFamily: "Gilroy-Bold",
                        fontSize: 18.78,
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w400,
                      ),
                      // CartActions(),
                    ],
                  ),
                ],
                
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(10) ,),
         if(!delievered)...[
          CustomButton(label: "Track Order",
          height: ScallingConfig.scale(45),
 
          borderRadius: 50,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => OrderTrackingScreen()));
          },
          ),
          SizedBox(height: ScallingConfig.scale(10) ,)],
        ],

      ),
    );
  }
}