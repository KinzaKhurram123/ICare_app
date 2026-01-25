import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/product_details.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_circle_icon_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/section_header.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class SellerProducts extends StatelessWidget {
  const SellerProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: "Best Seller Products",
        padding: EdgeInsets.symmetric(
          horizontal: ScallingConfig.scale(10),
        )),
        GridView.builder(
            itemCount: 5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: Utils.windowHeight(context) * 0.27,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (ctx, i) {
              return (
                ProductCard(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProductDetailsScreen()));
                  },
                showAddToCart: true,)
              );
            },
          ),
       
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, 
  this.showAddToCart = false,
  this.showRemove = false,
  this.onAdd,
  this.onRemove,
  this.onTap,
  });
  final bool showAddToCart;
  final bool  showRemove;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Utils.windowHeight(context) * 0.25, // SAME as grid extent
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              // margin: EdgeInsets.only(top: ScallingConfig.verticalScale(18), ),
              padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(10)),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurStyle: BlurStyle.inner,
                    spreadRadius: 5,
                    blurRadius: 7,
                    color: AppColors.lightGrey200.withAlpha(90),
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: ScallingConfig.verticalScale(10)),
                  Image.asset(ImagePaths.capsule,
                  width: double.infinity,
                  height: ScallingConfig.scale(120),
                  ),
                  CustomText(
                    width: double.infinity,
                    text: "Liver Cleanse Capsule",
                    fontFamily: "Gilroy-SemiBold",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.primary500,
                    lineHeight: 1.0,
                    letterSpacing: -0.3,
                  ),
                  SizedBox(height: ScallingConfig.verticalScale(5)),
            
                  Row(
                    children: [
                      CustomText(
                        text: "Visit:",
                        color: AppColors.darkGray500,
                        letterSpacing: -0.6,
                        lineHeight: 1.0,
                      ),
                      CustomText(
                        text: "NAN Pharma",
                        color: AppColors.primaryColor,
                        underline: true,
                        letterSpacing: -0.6,
                        lineHeight: 1.0,
                      ),
                    ],
                  ),
                  SizedBox(height: ScallingConfig.verticalScale(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconText(icon: ImagePaths.star_filled, 
                      text: "4.9 (2.75)"),
                      CustomText(
                        text: "Rs. 2000",
                        fontFamily: "Gilroy-SemiBold",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if(showAddToCart)
              Positioned(
              top: ScallingConfig.verticalScale(-5),
              right: ScallingConfig.scale(-10),
              child: CustomCircleIconButton(
                iconPath: ImagePaths.cart,
                bgColor: AppColors.primaryColor,
                onTap: onAdd,
                size: 30,
              ),
            ),
          if(showRemove)
              Positioned(
              top: ScallingConfig.verticalScale(-5),
              right: ScallingConfig.scale(-5),
              child: CustomCircleIconButton(
                iconData: Icons.remove,
                iconColor: AppColors.white,
                bgColor: AppColors.themeRed,
                onTap: onRemove,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}



class IconText extends StatelessWidget {
  const IconText({super.key, this.icon, this.text="", this.textColor, this.iconColor});
  final dynamic icon;
  final String? text;
  final Color? textColor;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgWrapper(assetPath: icon, color: iconColor,),
        SizedBox(width: ScallingConfig.scale(4),),
        CustomText(text: "(2.49)",
        fontFamily: "Gilroy-Regular",
        color: AppColors.grayColor,
        fontSize: 12,
        lineHeight: 1.0,
        letterSpacing: -0.5,
        )
      ],
    );
  }
}