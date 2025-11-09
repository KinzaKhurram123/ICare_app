
import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:icare/widgets/svg_wrapper.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
 final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CustomBackButton(),
        title: CustomText(text: "Change password", fontFamily: "Gilroy-Bold", fontSize: 16,),
      ),
      body: SingleChildScrollView(
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: ScallingConfig.scale(20), vertical: ScallingConfig.verticalScale(20)),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomInputField(
                          maxLines: 1,
                  
                          hintText: "Password",
                          leadingIcon: SvgWrapper(assetPath: ImagePaths.key),
                          isPassword: true,
                          bgColor: AppColors.white,
                          borderRadius: 30,
                          borderColor: AppColors.veryLightGrey,
                          borderWidth: 2,
                          // validator: (val) {
                          //   if (val == null || val.isEmpty) {
                          //     return "Please enter your username";
                          //   }
                          //   return null;
                          // },
                        ), 
                  
                        CustomInputField(
                          maxLines: 1,
                          hintText: "Confirm Password",
                          leadingIcon:SvgWrapper(assetPath: ImagePaths.key),
                          isPassword: true,
                          bgColor: AppColors.white,
                          borderRadius: 30,
                          borderColor: AppColors.veryLightGrey,
                          borderWidth: 2,
                          // validator: (val) {
                          //   if (val == null || val.isEmpty) {
                          //     return "Please enter your username";
                          //   }
                          //   return null;
                          // },
                        ),
                        SizedBox(height: ScallingConfig.scale(10)),
                  
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
                    // print("object");
                    // Navigator.pop(ctx);
                    // log("message        logs");
                    Navigator.of(ctx).pop();
                  },
                  // onPressed: () {\en
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
