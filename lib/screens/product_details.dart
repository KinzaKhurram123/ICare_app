import 'package:flutter/material.dart';
import 'package:icare/screens/select_payment_method.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final product = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: CustomBackButton(),
        ),
        title: CustomText(
          text: "Pharmacy Store",
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: Color(0xFF0F172A)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
            child: isDesktop ? _buildDesktopLayout(product) : _buildMobileLayout(product),
          ),
        ),
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomAction(context, product) : null,
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Product Images & Gallery
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Hero(
                      tag: 'product_image_${product['_id']}',
                      child: Icon(
                        Icons.medication_liquid_rounded,
                        size: 200,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: i == 0 ? AppColors.primaryColor : Colors.transparent, width: 2),
                    ),
                    child: Icon(
                      Icons.medication_liquid_rounded,
                      size: 40,
                      color: AppColors.primaryColor.withOpacity(0.5),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          // Right: Product Info
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductBadge(product),
                const SizedBox(height: 16),
                CustomText(
                  text: product['productName'] ?? "Liver Cleanse Capsule",
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                ),
                const SizedBox(height: 12),
                _buildRatingPriceRow(product),
                const SizedBox(height: 32),
                _buildDescriptionSection(product),
                const SizedBox(height: 40),
                _buildQuantitySelector(),
                const SizedBox(height: 48),
                _buildDesktopActions(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> product) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 350,
          color: Colors.white,
          child: Center(
            child: Hero(
              tag: 'product_image_${product['_id']}',
              child: Icon(
                Icons.medication_liquid_rounded,
                size: 150,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductBadge(product),
              const SizedBox(height: 12),
              CustomText(
                text: product['productName'] ?? "Liver Cleanse Capsule",
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
              const SizedBox(height: 8),
              _buildRatingPriceRow(product),
              const SizedBox(height: 24),
              _buildDescriptionSection(product),
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductBadge(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: product['medicineType'] ?? "Prescription Required",
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRatingPriceRow(Map<String, dynamic> product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber[600], size: 24),
            const SizedBox(width: 4),
            CustomText(text: "4.9", fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
            const SizedBox(width: 8),
            CustomText(text: "(2.4k Reviews)", fontSize: 14, color: const Color(0xFF64748B)),
          ],
        ),
        CustomText(
          text: "Rs. ${product['price'] ?? 0.0}",
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "Product Details", fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
        const SizedBox(height: 12),
        CustomText(
          text: product['description'] ?? "Premium quality pharmaceutical product designed for effective health support. Formulated with high-potency ingredients for maximum efficacy.",
          fontSize: 15,
          color: const Color(0xFF64748B),
          lineHeight: 1.6,
        ),
        const SizedBox(height: 24),
        _buildInfoRow(Icons.verified_user_rounded, "Certified Pharmaceutical Grade"),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.local_shipping_rounded, "Standard Delivery (2-3 Days)"),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        CustomText(text: text, fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        CustomText(text: "Quantity", fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        const SizedBox(width: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1),
                icon: const Icon(Icons.remove, size: 18),
              ),
              CustomText(text: "$_quantity", fontSize: 18, fontWeight: FontWeight.w900),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopActions(Map<String, dynamic> product) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: "Add to Cart",
            height: 64,
            borderRadius: 20,
            bgColor: Colors.white,
            labelColor: AppColors.primaryColor,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
            label: "Buy Now",
            height: 64,
            borderRadius: 20,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SelectPaymentMethod(amount: (product['price'] ?? 0.0).toDouble()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0F172A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              label: "Get for Rs. ${product['price'] ?? 0}",
              height: 56,
              borderRadius: 16,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => SelectPaymentMethod(amount: (product['price'] ?? 0.0).toDouble()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
