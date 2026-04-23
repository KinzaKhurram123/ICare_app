import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfile extends ConsumerStatefulWidget {
  const CreateProfile({super.key, this.isEdit = false});
  final bool isEdit;

  @override
  ConsumerState<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends ConsumerState<CreateProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillFromCache();
    _loadFromBackend();
  }

  void _prefillFromCache() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phoneNumber;
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      final result = await UserService().getUserProfile();
      if (result['success'] == true && mounted) {
        final u = result['user'];
        setState(() {
          nameController.text = u['name'] ?? nameController.text;
          emailController.text = u['email'] ?? emailController.text;
          phoneController.text = u['phoneNumber'] ?? phoneController.text;
          bioController.text = u['bio'] ?? '';
          ageController.text = u['age'] ?? '';
          qualificationController.text = u['qualification'] ?? '';
          _isFetching = false;
        });
      } else {
        if (mounted) setState(() => _isFetching = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put('/users/profile', {
        'name': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'bio': bioController.text.trim(),
        'age': ageController.text.trim(),
        'qualification': qualificationController.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          // Return the updated data directly — no modal, no extra API call needed
          final updated = response.data is Map ? Map<String, dynamic>.from(response.data) : <String, dynamic>{};
          Navigator.of(context).pop(updated);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    qualificationController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (MediaQuery.of(context).size.width > 900) {
      return _WebCreateProfile(
        isEdit: widget.isEdit,
        formKey: _formKey,
        nameController: nameController,
        emailController: emailController,
        phoneController: phoneController,
        bioController: bioController,
        qualificationController: qualificationController,
        ageController: ageController,
        isLoading: _isLoading,
        onSave: _save,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        leading: CustomBackButton(color: AppColors.primaryColor),
        automaticallyImplyLeading: false,
        title: CustomText(
          text: widget.isEdit ? "Edit Profile" : "Create Profile",
          fontSize: 16.78,
          fontFamily: "Gilroy-Bold",
          fontWeight: FontWeight.w400,
          letterSpacing: -0.31,
          lineHeight: 1.0,
          color: AppColors.primary500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(20),
              vertical: ScallingConfig.moderateScale(20),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ProfilePicker(onPickImage: (pickedImage) => {}),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        hintText: "Name",
                        leadingIcon: const Icon(Icons.person_outline, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: nameController,
                      ),
                      CustomInputField(
                        hintText: "Email",
                        leadingIcon: const Icon(Icons.email_outlined, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: emailController,
                        enabled: false,
                      ),
                      CustomInputField(
                        hintText: "Phone Number",
                        leadingIcon: const Icon(Icons.phone_outlined, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: phoneController,
                      ),
                      CustomInputField(
                        hintText: "Type your bio here....",
                        leadingIcon: const Icon(Icons.text_snippet_outlined, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: bioController,
                      ),
                      CustomInputField(
                        hintText: "Add Qualification",
                        leadingIcon: const Icon(Icons.school_outlined, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: qualificationController,
                      ),
                      CustomInputField(
                        hintText: "Age",
                        leadingIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.lightGrey200),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: ageController,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _isLoading ? null : _save,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.isEdit ? "Update Profile" : "Create Profile",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
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

// ─── Web layout ───────────────────────────────────────────────────────────────
class _WebCreateProfile extends StatelessWidget {
  final bool isEdit;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final TextEditingController qualificationController;
  final TextEditingController ageController;
  final bool isLoading;
  final VoidCallback onSave;

  const _WebCreateProfile({
    required this.isEdit,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
    required this.qualificationController,
    required this.ageController,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Row(
        children: [
          Container(
            width: 450,
            color: AppColors.primaryColor,
            child: Stack(
              children: [
                Positioned(
                  top: -100, left: -100,
                  child: Container(width: 300, height: 300,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle)),
                ),
                Positioned(
                  bottom: -50, right: -50,
                  child: Container(width: 250, height: 250,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle)),
                ),
                Padding(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomBackButton(color: Colors.white),
                      const Spacer(),
                      CustomText(
                        text: isEdit ? "Update Your\nProfile" : "Complete Your\nProfessional Identity",
                        fontSize: 38,
                        fontFamily: "Gilroy-Bold",
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Your profile is your digital identity in the iCare platform.",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18, height: 1.6),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(80),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEdit ? "Update Your Info" : "Profile Setup",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryColor, letterSpacing: 2),
                                ),
                                const SizedBox(height: 8),
                                const Text("Personal Details",
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), fontFamily: "Gilroy-Bold")),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          ProfilePicker(onPickImage: (f) {}),
                        ],
                      ),
                      const SizedBox(height: 60),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Row(children: [
                              Expanded(child: _buildInput(label: "Full Name", controller: nameController, icon: Icons.person_outline_rounded, hint: "Enter your name")),
                              const SizedBox(width: 32),
                              Expanded(child: _buildInput(label: "Email", controller: emailController, icon: Icons.alternate_email_rounded, hint: "email@example.com", enabled: false)),
                            ]),
                            const SizedBox(height: 32),
                            Row(children: [
                              Expanded(child: _buildInput(label: "Phone Number", controller: phoneController, icon: Icons.phone_android_rounded, hint: "+1 (555) 000-0000")),
                              const SizedBox(width: 32),
                              Expanded(child: _buildInput(label: "Age", controller: ageController, icon: Icons.calendar_today_rounded, hint: "e.g. 28")),
                            ]),
                            const SizedBox(height: 32),
                            _buildInput(label: "Bio & Description", controller: bioController, icon: Icons.description_outlined, hint: "Tell us about yourself...", maxLines: 4),
                            const SizedBox(height: 32),
                            _buildInput(label: "Qualifications", controller: qualificationController, icon: Icons.school_outlined, hint: "e.g. MBBS, BSc Nursing"),
                            const SizedBox(height: 60),
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: isLoading ? null : onSave,
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        isEdit ? "Update Changes" : "Create My Profile",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: "Gilroy-Bold"),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }
}

// ─── Profile image picker ─────────────────────────────────────────────────────
class ProfilePicker extends StatefulWidget {
  const ProfilePicker({super.key, required this.onPickImage});
  final void Function(File pickedImage) onPickImage;

  @override
  State<ProfilePicker> createState() => _ProfilePickerState();
}

class _ProfilePickerState extends State<ProfilePicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 600);
    if (pickedImage == null) return;
    final imageFile = File(pickedImage.path);
    setState(() => _selectedImage = imageFile);
    widget.onPickImage(imageFile);
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final double size = isDesktop ? 120 : Utils.windowWidth(context) * 0.3;
    final double height = isDesktop ? 120 : Utils.windowHeight(context) * 0.15;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size, height: height,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(border: Border.all(width: 2, color: AppColors.primaryColor), borderRadius: BorderRadius.circular(35)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              color: AppColors.primaryColor,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                  : const Center(child: Icon(Icons.person_outline, color: Colors.white, size: 45)),
            ),
          ),
        ),
        Positioned(
          right: ScallingConfig.scale(-5),
          bottom: ScallingConfig.scale(-5),
          child: CustomButton(
            onPressed: _showImageSourcePicker,
            padding: EdgeInsets.zero,
            width: ScallingConfig.scale(30),
            height: ScallingConfig.scale(25),
            borderRadius: 10,
            bgColor: AppColors.secondaryColor,
            leadingIcon: SvgWrapper(width: ScallingConfig.scale(20), assetPath: ImagePaths.camera),
          ),
        ),
      ],
    );
  }
}

