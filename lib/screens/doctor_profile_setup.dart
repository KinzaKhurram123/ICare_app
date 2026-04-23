import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class DoctorProfileSetup extends ConsumerStatefulWidget {
  const DoctorProfileSetup({super.key});

  @override
  ConsumerState<DoctorProfileSetup> createState() => _DoctorProfileSetupState();
}

class _DoctorProfileSetupState extends ConsumerState<DoctorProfileSetup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Profile picture
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _uploadedImageUrl;

  // Basic info controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill basic info from auth provider
    final user = ref.read(authProvider).user;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phoneNumber;
      emailController.text = user.email;
      _uploadedImageUrl = user.profilePicture;
    }
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final result = await DoctorService().getMyProfile();
      if (result['success'] == true && mounted) {
        final doc = result['doctor'] as Map<String, dynamic>;
        setState(() {
          if ((doc['specialization'] as String?)?.isNotEmpty == true) {
            specializationController.text = doc['specialization'];
          }
          if (doc['degrees'] is List && (doc['degrees'] as List).isNotEmpty) {
            degreesController.text = (doc['degrees'] as List).join(', ');
          }
          if ((doc['experience'] as String?)?.isNotEmpty == true) {
            experienceController.text = doc['experience'];
          }
          if ((doc['licenseNumber'] as String?)?.isNotEmpty == true) {
            licenseController.text = doc['licenseNumber'];
          }
          if ((doc['pmdcNumber'] as String?)?.isNotEmpty == true) {
            pmdcController.text = doc['pmdcNumber'];
          }
          if ((doc['clinicName'] as String?)?.isNotEmpty == true) {
            clinicNameController.text = doc['clinicName'];
          }
          if ((doc['clinicAddress'] as String?)?.isNotEmpty == true) {
            clinicAddressController.text = doc['clinicAddress'];
          }
          if (doc['availability'] != null) {
            final avail = doc['availability'] as Map<String, dynamic>;
            startTimeController.text = avail['availableTime']?['start'] ?? '';
            endTimeController.text = avail['availableTime']?['end'] ?? '';
            if (avail['availableDays'] is List) {
              for (final day in (avail['availableDays'] as List)) {
                if (selectedDays.containsKey(day)) selectedDays[day] = true;
              }
            }
          }
        });
      }
    } catch (_) {}
  }

  // Controllers
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController degreesController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController pmdcController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  // Available days selection
  final Map<String, bool> selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    specializationController.dispose();
    degreesController.dispose();
    experienceController.dispose();
    licenseController.dispose();
    pmdcController.dispose();
    clinicNameController.dispose();
    clinicAddressController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Update Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _photoOption(Icons.photo_library_rounded, 'Gallery', const Color(0xFF6366F1), () async {
                  Navigator.pop(context);
                  final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 600);
                  if (picked != null) {
                    if (kIsWeb) {
                      final bytes = await picked.readAsBytes();
                      setState(() => _selectedImageBytes = bytes);
                      await _uploadImage(null, bytes: bytes);
                    } else {
                      setState(() => _selectedImage = File(picked.path));
                      await _uploadImage(File(picked.path));
                    }
                  }
                })),
                const SizedBox(width: 16),
                Expanded(child: _photoOption(Icons.camera_alt_rounded, 'Camera', const Color(0xFF0EA5E9), () async {
                  Navigator.pop(context);
                  final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 600);
                  if (picked != null) {
                    if (kIsWeb) {
                      final bytes = await picked.readAsBytes();
                      setState(() => _selectedImageBytes = bytes);
                      await _uploadImage(null, bytes: bytes);
                    } else {
                      setState(() => _selectedImage = File(picked.path));
                      await _uploadImage(File(picked.path));
                    }
                  }
                })),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)))),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              )),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 26)),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Future<void> _uploadImage(File? file, {Uint8List? bytes}) async {
    try {
      setState(() => _isLoading = true);
      final imageBytes = bytes ?? await file!.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final response = await ApiService().put('/users/profile', {'profilePicture': base64Str});
      if (response.statusCode == 200 && mounted) {
        setState(() => _uploadedImageUrl = base64Str);
        final updatedUser = app_user.User.fromJson(Map<String, dynamic>.from(response.data as Map));
        ref.read(authProvider.notifier).setUser(updatedUser);
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAvatarPicker() {
    Widget avatarChild;
    if (_selectedImageBytes != null) {
      avatarChild = Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (_selectedImage != null && !kIsWeb) {
      avatarChild = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      try {
        final base64Str = _uploadedImageUrl!.contains(',') ? _uploadedImageUrl!.split(',').last : _uploadedImageUrl!;
        avatarChild = Image.memory(base64Decode(base64Str), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarInitial());
      } catch (_) {
        avatarChild = _avatarInitial();
      }
    } else {
      avatarChild = _avatarInitial();
    }

    return Column(children: [
      GestureDetector(
        onTap: _pickImage,
        child: Stack(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 3),
            ),
            child: ClipOval(child: avatarChild),
          ),
          Positioned(bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)),
              child: _isLoading
                ? const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.camera_alt, color: Colors.white, size: 14),
            )),
        ]),
      ),
      const SizedBox(height: 6),
      const Text('Tap to change photo', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
    ]);
  }

  Widget _avatarInitial() {
    final name = nameController.text;
    return Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'D',
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
    ));
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final availableDays = selectedDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (availableDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one available day'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save basic info (name, phone) first
    if (nameController.text.trim().isNotEmpty) {
      await UserService().updateProfile(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
    }

    final degrees = degreesController.text
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();

    final result = await DoctorService().updateDoctorProfile(
      specialization: specializationController.text,
      degrees: degrees,
      experience: experienceController.text,
      licenseNumber: licenseController.text,
      pmdcNumber: pmdcController.text,
      clinicName: clinicNameController.text,
      clinicAddress: clinicAddressController.text,
      availableDays: availableDays,
      startTime: startTimeController.text,
      endTime: endTimeController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      _showSuccessModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update profile'),
        ),
      );
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Profile Updated",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your professional profile has been updated successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 900) {
      return _buildWebView();
    }
    return _buildMobileView();
  }

  Widget _buildMobileView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        leading: const CustomBackButton(color: AppColors.primaryColor),
        automaticallyImplyLeading: false,
        title: const Text(
          "Professional Profile",
          style: TextStyle(
            fontSize: 16.78,
            fontFamily: "Gilroy-Bold",
            fontWeight: FontWeight.w400,
            color: AppColors.primary500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildAvatarPicker()),
                const SizedBox(height: 24),
                _buildSectionTitle("Personal Information"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: nameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                  hint: "Your full name",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  hint: "Your phone number",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  hint: "Your email address",
                  enabled: false,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Professional Information"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: specializationController,
                  label: "Specialization",
                  icon: Icons.medical_services_outlined,
                  hint: "e.g., Cardiologist, Dermatologist",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: degreesController,
                  label: "Degrees (comma separated)",
                  icon: Icons.school_outlined,
                  hint: "e.g., MBBS, MD, PhD",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: experienceController,
                  label: "Years of Experience",
                  icon: Icons.work_outline,
                  hint: "e.g., 5 years",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: licenseController,
                  label: "License Number",
                  icon: Icons.badge_outlined,
                  hint: "Medical license number",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: pmdcController,
                  label: "PMDC Number",
                  icon: Icons.verified_user_outlined,
                  hint: "PMDC registration number",
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Clinic Information"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: clinicNameController,
                  label: "Clinic Name",
                  icon: Icons.local_hospital_outlined,
                  hint: "Your clinic or hospital name",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: clinicAddressController,
                  label: "Clinic Address",
                  icon: Icons.location_on_outlined,
                  hint: "Full address",
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Availability"),
                const SizedBox(height: 16),
                _buildDaysSelector(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        controller: startTimeController,
                        label: "Start Time",
                        hint: "09:00 AM",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        controller: endTimeController,
                        label: "End Time",
                        hint: "05:00 PM",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Row(
        children: [
          // Left Panel
          Container(
            width: 450,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryColor, Color(0xFF6366F1)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(color: Colors.white),
                  const Spacer(),
                  const Text(
                    "Complete Your\nProfessional Profile",
                    style: TextStyle(
                      fontSize: 38,
                      fontFamily: "Gilroy-Bold",
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Set up your professional details, clinic information, and availability to start accepting appointments from patients.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          // Right Panel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(80),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DOCTOR PROFILE",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Professional Details",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(child: _buildAvatarPicker()),
                        const SizedBox(height: 40),
                        const Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: nameController,
                                label: "Full Name",
                                icon: Icons.person_outline,
                                hint: "Your full name",
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                controller: phoneController,
                                label: "Phone Number",
                                icon: Icons.phone_outlined,
                                hint: "Your phone number",
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                hint: "Your email address",
                                enabled: false,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Professional Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: specializationController,
                                label: "Specialization",
                                icon: Icons.medical_services_outlined,
                                hint: "e.g., Cardiologist",
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                controller: experienceController,
                                label: "Years of Experience",
                                icon: Icons.work_outline,
                                hint: "e.g., 5 years",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: degreesController,
                                label: "Degrees (comma separated)",
                                icon: Icons.school_outlined,
                                hint: "e.g., MBBS, MD, PhD",
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                controller: licenseController,
                                label: "License Number",
                                icon: Icons.badge_outlined,
                                hint: "Medical license number",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: pmdcController,
                                label: "PMDC Number",
                                icon: Icons.verified_user_outlined,
                                hint: "PMDC registration number",
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Clinic Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: clinicNameController,
                          label: "Clinic Name",
                          icon: Icons.local_hospital_outlined,
                          hint: "Your clinic or hospital name",
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: clinicAddressController,
                          label: "Clinic Address",
                          icon: Icons.location_on_outlined,
                          hint: "Full address",
                          maxLines: 2,
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Availability Schedule",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDaysSelector(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeField(
                                controller: startTimeController,
                                label: "Start Time",
                                hint: "09:00 AM",
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTimeField(
                                controller: endTimeController,
                                label: "End Time",
                                hint: "05:00 PM",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _submitProfile,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Save Professional Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      fontFamily: "Gilroy-Bold",
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
          validator: enabled
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectTime(controller),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: const Icon(
              Icons.access_time,
              color: AppColors.primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedDays.keys.map((day) {
        final isSelected = selectedDays[day]!;
        return FilterChip(
          label: Text(day.substring(0, 3)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selectedDays[day] = selected;
            });
          },
          selectedColor: AppColors.primaryColor,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xFFE2E8F0),
            ),
          ),
        );
      }).toList(),
    );
  }
}
