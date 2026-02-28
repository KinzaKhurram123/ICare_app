import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/reset_password.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCode extends StatefulWidget {
  const VerifyCode({super.key});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
@override
void dispose() {
  codeController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
   final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
   
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(isTablet: isTablet),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: Utils.windowWidth(context) * 0.5,
          height: Utils.windowHeight(context),
          child: Image.asset("assets/images/splash.jpg", fit: BoxFit.cover),
        ),
        Container(
         padding: EdgeInsets.symmetric(horizontal: ScallingConfig.moderateScale(30)),
          width: Utils.windowWidth(context) * 0.5,
          child: Column(

            children: [
               SizedBox(height: ScallingConfig.moderateScale(30)),
                CustomText(
                  text: "Verification Code",
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: ScallingConfig.scale(19)),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        enableActiveFill: false,
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

  CustomButton(
    width: double.infinity,
    height: ScallingConfig.scale(60),
    borderRadius: ScallingConfig.scale(30),
    label: "Confirm",
    onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ResetPassword()));
    },
  ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

            ],
          ),
        )
      ],
    );
  }
  Widget _buildMobileLayout({bool isTablet = false}) {
    return
      Stack(

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

          
          Container(
            width: Utils.windowWidth(context),
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(isTablet ? 60 : 100),
            ),
            child: Column(
              crossAxisAlignment: isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start ,
              
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
                  textAlign: isTablet ? TextAlign.center : TextAlign.start,
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
              height: isTablet ? Utils.windowHeight(context) * 0.6 : Utils.windowHeight(context) * 0.7,
              width: isTablet ? Utils.windowWidth(context) * 0.7 : double.infinity,
              decoration:  BoxDecoration(
              color:  isTablet ?  AppColors.bgColor.withAlpha(70) : AppColors.bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding:  EdgeInsets.symmetric(horizontal: isTablet ? ScallingConfig.scale(50) : ScallingConfig.scale(15), vertical: 30),
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
                          inactiveColor: isTablet ? AppColors.white :  Colors.grey.shade300,
                          activeColor: Colors.blue,
                          
                          selectedColor: Colors.blueAccent,
                          activeFillColor: Colors.red,
                        inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,

                        ),
                        cursorColor: Colors.blue,
                        enableActiveFill: false,
                        onChanged: (value) {
                          print("OTP: $value");
                        },
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child:  Text(
                            "Resend Code",
                            style: TextStyle(
                              color: isTablet ? AppColors.white : AppColors.themeBlack,
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
                          onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ResetPassword()));

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
      Positioned
          (
            top: ScallingConfig.scale(30),
            left: ScallingConfig.scale(isTablet ? 10 : -10),
            child: CustomBackButton()),
        ],
      );
  }
}
