import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/custom_text_input.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // for web
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phoneNumber;
      _uploadedImageUrl = user.profilePicture;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
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
            // drag handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you want to update your photo',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _photoOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF6366F1),
                    onTap: () async {
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
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _photoOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF0EA5E9),
                    onTap: () async {
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
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(File? file, {Uint8List? bytes}) async {
    try {
      setState(() => isLoading = true);
      final imageBytes = bytes ?? await file!.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${_encodeBase64(imageBytes)}';
      final response = await ApiService().put('/users/profile', {
        'profilePicture': base64Str,
      });
      if (response.statusCode == 200 && mounted) {
        setState(() => _uploadedImageUrl = base64Str);
        // Update auth provider so image persists across screens
        final updatedUser = app_user.User.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        ref.read(authProvider.notifier).setUser(updatedUser);
      }
    } catch (e) {
      debugPrint('Image upload error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _encodeBase64(List<int> bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = StringBuffer();
    for (var i = 0; i < bytes.length; i += 3) {
      final b0 = bytes[i];
      final b1 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      final b2 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result.write(chars[(b0 >> 2) & 0x3F]);
      result.write(chars[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      result.write(i + 1 < bytes.length ? chars[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      result.write(i + 2 < bytes.length ? chars[b2 & 0x3F] : '=');
    }
    return result.toString();
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final result = await _userService.updateProfile(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
      if (result['success']) {
        final user = app_user.User.fromJson(result['user']);
        ref.read(authProvider.notifier).setUser(user);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
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
      SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // ── Profile Picture with upload ──
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2), width: 3),
                        ),
                        child: ClipOval(
                          child: _selectedImageBytes != null
                              ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                              : _selectedImage != null && !kIsWeb
                                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                  : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty && !_uploadedImageUrl!.startsWith('data:'))
                                      ? Image.network(_uploadedImageUrl!, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _avatarFallback(user?.name))
                                      : _avatarFallback(user?.name),
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
                          child: isLoading
                              ? const SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Tap to change photo',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 32),

                // ── Form ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                        const SizedBox(height: 20),
                        CustomInputField(
                          hintText: 'Full Name',
                          leadingIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                          controller: nameController,
                          bgColor: const Color(0xFFF8FAFC),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          validator: (val) => (val == null || val.isEmpty) ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          hintText: 'Phone Number',
                          leadingIcon: const Icon(Icons.phone_outlined, color: Color(0xFF94A3B8)),
                          controller: phoneController,
                          bgColor: const Color(0xFFF8FAFC),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          validator: (val) => (val == null || val.isEmpty) ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomInputField(
                          hintText: user?.email ?? '',
                          leadingIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                          controller: TextEditingController(text: user?.email),
                          bgColor: const Color(0xFFF1F5F9),
                          borderRadius: 14,
                          borderColor: const Color(0xFFE2E8F0),
                          borderWidth: 1.5,
                          enabled: false,
                        ),
                        const SizedBox(height: 8),
                        const Text('Email cannot be changed',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: isLoading ? null : _handleUpdate,
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Update Profile',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (ctx) => LoginScreen()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.redAccent,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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

  Widget _avatarFallback(String? name) {
    return Center(
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : 'U',
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
      ),
    );
  }
}
