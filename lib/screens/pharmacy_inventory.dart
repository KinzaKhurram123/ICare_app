import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:intl/intl.dart';

class PharmacyInventory extends StatefulWidget {
  const PharmacyInventory({super.key});
  @override
  State<PharmacyInventory> createState() => _PharmacyInventoryState();
}

class _PharmacyInventoryState extends State<PharmacyInventory> {
  final PharmacyService _pharmacyService = PharmacyService();
  String _searchQuery = '';
  String _filterCategory = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];

  static const _categories = [
    'All', 'Pain Relief', 'Antibiotic', 'Allergy', 'Vitamins',
    'Diabetes', 'Cholesterol', 'Gastric', 'Blood Pressure',
    'Heart', 'Cough & Cold',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);
      final medicines = await _pharmacyService.getMedicines(
        category: _filterCategory != 'All' ? _filterCategory : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _products = medicines.map<Map<String, dynamic>>((m) => {
          '_id': m['_id'],
          'name': m['productName'] ?? 'Unknown',
          'brand': m['brand'] ?? m['companyName'] ?? '',
          'category': m['category'] ?? 'Other',
          'type': m['medicineType'] ?? 'Tablet',
          'power': m['power'] ?? '',
          'stock': (m['quantity'] ?? 0) as int,
          'price': (m['price'] ?? 0).toDouble(),
          'amount': m['amount'] ?? '',
          'details': m['details'] ?? '',
          'precautions': m['precautions'] ?? '',
          'manufacturer': m['companyName'] ?? '',
          'expiry': m['expiry'] != null
              ? DateTime.parse(m['expiry'])
              : DateTime.now().add(const Duration(days: 365)),
          'isAvailable': m['isAvailable'] ?? true,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load data. Please try again.')));
      }
    }
  }

  void _showAddModal() {
    showDialog(
      context: context,
      builder: (_) => _AddMedicineModal(
        onSave: (data) async {
          try {
            await _pharmacyService.createMedicine(data);
            await _loadProducts();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Medicine added successfully'),
                backgroundColor: Color(0xFF10B981),
              ));
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text('Inventory',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _showAddModal,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, 12, isDesktop ? 32 : 16, 0),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) { setState(() => _searchQuery = v); _loadProducts(); },
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    filled: true, fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((cat) {
                      final sel = _filterCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF64748B),
                          )),
                          selected: sel,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (_) { setState(() => _filterCategory = cat); _loadProducts(); },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? _buildEmpty()
                    : GridView.builder(
                        padding: EdgeInsets.all(isDesktop ? 32 : 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isDesktop ? 0.72 : 0.68,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (_, i) => _MedicineCard(product: _products[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.medication_outlined, size: 72, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('No medicines found', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: _showAddModal,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add First Medicine'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
      ),
    ]),
  );
}

// ── Medicine Card ─────────────────────────────────────────────────────────────
class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _MedicineCard({required this.product});

  Color get _categoryColor {
    switch ((product['category'] as String).toLowerCase()) {
      case 'pain relief': return const Color(0xFFEF4444);
      case 'antibiotic': return const Color(0xFF8B5CF6);
      case 'diabetes': return const Color(0xFF3B82F6);
      case 'vitamins': return const Color(0xFFF59E0B);
      case 'allergy': return const Color(0xFF06B6D4);
      case 'gastric': return const Color(0xFF10B981);
      case 'cholesterol': return const Color(0xFFEC4899);
      case 'blood pressure': return const Color(0xFFEF4444);
      case 'heart': return const Color(0xFFDC2626);
      default: return AppColors.primaryColor;
    }
  }

  IconData get _typeIcon {
    switch ((product['type'] as String).toLowerCase()) {
      case 'syrup': return Icons.local_drink_rounded;
      case 'capsule': return Icons.circle_outlined;
      case 'gel': return Icons.water_drop_rounded;
      case 'injection': return Icons.vaccines_rounded;
      default: return Icons.medication_rounded;
    }
  }

  String get _imageUrl {
    switch ((product['type'] as String).toLowerCase()) {
      case 'syrup': return 'https://img.icons8.com/color/200/cough-syrup.png';
      case 'capsule': return 'https://img.icons8.com/color/200/capsule.png';
      case 'injection': return 'https://img.icons8.com/color/200/syringe.png';
      case 'gel':
      case 'cream': return 'https://img.icons8.com/color/200/ointment.png';
      case 'drops': return 'https://img.icons8.com/color/200/eye-drops.png';
      default: return 'https://img.icons8.com/color/200/pill.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = product['stock'] as int;
    final isLow = stock < 30;
    final expiry = product['expiry'] as DateTime;
    final expiringSoon = expiry.difference(DateTime.now()).inDays < 90;
    final color = _categoryColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLow ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      _imageUrl,
                      height: 72,
                      width: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(_typeIcon, size: 52, color: color.withOpacity(0.7)),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(product['category'], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
                // Stock badge
                if (isLow)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Low Stock', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  if ((product['brand'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(product['brand'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                  if ((product['power'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(product['power'], style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rs ${product['price'].toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Qty: $stock',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 11,
                        color: expiringSoon ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text('Exp: ${DateFormat('MMM yy').format(expiry)}',
                        style: TextStyle(fontSize: 10,
                            color: expiringSoon ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Medicine Modal ────────────────────────────────────────────────────────
class _AddMedicineModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const _AddMedicineModal({required this.onSave});
  @override
  State<_AddMedicineModal> createState() => _AddMedicineModalState();
}

class _AddMedicineModalState extends State<_AddMedicineModal> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _power = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _amount = TextEditingController();
  final _details = TextEditingController();
  final _precautions = TextEditingController();
  String _category = 'Pain Relief';
  String _type = 'Tablet';
  String _delivery = 'both';
  bool _saving = false;

  static const _categories = ['Pain Relief', 'Antibiotic', 'Allergy', 'Vitamins',
    'Diabetes', 'Cholesterol', 'Gastric', 'Blood Pressure', 'Heart', 'Cough & Cold', 'Other'];
  static const _types = ['Tablet', 'Capsule', 'Syrup', 'Gel', 'Injection', 'Drops', 'Cream'];

  @override
  void dispose() {
    for (final c in [_name, _brand, _power, _price, _qty, _amount, _details, _precautions]) c.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5)),
    filled: true, fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave({
      'productName': _name.text.trim(),
      'brand': _brand.text.trim(),
      'power': _power.text.trim(),
      'category': _category,
      'medicineType': _type,
      'price': double.parse(_price.text.trim()),
      'quantity': int.parse(_qty.text.trim()),
      'amount': _amount.text.trim(),
      'details': _details.text.trim(),
      'precautions': _precautions.text.trim(),
      'deliveryOption': _delivery,
      'isAvailable': true,
      'expiry': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Add New Medicine',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(controller: _name, decoration: _dec('Medicine Name *', Icons.medication_rounded),
                          validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(controller: _brand, decoration: _dec('Brand', Icons.business_rounded))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _power, decoration: _dec('Strength (e.g. 500mg)', Icons.science_rounded))),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: _dec('Category', Icons.category_rounded),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _type,
                            decoration: _dec('Type', Icons.local_pharmacy_rounded),
                            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _type = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(controller: _price, decoration: _dec('Price (Rs) *', Icons.attach_money_rounded),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _qty, decoration: _dec('Quantity *', Icons.inventory_rounded),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null)),
                      ]),
                      const SizedBox(height: 12),
                      TextFormField(controller: _amount, decoration: _dec('Pack Size (e.g. 20 tablets)', Icons.straighten_rounded)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _details, decoration: _dec('Description', Icons.description_rounded), maxLines: 2),
                      const SizedBox(height: 12),
                      TextFormField(controller: _precautions, decoration: _dec('Precautions', Icons.warning_amber_rounded), maxLines: 2),
                      const SizedBox(height: 12),
                      // Delivery option
                      const Text('Delivery Option', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      const SizedBox(height: 6),
                      Row(children: [
                        for (final opt in [('both', 'Both'), ('pickup', 'Pickup'), ('delivery', 'Delivery')])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(opt.$2, style: TextStyle(fontSize: 12,
                                  color: _delivery == opt.$1 ? Colors.white : const Color(0xFF64748B))),
                              selected: _delivery == opt.$1,
                              selectedColor: AppColors.primaryColor,
                              onSelected: (_) => setState(() => _delivery = opt.$1),
                            ),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add Medicine'),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
