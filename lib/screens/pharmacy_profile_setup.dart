import 'package:flutter/material.dart';
import '../services/pharmacy_service.dart';
import 'pharmacist_dashboard.dart';
import 'tabs.dart';

class PharmacyProfileSetup extends StatefulWidget {
  const PharmacyProfileSetup({super.key});

  @override
  State<PharmacyProfileSetup> createState() => _PharmacyProfileSetupState();
}

class _PharmacyProfileSetupState extends State<PharmacyProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  final PharmacyService _pharmacyService = PharmacyService();

  bool _isLoading = true;
  bool _isSaving = false;

  final _ownerNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _openHoursFromController = TextEditingController();
  final _openHoursToController = TextEditingController();

  bool _deliveryAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _cnicController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _openHoursFromController.dispose();
    _openHoursToController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _pharmacyService.getPharmacyProfile();
      setState(() {
        _ownerNameController.text = profile['ownerName'] ?? '';
        _cnicController.text = profile['cnic'] ?? '';
        _licenseNumberController.text = profile['licenseNumber'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _cityController.text = profile['city'] ?? '';
        _openHoursFromController.text = profile['openHours']?['from'] ?? '';
        _openHoursToController.text = profile['openHours']?['to'] ?? '';
        _deliveryAvailable = profile['deliveryAvailable'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Unable to load data. Please try again.')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _pharmacyService.updatePharmacyProfile({
        'ownerName': _ownerNameController.text,
        'cnic': _cnicController.text,
        'licenseNumber': _licenseNumberController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'openHours': {
          'from': _openHoursFromController.text,
          'to': _openHoursToController.text,
        },
        'deliveryAvailable': _deliveryAvailable,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Navigate to dashboard after profile setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const TabsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pharmacy Profile Setup'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Basic Information', Icons.info_outline, [
                      _buildTextField(
                        controller: _ownerNameController,
                        label: 'Owner Name',
                        icon: Icons.person,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cnicController,
                        label: 'CNIC',
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _licenseNumberController,
                        label: 'License Number',
                        icon: Icons.verified_user,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Location', Icons.location_on, [
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Operating Hours', Icons.access_time, [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _openHoursFromController,
                              label: 'From (e.g., 09:00 AM)',
                              icon: Icons.schedule,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _openHoursToController,
                              label: 'To (e.g., 09:00 PM)',
                              icon: Icons.schedule,
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Services', Icons.local_shipping, [
                      SwitchListTile(
                        title: const Text('Delivery Available'),
                        subtitle: const Text('Offer home delivery service'),
                        value: _deliveryAvailable,
                        onChanged: (value) {
                          setState(() => _deliveryAvailable = value);
                        },
                        activeColor: const Color(0xFF00897B),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF00897B), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00897B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
