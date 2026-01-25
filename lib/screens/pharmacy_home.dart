import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/filters.dart';
import 'package:icare/screens/pharmacy_filter.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/pharmcy_categories.dart';
import 'package:icare/widgets/seller_products.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class PharmacyHome extends StatefulWidget {
  const PharmacyHome({super.key});

  @override
  State<PharmacyHome> createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  
  String selectedCategory = "";
  @override
  Widget build(BuildContext context) {
    return Column(

        children: [
           CustomInputField(
                width: Utils.windowWidth(context) * 0.9,
        
                hintText: "Search",
                trailingIcon: SvgWrapper(
                  assetPath: ImagePaths.filters,
                  onPress: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (ctx) => PharmacyFilterScreen()));
                  },
                ),
                leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
              ),
        SizedBox(height: ScallingConfig.scale(20),),
             PharmcyCategories(
              selectedCategory: selectedCategory,
              onCategorySelect: (value) {
                setState(() {
                  selectedCategory = value;
                });
                print("Selected Category: $value");
              },
              categories: [
              {"id" :"1", "name" : "Pain", "icon": ImagePaths.pain},
              {"id" :"2", "name" : "Vitamins", "icon": ImagePaths.vitamins},
              {"id" :"3", "name" : "Skincare", "icon": ImagePaths.skin_care},
              {"id" :"4", "name" : "Babycare", "icon": ImagePaths.baby_care},
             ],),
        SizedBox(height: ScallingConfig.scale(20),),
             SellerProducts(),
        ],
      );
   
  }
}