import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/models/cart.dart';
import 'package:icare/models/product.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/cart_item.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/row_text.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class MyCartScreen extends StatelessWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "My Cart",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
      ),
      body:  Column(
          children: [
            CartList(),
            SizedBox(height: ScallingConfig.scale(30)),
            DiscountCodeField(),
            SizedBox(height: ScallingConfig.scale(30)),
            RowText(leadingText: "Sub Total",trailingText: "6000",),
            SizedBox(height: ScallingConfig.scale(10)),
            RowText(leadingText: "Discount",trailingText: "10%",),
            SizedBox(height: ScallingConfig.scale(10)),
            RowText(leadingText: "Total",trailingText: "5900",),
            SizedBox(height: ScallingConfig.scale(30)),
            CustomButton(
              label: "Checkout",
              width: Utils.windowWidth(context) * 0.9,
              borderRadius: 70,
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()));
              },
            )
            ]),
    );
  }
}

class CartList extends StatelessWidget {
  const CartList({super.key});
  @override
  Widget build(BuildContext context) {
    var cartItems = [
      Cart(
        id: "1",
        product: Product(
          id: "p1",
          title: "Vitamin B3",
          category: "Pharma",
          ratings: "(2.9)",
          link: "nan Pahrma",
          image: ImagePaths.capsule2,
          price: 2000,
        ),
        quantity: 1,
      ),
      Cart(
        id: "2",
        product: Product(
          id: "p2",
          title: "Liver Cleanse Capsule",
          category: "Pharma",
          ratings: "(2.9)",
          link: "nan Pahrma",
          image: ImagePaths.capsule,
          price: 2000,
        ),
        quantity: 1,
      ),
      Cart(
        id: "3",
        product: Product(
          id: "p3",
          title: "Vitamin B3",
          category: "Pharma",
          ratings: "(2.9)",
          link: "nan Pahrma",
          image: ImagePaths.capsule2,
          price: 2000,
        ),
        quantity: 1,
      ),
    ];
    return SizedBox(
      width: Utils.windowWidth(context),
      height: Utils.windowHeight(context) * 0.4,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(15)),

        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return (Dismissible(

            secondaryBackground: Container(
              padding: EdgeInsets.only(
                left: ScallingConfig.scale(220),
                top: ScallingConfig.verticalScale(10),
                bottom: ScallingConfig.verticalScale(10),
              ),
              decoration: BoxDecoration(
                color: AppColors.themeRed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgWrapper(
                assetPath: ImagePaths.trash,
                fit: BoxFit.scaleDown,
                ),
            ),
            background: Container(color: AppColors.themeRed),
            onDismissed: (direction) {
              log(direction.toString());
            },
            key: ValueKey(cartItems[index].id),
            child: CartItem(item: cartItems[index]),
          ));
        },
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem({super.key, this.item});
  final Cart? item;
  @override
  Widget build(BuildContext context) {
    return (Container(
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
      child: Row(
        spacing: ScallingConfig.scale(25),
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(20),
            child: Image.asset(
              item!.product!.image ?? ImagePaths.capsule,
              width: ScallingConfig.scale(70),
              height: ScallingConfig.scale(70),
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: item!.product!.title,
                fontFamily: "Gilroy-Bold",
                fontSize: 14.78,
                letterSpacing: -0.3,
                lineHeight: 1.0,
                color: AppColors.primary500,
                fontWeight: FontWeight.w400,
              ),
              CustomText(
                text: item!.product!.category,
                fontFamily: "Gilroy-Regular",
                fontSize: 14.78,
                color: AppColors.primary500,
                fontWeight: FontWeight.w400,
              ),
              Row(
                spacing: ScallingConfig.scale(50),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'RS ${item!.product!.price.toString()}',
                    fontFamily: "Gilroy-Bold",
                    fontSize: 18.78,
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w400,
                  ),
                  CartActions(),
                ],
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class CartActions extends StatelessWidget {
  const CartActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScallingConfig.scale(5)),
      decoration: BoxDecoration(
        color: AppColors.tertiaryColor.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        spacing: ScallingConfig.scale(10),
        children: [
          CustomButton(
            borderRadius: 3,
            bgColor: AppColors.bgColor,
            width: ScallingConfig.scale(20),
            height: ScallingConfig.scale(20),
          ),
          CustomText(
            text: "1",
            fontFamily: "Gilroy-Bold",
            fontSize: 14.78,
            letterSpacing: -0.3,
            lineHeight: 1.0,
            color: AppColors.primary500,
            fontWeight: FontWeight.w400,
          ),
          CustomButton(
            borderRadius: 3,
            width: ScallingConfig.scale(20),
            height: ScallingConfig.scale(20),
          ),
        ],
      ),
    );
  }
}


class DiscountCodeField extends StatelessWidget {
  const DiscountCodeField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Utils.windowWidth(context) * 0.9,
height: ScallingConfig.scale(60),
      decoration: BoxDecoration(
        color: AppColors.lightGrey600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
 Expanded(
   child: Center(
     child: CustomInputField(
                height: ScallingConfig.scale(45),
                hintStyle: TextStyle(
                  color: AppColors.primary500,
                  fontFamily: "Gilroy-Medium",
                  fontWeight: FontWeight.w400,
                  fontSize: ScallingConfig.moderateScale(16.78)
                ),
                bgColor: Colors.transparent,
                hintText: "Enter Discount Code"),
   ),
 ),
          CustomButton(
            label: "Apply",
            width: Utils.windowWidth(context) * 0.3,
            height: ScallingConfig.scale(50),
            borderRadius: 50,
          )
        ],
      ),
    );
  }
}