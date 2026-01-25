import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key, this.isEdit=false});
  final bool isEdit;

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(
    backgroundColor: AppColors.bgColor,
    leading: CustomBackButton(),
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
ProfilePicker(onPickImage: (pickedImage)=> {

}),
                const SizedBox(height: 30),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        hintText: "Name",
                        leadingIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.lightGrey200,
                        ),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: nameController,
                      ),
                      CustomInputField(
                        hintText: "Email",
                        leadingIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.lightGrey200,
                        ),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: emailController,
                      ),
                      CustomInputField(
                        hintText: "Phone Number",
                        leadingIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.lightGrey200,
                        ),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: phoneController,
                      ),
                      CustomInputField(
                        hintText: "Type your bio here....",
                        leadingIcon: const Icon(
                          Icons.text_snippet_outlined,
                          color: AppColors.lightGrey200,
                        ),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: bioController,
                      ),
                      CustomInputField(
                        hintText: "Add Qualification",
                        leadingIcon: const Icon(
                          Icons.school_outlined,
                          color: AppColors.lightGrey200,
                        ),
                        bgColor: AppColors.bgColor,
                        borderRadius: 30,
                        borderColor: AppColors.lightGrey200,
                        controller: qualificationController,
                      ),
                      CustomInputField(
                        hintText: "Age",
                        leadingIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.lightGrey200,
                        ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _showSuccessModal(context);
                            }
                          },
                          child: const Text(
                            "Create Profile",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePicker extends StatefulWidget {
  const ProfilePicker({
    super.key,
    required this.onPickImage,
  });

  final void Function(File pickedImage) onPickImage;

  @override
  State<ProfilePicker> createState() => _ProfilePickerState();
}

class _ProfilePickerState extends State<ProfilePicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    final imageFile = File(pickedImage.path);

    setState(() {
      _selectedImage = imageFile;
    });

    widget.onPickImage(imageFile);
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: Utils.windowWidth(context) * 0.3,
          height: Utils.windowHeight(context) * 0.15,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(35),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              color: AppColors.primaryColor,
              width: Utils.windowWidth(context) * 0.26,
              height: Utils.windowHeight(context) * 0.1,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Center(
                          child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                        
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
            leadingIcon: SvgWrapper(
              width: ScallingConfig.scale(20),
              assetPath: ImagePaths.camera,
            ),
          ),
        ),
      ],
    );
  }
}


void _showSuccessModal(BuildContext ctx) {
  showDialog(
    context: ctx,
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                "Successful", 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ), 
              const SizedBox(height: 8),
              const Text(
                "You have complete your profile setup successfully.",
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
                    Navigator.pop(ctx);
                  },
                  // onPressed: () {
                    // Navigator.pop(context); // Close modal
                  //   Navigator.pop(context); // Go back to login screen
                  // },
                  child: const Text(
                    "Go Back",
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
