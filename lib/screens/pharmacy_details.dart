import 'dart:io';
import 'package:dio/dio.dart';
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
  final List<dynamic>? prescribedMedicines;
  const PharmacyDetailsScreen({super.key, required this.pharmacy, this.prescribedMedicines});

  @override
  State<PharmacyDetailsScreen> createState() => _PharmacyDetailsScreenState();
}

class _PharmacyDetailsScreenState extends State<PharmacyDetailsScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final CartService _cartService = CartService();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _medicines = [];
  bool _isLoading = true;
  bool _isPlacingOrder = false;
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
    // Skip mock medicines (they don't exist in database)
    if (id.isEmpty || id.startsWith('mock_')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${med['productName']} — contact pharmacy directly to order'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
      return;
    }
    if (_addingToCart.contains(id)) return;
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
          // If pharmacy has no products, show Pakistani mock medicines
          _medicines = data.isNotEmpty ? data : _getPakistaniMockMedicines();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _medicines = _getPakistaniMockMedicines();
          _isLoading = false;
        });
      }
    }
  }

  /// Pakistani common medicines as fallback when pharmacy has no products
  List<Map<String, dynamic>> _getPakistaniMockMedicines() {
    return [
      {
        '_id': 'mock_1',
        'productName': 'Panadol (Paracetamol 500mg)',
        'brand': 'GSK Pakistan',
        'price': 35,
        'category': 'OTC',
        'description': 'Pain reliever and fever reducer',
        'stock_quantity': 100,
      },
      {
        '_id': 'mock_2',
        'productName': 'Brufen (Ibuprofen 400mg)',
        'brand': 'Abbott Pakistan',
        'price': 85,
        'category': 'OTC',
        'description': 'Anti-inflammatory pain reliever',
        'stock_quantity': 80,
      },
      {
        '_id': 'mock_3',
        'productName': 'Augmentin (Amoxicillin 625mg)',
        'brand': 'GSK Pakistan',
        'price': 420,
        'category': 'Prescription',
        'description': 'Antibiotic for bacterial infections',
        'stock_quantity': 50,
      },
      {
        '_id': 'mock_4',
        'productName': 'Risek (Omeprazole 20mg)',
        'brand': 'Getz Pharma',
        'price': 180,
        'category': 'Prescription',
        'description': 'Acid reflux and stomach ulcer treatment',
        'stock_quantity': 60,
      },
      {
        '_id': 'mock_5',
        'productName': 'Glucophage (Metformin 500mg)',
        'brand': 'Merck Pakistan',
        'price': 95,
        'category': 'Prescription',
        'description': 'Diabetes management medication',
        'stock_quantity': 70,
      },
      {
        '_id': 'mock_6',
        'productName': 'Lipitor (Atorvastatin 20mg)',
        'brand': 'Pfizer Pakistan',
        'price': 320,
        'category': 'Prescription',
        'description': 'Cholesterol lowering medication',
        'stock_quantity': 45,
      },
    ];
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
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _placePrescriptionOrder();
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

  Future<void> _placePrescriptionOrder() async {
    final pharmacyId = widget.pharmacy['_id']?.toString() ?? '';
    if (pharmacyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pharmacy ID not found'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isPlacingOrder = true);
    try {
      final medicines = widget.prescribedMedicines ?? [];
      await _pharmacyService.createPrescriptionOrder(
        pharmacyId: pharmacyId,
        medicines: medicines,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed! Pharmacy will confirm shortly.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to place order';
        if (e is DioException) {
          // Extract the actual backend error message
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            errorMsg = data['message'].toString();
          } else {
            errorMsg = 'Server error (${e.response?.statusCode ?? 'unknown'}). Please try again.';
          }
        } else {
          errorMsg = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
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
                      if (widget.prescribedMedicines != null && widget.prescribedMedicines!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildPrescribedMedicinesBanner(),
                      ],
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
                        text: widget.pharmacy['pharmacy_name']?.toString()
                            ?? widget.pharmacy['pharmacyName']?.toString()
                            ?? widget.pharmacy['user']?['name']?.toString()
                            ?? widget.pharmacy['name']?.toString()
                            ?? 'Pharmacy',
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

  Widget _buildPrescribedMedicinesBanner() {
    final meds = widget.prescribedMedicines!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor's Prescription",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('Prescribed medicines with dosage details',
                          style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${meds.length} Medicine${meds.length > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Medicine cards — lab jaisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: meds.map((m) {
                final name = m is Map
                    ? (m['name'] ?? m['medicineName'] ?? '').toString()
                    : m.toString();
                final dosage = m is Map ? (m['dosage'] ?? '').toString() : '';
                final frequency = m is Map ? (m['frequency'] ?? '').toString() : '';
                final duration = m is Map ? (m['duration'] ?? '').toString() : '';
                final day = m is Map ? (m['day'] ?? '').toString() : '';
                final noon = m is Map ? (m['noon'] ?? '').toString() : '';
                final night = m is Map ? (m['night'] ?? '').toString() : '';
                final instructions = m is Map ? (m['instructions'] ?? '').toString() : '';

                // Calculate quantity: day + noon + night × duration days
                int totalQty = 0;
                try {
                  final d = int.tryParse(day) ?? 0;
                  final n = int.tryParse(noon) ?? 0;
                  final ni = int.tryParse(night) ?? 0;
                  final perDay = d + n + ni;
                  // Extract number from duration string e.g. "5 days" → 5
                  final durationMatch = RegExp(r'\d+').firstMatch(duration);
                  final durationDays = durationMatch != null ? int.tryParse(durationMatch.group(0)!) ?? 0 : 0;
                  if (perDay > 0 && durationDays > 0) {
                    totalQty = perDay * durationDays;
                  }
                } catch (_) {}

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine name
                      Row(
                        children: [
                          const Icon(Icons.medication_rounded, color: Color(0xFF1D4ED8), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (totalQty > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D4ED8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Qty: $totalQty',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dosage chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (day.isNotEmpty && day != '0')
                            _doseChip('☀️ Day: $day', const Color(0xFFF59E0B)),
                          if (noon.isNotEmpty && noon != '0')
                            _doseChip('🌤️ Noon: $noon', const Color(0xFFEF4444)),
                          if (night.isNotEmpty && night != '0')
                            _doseChip('🌙 Night: $night', const Color(0xFF6366F1)),
                          if (dosage.isNotEmpty && day.isEmpty)
                            _doseChip('💊 $dosage', const Color(0xFF0EA5E9)),
                          if (frequency.isNotEmpty && day.isEmpty)
                            _doseChip('🔄 $frequency', const Color(0xFF10B981)),
                          if (duration.isNotEmpty)
                            _doseChip('📅 $duration', const Color(0xFF64748B)),
                        ],
                      ),
                      // Calculation summary
                      if (totalQty > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            _buildQuantityText(day, noon, night, duration, totalQty),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (instructions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '📝 $instructions',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Order button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPlacingOrder ? null : _placePrescriptionOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: _isPlacingOrder
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isPlacingOrder ? 'Placing Order...' : 'Order All Prescribed Medicines',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text(
                'Or browse & add individual medicines below',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doseChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  String _buildQuantityText(String day, String noon, String night, String duration, int total) {
    final parts = <String>[];
    if (day.isNotEmpty && day != '0') parts.add('Day: $day');
    if (noon.isNotEmpty && noon != '0') parts.add('Noon: $noon');
    if (night.isNotEmpty && night != '0') parts.add('Night: $night');
    final perDay = parts.isNotEmpty ? parts.join(' + ') : '';
    if (perDay.isNotEmpty && duration.isNotEmpty) {
      return '($perDay) × $duration = $total tablets';
    }
    return 'Total: $total tablets';
  }  }

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
    final isMock = id.startsWith('mock_');
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
                    color: isMock
                        ? Colors.grey[300]
                        : isAdding
                            ? Colors.grey[300]
                            : AppColors.primaryColor,
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
                      : Icon(
                          isMock ? Icons.info_outline_rounded : Icons.add_rounded,
                          color: isMock ? Colors.grey[600] : Colors.white,
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
                text: "Upload Physical Rx",
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
