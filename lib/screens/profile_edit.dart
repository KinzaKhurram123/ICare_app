import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final UserService _userService = UserService();
  bool isLoading = false;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // On web, camera is not supported — go straight to gallery
    if (kIsWeb) {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 600,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
      return;
    }

    // Mobile: offer gallery or camera
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                  maxWidth: 600,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() => _imageBytes = bytes);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 600,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() => _imageBytes = bytes);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await _userService.updateProfile(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        cnic: cnicController.text.trim().isEmpty ? null : cnicController.text.trim(),
        age: ageController.text.trim().isEmpty ? null : ageController.text.trim(),
        height: heightController.text.trim().isEmpty ? null : heightController.text.trim(),
        weight: weightController.text.trim().isEmpty ? null : weightController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
        profileImage: _imageBytes,
      );

      if (result['success']) {
        final userData = result['user'];
        final user = app_user.User.fromJson(userData);
        ref.read(authProvider.notifier).setUser(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final role = ref.read(authProvider).userRole ?? '';
    final isPatient = role == 'Patient';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Profile Picture with upload
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: _imageBytes != null
                              ? Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : user?.profilePicture != null && user!.profilePicture!.isNotEmpty
                              ? Image.network(
                                  user.profilePicture!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        user.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to upload photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomInputField(
                          hintText: 'Full Name',
                          leadingIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF94A3B8),
                          ),
                          controller: nameController,
                          bgColor: const Color(0xFFF8FAFC),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          hintText: 'Phone Number',
                          leadingIcon: const Icon(
                            Icons.phone_outlined,
                            color: Color(0xFF94A3B8),
                          ),
                          controller: phoneController,
                          bgColor: const Color(0xFFF8FAFC),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email (read-only)
                        CustomInputField(
                          hintText: user?.email ?? '',
                          leadingIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF94A3B8),
                          ),
                          controller: TextEditingController(text: user?.email),
                          bgColor: const Color(0xFFF1F5F9),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          enabled: false,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Email cannot be changed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        if (isPatient) ...[
                          const SizedBox(height: 16),
                          CustomInputField(
                            hintText: 'CNIC Number (e.g. 42101-1234567-1)',
                            leadingIcon: const Icon(
                              Icons.credit_card_outlined,
                              color: Color(0xFF94A3B8),
                            ),
                            controller: cnicController,
                            bgColor: const Color(0xFFF8FAFC),
                            borderRadius: 14,
                            borderColor: const Color(0xFFE2E8F0),
                            borderWidth: 1.5,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Health Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  hintText: 'Age',
                                  leadingIcon: const Icon(
                                    Icons.cake_outlined,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  controller: ageController,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomInputField(
                                  hintText: 'Height (cm)',
                                  leadingIcon: const Icon(
                                    Icons.height_rounded,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  controller: heightController,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomInputField(
                                  hintText: 'Weight (kg)',
                                  leadingIcon: const Icon(
                                    Icons.monitor_weight_outlined,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  controller: weightController,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            hintText: 'Address',
                            leadingIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF94A3B8),
                            ),
                            controller: addressController,
                            bgColor: const Color(0xFFF8FAFC),
                            borderRadius: 14,
                            borderColor: const Color(0xFFE2E8F0),
                            borderWidth: 1.5,
                          ),
                        ],
                        const SizedBox(height: 32),
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading ? null : _handleUpdate,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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
}
