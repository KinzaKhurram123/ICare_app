import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/verify_code.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
        final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
    
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(isTablet: isTablet),
    );
  }

Widget _buildDesktopLayout() {
  return (
    Row(
      children: [
  SizedBox(
                width: Utils.windowWidth(context) * 0.5,
                height: Utils.windowHeight(context),
                child: Image.asset("assets/images/splash.jpg", fit: BoxFit.cover),
              ),
              Container(
                width: Utils.windowWidth(context) * 0.5,
                height: Utils.windowHeight(context),
                child: SingleChildScrollView(
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      CustomText(
                        text: "Forget Password",
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        width: Utils.windowWidth(context) * 0.4,
                        color: AppColors.primaryColor,
                      ),                      SizedBox(height: 20),
                      CustomInputField(
                        width: Utils.windowWidth(context) * 0.4,
                        hintText: "Email or Phone Number",
                        leadingIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.primary500,
                        ),
                        controller: emailController,
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
                      const SizedBox(height: 50),
                      CustomButton(
                        label: "Send",
                        width: Utils.windowWidth(context) * 0.4,
                        height: 60,
                        borderRadius: ScallingConfig.scale(30),
                          onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(builder:(ctx) => VerifyCode()));

                          },
                     ),
                    ],
                  ),
                ),
              )
                // SizedBox(height: 20),
              
                
            
      ],
      ));
}

Widget _buildMobileLayout({bool isTablet = false}) {
  return Stack(
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
            height: isTablet ?  Utils.windowHeight(context) * 0.35 : double.infinity,
 
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(isTablet ?  20 : 100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ScallingConfig.moderateScale(30)),
                CustomText(
                  text: "Forget Password",
                  fontWeight: FontWeight.w900,
                  textAlign: TextAlign.center,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 3),
                CustomText(
                  maxLines: 2,
                                    textAlign: TextAlign.center,
                  text:
                      "Please enter your email or phone number to reset password",
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
              width: isTablet ? Utils.windowWidth(context) * 0.7 : double.infinity,
              height: Utils.windowHeight(context) * 0.67,
              decoration: BoxDecoration(
                color: isTablet ?  AppColors.bgColor.withAlpha(70) : AppColors.bgColor,
                // color: AppColors.grayColor.withAlpha(60),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding:  EdgeInsets.symmetric(horizontal: isTablet ? 50 : 15, vertical: 30),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomInputField(
                        hintText: "Email or Phone Number",
                        leadingIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.primary500,
                        ),
                        controller: emailController,
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

                      const SizedBox(height: 50),

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
               Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => VerifyCode()));

                          },
                          child: Text(
                            "Send",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
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
         Positioned(

          top:ScallingConfig.scale(isTablet ? 20 : 40),
          child: CustomBackButton()
         )
        ],
      );
}
}
