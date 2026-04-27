import 'package:flutter/material.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/screens/pharmacy_details.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  List<dynamic> _pharmacies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPharmacies();
  }

  Future<void> _fetchPharmacies() async {
    try {
      final data = await _pharmacyService.getAllPharmacies();
      if (mounted) {
        setState(() {
          _pharmacies = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pharmacies: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: CustomBackButton(),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: CustomText(
          text: "Pharmacies",
          fontFamily: "Gilroy-Bold",
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pharmacies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_pharmacy_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No pharmacies found',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search and Filter Header
                        _buildSearchHeader(context, isDesktop),
                        const SizedBox(height: 32),

                        // Categories Row
                        _buildCategories(isDesktop),
                        const SizedBox(height: 40),

                        // Section title
                        CustomText(
                          text: "Available Pharmacies (${_pharmacies.length})",
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                        const SizedBox(height: 24),

                        // Pharmacy Grid/List
                        isDesktop ? _buildPharmacyGrid() : _buildPharmacyList(),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Sidebar removed as per user request to avoid adding things not in mobile

  Widget _buildSearchHeader(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: CustomInputField(
            margin: EdgeInsets.zero,
            height: 54,
            width: double.infinity,
            hintText: "Search for medicines or pharmacies...",
            leadingIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF0F172A),
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(bool isDesktop) {
    final categories = [
      {
        "name": "Baby Care",
        "icon": Icons.child_care_rounded,
        "color": const Color(0xFFF472B6),
      },
      {
        "name": "Skin Care",
        "icon": Icons.face_rounded,
        "color": const Color(0xFF60A5FA),
      },
      {
        "name": "Vitamins",
        "icon": Icons.auto_awesome_rounded,
        "color": const Color(0xFFFBBF24),
      },
      {
        "name": "Pain Relief",
        "icon": Icons.healing_rounded,
        "color": const Color(0xFF34D399),
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: categories
          .map(
            (cat) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: (cat["color"] as Color).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat["icon"] as IconData,
                    color: cat["color"] as Color,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  CustomText(
                    text: cat["name"] as String,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPharmacyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pharmacies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 320,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemBuilder: (ctx, i) => PharmacyWidget(pharmacy: _pharmacies[i]),
    );
  }

  Widget _buildPharmacyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pharmacies.length,
      itemBuilder: (ctx, i) => PharmacyWidget(pharmacy: _pharmacies[i]),
    );
  }
}

class PharmacyWidget extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  const PharmacyWidget({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => PharmacyDetailsScreen(pharmacy: pharmacy),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pharmacy Image with premium detail
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.12,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                ImagePaths.pharmacyLogo,
                                fit: BoxFit.cover,
                                width: 75,
                                height: 75,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Pharmacy Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text:
                                        pharmacy['user']?['name'] ?? 'Pharmacy',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: "Gilroy-Bold",
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (pharmacy['isApproved'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFBEB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFFEF3C7),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: Color(0xFFD97706),
                                        ),
                                        const SizedBox(width: 4),
                                        CustomText(
                                          text: "Verified",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF92400E),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: CustomText(
                                    text:
                                        pharmacy['address'] ??
                                        'Address not available',
                                    color: const Color(0xFF64748B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (pharmacy['deliveryAvailable'] == true)
                                  _buildStatusTag(
                                    "Free Delivery",
                                    const Color(0xFF0EA5E9),
                                  ),
                                if (pharmacy['deliveryAvailable'] == true)
                                  const SizedBox(width: 8),
                                if (pharmacy['openHours'] != null)
                                  _buildStatusTag(
                                    "${pharmacy['openHours']['from'] ?? ''}-${pharmacy['openHours']['to'] ?? ''}",
                                    const Color(0xFF6366F1),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: pharmacy['city'] != null
                                ? "Location"
                                : "Pickup Type",
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                pharmacy['city'] != null
                                    ? Icons.location_city_rounded
                                    : Icons.access_time_filled_rounded,
                                size: 12,
                                color: const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              CustomText(
                                text: pharmacy['city'] ?? "15-20 Mins",
                                color: const Color(0xFF0F172A),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: CustomButton(
                            label: "Visit Pharmacy",
                            height: 44,
                            borderRadius: 14,
                            labelSize: 12,
                            labelWeight: FontWeight.w900,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF334155)],
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      PharmacyDetailsScreen(pharmacy: pharmacy),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        text: label,
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
