import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCode extends StatefulWidget {
  const VerifyCode({super.key});

  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController codeController = TextEditingController();
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
                  text: "Verification Code",
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
                      PinCodeTextField(
                        appContext: context,
                        length: 5,
                        controller: codeController,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.circle,
                          borderRadius: BorderRadius.circular(50),
                          fieldHeight: 60,
                          fieldWidth: 60,
                          inactiveColor: Colors.grey.shade300,
                          activeColor: Colors.blue,
                          selectedColor: Colors.blueAccent,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                        ),
                        cursorColor: Colors.blue,
                        enableActiveFill: true,
                        onChanged: (value) {
                          print("OTP: $value");
                        },
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Resend Code",
                            style: TextStyle(
                              color: AppColors.themeBlack,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                          onPressed: () {},
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
