import 'package:flutter/material.dart';
import '../services/laboratory_service.dart';
import 'laboratory_dashboard.dart';
import 'tabs.dart';
import '../widgets/back_button.dart';

class LabProfileSetup extends StatefulWidget {
  const LabProfileSetup({super.key});

  @override
  State<LabProfileSetup> createState() => _LabProfileSetupState();
}

class _LabProfileSetupState extends State<LabProfileSetup>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final LaboratoryService _labService = LaboratoryService();

  bool _isLoading = true;
  bool _isSaving = false;

  final _labNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _labEmailController = TextEditingController();
  final _labPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workingHoursFromController = TextEditingController();
  final _workingHoursToController = TextEditingController();

  bool _homeSampleAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Premium Theme Colors
  static const Color primaryColor = Color(0xFF0B2D6E);
  static const Color secondaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF0EA5E9);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _labNameController.dispose();
    _ownerNameController.dispose();
    _licenseNumberController.dispose();
    _labEmailController.dispose();
    _labPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _workingHoursFromController.dispose();
    _workingHoursToController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _labService.getProfile();
      setState(() {
        _labNameController.text = profile['labName'] ?? '';
        _ownerNameController.text = profile['ownerName'] ?? '';
        _licenseNumberController.text = profile['licenseNumber'] ?? '';
        _labEmailController.text = profile['labEmail'] ?? '';
        _labPhoneController.text = profile['labPhoneNumber'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _cityController.text = profile['city'] ?? '';
        _titleController.text = profile['title'] ?? '';
        _descriptionController.text = profile['description'] ?? '';
        _workingHoursFromController.text =
            profile['workingHours']?['from'] ?? '';
        _workingHoursToController.text = profile['workingHours']?['to'] ?? '';
        _homeSampleAvailable = profile['homeSampleAvailable'] ?? false;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to load data. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _labService.updateProfile({
        'labName': _labNameController.text,
        'ownerName': _ownerNameController.text,
        'licenseNumber': _licenseNumberController.text,
        'labEmail': _labEmailController.text,
        'labPhoneNumber': _labPhoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'workingHours': {
          'from': _workingHoursFromController.text,
          'to': _workingHoursToController.text,
        },
        'homeSampleAvailable': _homeSampleAvailable,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const TabsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Laboratory Profile',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 40 : 20),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1000 : double.infinity,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildSection(
                            'Basic Information',
                            Icons.business_rounded,
                            [
                              _buildTextField(
                                controller: _labNameController,
                                label: 'Laboratory Name',
                                icon: Icons.business_rounded,
                                hint: 'e.g., City Medical Laboratory',
                                validator: (v) => v?.isEmpty ?? true
                                    ? 'Laboratory name is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _ownerNameController,
                                label: 'Owner Name',
                                icon: Icons.person_rounded,
                                hint: 'e.g., Dr. Ahmed Khan',
                                validator: (v) => v?.isEmpty ?? true
                                    ? 'Owner name is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _licenseNumberController,
                                label: 'License Number',
                                icon: Icons.badge_rounded,
                                hint: 'e.g., LAB-2024-PKR-12345',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            'Contact Information',
                            Icons.contact_phone_rounded,
                            [
                              _buildTextField(
                                controller: _labEmailController,
                                label: 'Laboratory Email',
                                icon: Icons.email_rounded,
                                hint: 'info@yourlab.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _labPhoneController,
                                label: 'Laboratory Phone',
                                icon: Icons.phone_rounded,
                                hint: '+92-300-1234567',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            'Location Details',
                            Icons.location_on_rounded,
                            [
                              _buildTextField(
                                controller: _addressController,
                                label: 'Address',
                                icon: Icons.home_rounded,
                                hint: '123 Medical Plaza, Main Boulevard',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                icon: Icons.location_city_rounded,
                                hint: 'Lahore',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            'About Laboratory',
                            Icons.description_rounded,
                            [
                              _buildTextField(
                                controller: _titleController,
                                label: 'Title/Tagline',
                                icon: Icons.title_rounded,
                                hint: 'Your Trusted Healthcare Partner',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description',
                                icon: Icons.notes_rounded,
                                hint:
                                    'Tell patients about your laboratory, services, and expertise...',
                                maxLines: 4,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            'Working Hours',
                            Icons.access_time_rounded,
                            [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _workingHoursFromController,
                                      label: 'Opening Time',
                                      icon: Icons.wb_sunny_rounded,
                                      hint: '08:00 AM',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _workingHoursToController,
                                      label: 'Closing Time',
                                      icon: Icons.nightlight_round,
                                      hint: '10:00 PM',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildServicesSection(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.science_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laboratory Profile Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete your laboratory information to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Services Offered',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              setState(() => _homeSampleAvailable = !_homeSampleAvailable);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _homeSampleAvailable
                    ? primaryColor.withValues(alpha: 0.1)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _homeSampleAvailable
                      ? primaryColor
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _homeSampleAvailable
                          ? primaryColor
                          : const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Home Sample Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Offer sample collection at patient\'s home',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(
                              0xFF64748B,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _homeSampleAvailable
                          ? primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: _homeSampleAvailable
                            ? primaryColor
                            : const Color(0xFF64748B),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _homeSampleAvailable
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryColor, secondaryColor]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
