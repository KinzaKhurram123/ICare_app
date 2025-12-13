import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Uncomment if using Firebase
// import 'your_app/constants/app_colors.dart'; // Optional if you have color constants

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: Utils.windowWidth(context),
            height: Utils.windowHeight(context),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImagePaths.backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
                Positioned
          
          (
            top: 30,
            left: -10,
            child: CustomBackButton()),
          Positioned(
            top: 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScallingConfig.moderateScale(30)),
                CustomText(
                  text: "Reset Password",
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 3),
                CustomText(
                  maxLines: 2,
                  text:
                      "Forgot Password To Enjoy The Best Doctor Consultation Experience",
                  fontSize: 13,
                  width: Utils.windowHeight(context) * 0.4,
                  color: AppColors.themeBlack,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.7,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        hintText: "Password",
                        leadingIcon: Icon(
                          Icons.key,
                          color: AppColors.primary500,
                        ),
                        isPassword: true,
                        bgColor: AppColors.white,
                        borderRadius: 30,
                        borderColor: AppColors.veryLightGrey,
                        borderWidth: 2,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your username";
                          }
                          return null;
                        },
                      ),

                      CustomInputField(
                        hintText: "Confirm Password",
                        leadingIcon: Icon(
                          Icons.key,
                          color: AppColors.primary500,
                        ),
                        isPassword: true,
                        bgColor: AppColors.white,
                        borderRadius: 30,
                        borderColor: AppColors.veryLightGrey,
                        borderWidth: 2,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your username";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 70),

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
                            // if (_formKey.currentState!.validate()) {
                            //   _showSuccessModal(context);
                            // }
                              _showSuccessModal(context);
                          },
                          child: Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
}

void _showSuccessModal(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
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
                "Password Changed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You've successfully changed your password",
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
                    // Navigator.pop(ctx);
                    // // Go back to login screen
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => LoginScreen()));

                  },
                  // onPressed: () {
                  //   Navigator.pop(context); // Close modal
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
