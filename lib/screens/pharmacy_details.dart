import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/product_details.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/seller_products.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PharmacyDetailsScreen extends StatelessWidget {
  const PharmacyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: "Pharmacies",
          fontFamily: "Gilroy-Bold",
          fontSize: 16.78,
          color: AppColors.primary500,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Image.asset(
                ImagePaths.pharmacyLogo,
                width: ScallingConfig.scale(100),
                height: ScallingConfig.scale(100),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Green Pharmacy",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Gilroy-Bold",
                    color: AppColors.themeDarkGrey,
                  ),
                  SizedBox(height: ScallingConfig.verticalScale(5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.location),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: "20 Cooper Square, USA",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgWrapper(assetPath: ImagePaths.delievry),
                      SizedBox(width: ScallingConfig.scale(6)),
                      CustomText(
                        text: "Home Delievery: 25min",
                        color: AppColors.darkGreyColor,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          CustomText(
            text:
                "Our Pharmacy combines advanced diagnostic technology with the expertise of highly qualified professionals, ensuring every test is conducted with precision, accuracy, and reliability to support better healthcare outcomes.",
            maxLines: 30,
            width: Utils.windowWidth(context) * 0.9,
            fontFamily: "Gilroy-SemiBold",
            color: AppColors.grayColor,
            fontSize: 10.59,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(height: ScallingConfig.scale(5)),
          CustomText(
            text: "Our Products",
            maxLines: 30,
            width: Utils.windowWidth(context) * 0.9,
            fontFamily: "Gilroy-Bold",
            color: AppColors.primary500,
            fontSize: 16.89,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(height: ScallingConfig.scale(5)),

          SizedBox(
            height: Utils.windowHeight(context) * 0.6,
            child: ProductsList(),
          ),
        ],
      ),
    );
  }
}

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 8,

      shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: Utils.windowHeight(context) * 0.27,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (ctx, i) {
        return (ProductCard(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => ProductDetailsScreen()));
          },
          showAddToCart: true,
        ));
      },
    );
  }
}
