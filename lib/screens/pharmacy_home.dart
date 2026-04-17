import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/pharmacy_filter.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
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
    final bool isDesktop = Utils.windowWidth(context) > 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stunning Pharmacy Banner
          _buildHeroBanner(context, isDesktop),
          
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 20,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
                Center(
                  child: CustomInputField(
                    width: isDesktop ? 800 : Utils.windowWidth(context) * 0.9,
                    hintText: "Search medications, health products...",
                    trailingIcon: SvgWrapper(
                      assetPath: ImagePaths.filters,
                      onPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => PharmacyFilterScreen()),
                        );
                      },
                    ),
                    leadingIcon: SvgWrapper(assetPath: ImagePaths.search),
                  ),
                ),
                SizedBox(height: ScallingConfig.scale(30)),
                
                // Categories
                CustomText(
                  text: "Health Categories",
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(height: 20),
                PharmcyCategories(
                  selectedCategory: selectedCategory,
                  onCategorySelect: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  categories: [
                    {"id": "1", "name": "Pain Relief", "icon": ImagePaths.pain},
                    {"id": "2", "name": "Vitamins", "icon": ImagePaths.vitamins},
                    {"id": "3", "name": "Skincare", "icon": ImagePaths.skin_care},
                    {"id": "4", "name": "Baby Care", "icon": ImagePaths.baby_care},
                  ],
                ),
                SizedBox(height: ScallingConfig.scale(40)),
                
                // Products
                const SellerProducts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      height: isDesktop ? 340 : 220,
      margin: EdgeInsets.all(isDesktop ? 24 : 0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(isDesktop ? 30 : 0),
        image: DecorationImage(
          image: const NetworkImage(
            "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=2070",
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 30 : 0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.0),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CustomText(
                text: "✨ 20% OFF FIRST ORDER",
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            CustomText(
              text: "Your Trusted\nPharmacy Partner",
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              lineHeight: 1.1,
            ),
            const SizedBox(height: 12),
            CustomText(
              text: "Genuine medicines delivered in 60 mins.",
              fontSize: isDesktop ? 18 : 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }
}
