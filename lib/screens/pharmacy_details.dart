import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:icare/services/cart_service.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class PharmacyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacy;
  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final CartService _cartService = CartService();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _medicines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  XFile? _selectedPrescription;
  final Set<String> _addingToCart = {};

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _addToCart(dynamic med) async {
    final id = med['_id']?.toString() ?? '';
    if (id.isEmpty || _addingToCart.contains(id)) return;
    setState(() => _addingToCart.add(id));
    try {
      await _cartService.addItem(id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${med['productName']} added to cart'),
          backgroundColor: AppColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to add to cart. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _addingToCart.remove(id));
    }
  }

  Future<void> _fetchMedicines() async {
    try {
      final pharmacyId = widget.pharmacy['_id'];
      final data = await _pharmacyService.getMedicinesByPharmacyId(pharmacyId);
      if (mounted) {
        setState(() {
          _medicines = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPrescription() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPrescription = image;
      });
      _showUploadConfirmation();
    }
  }

  void _showUploadConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomText(
              text: "Prescription Selected",
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: kIsWeb
                  ? Image.network(
                      _selectedPrescription!.path,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_selectedPrescription!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: "Cancel",
                    bgColor: Colors.grey[100],
                    labelColor: Colors.black,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: "Confirm & Order",
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order sent to pharmacy!"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> get _filteredMedicines {
    if (_searchQuery.isEmpty) return _medicines;
    return _medicines.where((m) {
      final name = (m['productName'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPharmacyInfo(),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 30),
                      _buildCategories(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Available Medicines",
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          CustomText(
                            text: "${_filteredMedicines.length} items",
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _filteredMedicines.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 2,
                          mainAxisExtent: 260,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildMedicineCard(_filteredMedicines[index]),
                          childCount: _filteredMedicines.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: CustomBackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        ImagePaths.pharmacyLogo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: widget.pharmacy['user']?['name'] ?? 'Pharmacy',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      const SizedBox(width: 8),
                      if (widget.pharmacy['isApproved'] == true)
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.blueAccent,
                          size: 20,
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

  Widget _buildPharmacyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.star_rounded, "4.8", "Rating", Colors.amber),
          _divider(),
          _infoItem(
            Icons.access_time_filled_rounded,
            widget.pharmacy['openHours'] != null
                ? "${widget.pharmacy['openHours']['from']}-${widget.pharmacy['openHours']['to']}"
                : "8AM-10PM",
            "Hours",
            Colors.blue,
          ),
          _divider(),
          _infoItem(
            Icons.delivery_dining_rounded,
            widget.pharmacy['deliveryAvailable'] == true ? "Free" : "Pickup",
            "Delivery",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        CustomText(text: value, fontWeight: FontWeight.bold, fontSize: 13),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2));

  Widget _buildSearchBar() {
    return CustomInputField(
      hintText: "Search for specific medicine...",
      borderRadius: 16,
      borderColor: const Color(0xFFF1F5F9),
      bgColor: const Color(0xFFF8FAFC),
      leadingIcon: const Icon(Icons.search_rounded, color: Colors.grey),
      onChanged: (v) => setState(() => _searchQuery = v),
    );
  }

  Widget _buildCategories() {
    final categories = [
      "Prescriptions",
      "OTC Medicines",
      "Vitamins",
      "Personal Care",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (cat) => Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomText(
                  text: cat,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMedicineCard(dynamic med) {
    final id = med['_id']?.toString() ?? '';
    final isAdding = _addingToCart.contains(id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  size: 50,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomText(
            text: med['productName'] ?? 'Medicine Name',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            med['brand'] ?? 'Pharma Co.',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Rs ${med['price'] ?? 0.0}",
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
              GestureDetector(
                onTap: isAdding ? null : () => _addToCart(med),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isAdding ? Colors.grey[300] : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isAdding
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const CustomText(
            text: "No medicines found",
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          const Text(
            "Try searching for something else",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: InkWell(
        onTap: _pickPrescription,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.upload_file_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const CustomText(
                text: "Upload Prescription",
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
