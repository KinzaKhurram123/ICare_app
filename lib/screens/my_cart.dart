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
    final bool isDesktop = Utils.windowWidth(context) > 900;

    if (isDesktop) {
      return _buildWebLayout(context);
    }

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
      body: Column(children: [
        CartList(),
        SizedBox(height: ScallingConfig.scale(30)),
        DiscountCodeField(),
        SizedBox(height: ScallingConfig.scale(30)),
        RowText(
          leadingText: "Sub Total",
          trailingText: "6000",
        ),
        SizedBox(height: ScallingConfig.scale(10)),
        RowText(
          leadingText: "Discount",
          trailingText: "10%",
        ),
        SizedBox(height: ScallingConfig.scale(10)),
        RowText(
          leadingText: "Total",
          trailingText: "5900",
        ),
        SizedBox(height: ScallingConfig.scale(30)),
        CustomButton(
          label: "Checkout",
          width: Utils.windowWidth(context) * 0.9,
          borderRadius: 70,
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => SelectPaymentMethod()));
          },
        )
      ]),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product List Area ──────────────────────────────────────────
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            color: AppColors.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Shopping Cart",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "You have 3 items in your cart",
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Header Row for Table-like look
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: Text("PRODUCT",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 1))),
                        Expanded(
                            flex: 2,
                            child: Center(
                                child: Text("QUANTITY",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 1)))),
                        Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text("PRICE",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 1)))),
                        SizedBox(width: 60), // Space for delete icon
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const _WebCartList(),
                ],
              ),
            ),
          ),

          // ── Checkout Summary Sidebar ───────────────────────────────────
          Container(
            width: 400,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(-10, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 32),
                const _WebSummaryRow(label: "Subtotal", value: "PKR 6,000"),
                const _WebSummaryRow(label: "Shipping", value: "Free"),
                const _WebSummaryRow(
                    label: "Discount (10%)", value: "-PKR 600", isNegative: true),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "PKR 5,400",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  "Promo Code",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Enter code...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text("Apply",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => SelectPaymentMethod()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.primaryColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      "Checkout Now",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Continue Shopping",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                      fontSize: ScallingConfig.moderateScale(16.78)),
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

// ── Web Specific Helper Widgets ──────────────────────────────────────────────

class _WebCartList extends StatelessWidget {
  const _WebCartList();

  @override
  Widget build(BuildContext context) {
    var cartItems = [
      Cart(
        id: "1",
        product: Product(
          id: "p1",
          title: "Vitamin B3",
          category: "Health & Wellness",
          ratings: "(4.9)",
          link: "nan Pharma",
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
          category: "Medical Care",
          ratings: "(4.8)",
          link: "nan Pharma",
          image: ImagePaths.capsule,
          price: 2000,
        ),
        quantity: 1,
      ),
      Cart(
        id: "3",
        product: Product(
          id: "p3",
          title: "Multi Vitamin Plus",
          category: "Supplements",
          ratings: "(4.7)",
          link: "nan Pharma",
          image: ImagePaths.capsule2,
          price: 2000,
        ),
        quantity: 1,
      ),
    ];

    return Column(
      children: cartItems.map((item) => _WebCartItemTile(item: item)).toList(),
    );
  }
}

class _WebCartItemTile extends StatelessWidget {
  final Cart item;
  const _WebCartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(item.product!.image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product!.title ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.product!.category ?? '',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quantity
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuantityBtn(Icons.remove, () {}),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "${item.quantity}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                _buildQuantityBtn(Icons.add, () {}),
              ],
            ),
          ),
          // Price
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "PKR ${item.product!.price}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          // Delete
          const SizedBox(width: 20),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.red[300], size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF1E293B)),
      ),
    );
  }
}

class _WebSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _WebSummaryRow(
      {required this.label, required this.value, this.isNegative = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isNegative ? Colors.redAccent : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}