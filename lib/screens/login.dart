

import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/forget_password.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool rememberMe = false;
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    print("====> $isTablet  ${Utils.windowWidth(context)} ");

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isDesktop ?  _buildDesktopLayout() : _buildMobileLayout(isTablet: isTablet),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
    
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: Utils.windowWidth(context) * 0.5,
                height: Utils.windowHeight(context),
                child: Image.asset("assets/images/splash.jpg", fit: BoxFit.cover),
              ),
                      Container(
          color: AppColors.bgColor,
          width: Utils.windowWidth(context) * 0.5,
          height: Utils.windowHeight(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScallingConfig.scale(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      width:  Utils.windowWidth(context) * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: isLogin
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      color: !isLogin
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScallingConfig.scale(10)),
                CustomText(
                  text: isLogin ? "Welcome Back!" : "Go Ahead & Set Up Your Account",
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy-Bold",
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                       SizedBox(height: 25),

                    /// FORM FIELDS
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!isLogin)
                            CustomInputField(
                              hintText: "Username or Email",
                              leadingIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primary500,
                              ),
                              controller: usernameController,
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
                          SizedBox(height: 5),
                          if (isLogin)
                            CustomInputField(
                              hintText: "Username or Email",
                              leadingIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primary500,
                              ),
                              controller: usernameController,
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
                          SizedBox(height: 5),

                          CustomInputField(
                            hintText: "Enter Your Password",
                            leadingIcon: Icon(
                              Icons.key,
                              color: AppColors.primary500,
                            ),
                            controller: passwordController,
                            isPassword: true,
                            bgColor: AppColors.white,
                            borderRadius: 30,
                            borderColor: AppColors.veryLightGrey,
                            borderWidth: 2,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),

                          if (!isLogin) ...[
                            SizedBox(height: 5),
                            CustomInputField( 
                              controller: confirmPasswordController,
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
                                  return "Please confirm your password";
                                } else if (val !=
                                    passwordController.text.trim()) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                          ],

                          if (isLogin) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (val) {
                                        setState(() => rememberMe = val!);
                                      },
                                      activeColor: AppColors.primary500,
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: AppColors.lightGrey200,
                                        width: 2,
                                      ),
                                    ),
                                    CustomText(
                                      text: "Remember me",
                                      fontSize: 15,
                                      color: AppColors.lightGrey200,
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ForgetPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password",
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (isLogin) ...[
                            SizedBox(height: 10),
                          ] else ...[
                            SizedBox(height: 80),
                          ],
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => TabsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                isLogin ? "Sign In" : "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          if (isLogin) ...[
                            SizedBox(height: 25),
                            Text(
                              "Or Continue With",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialButton(
                                  ImagePaths.facebook_icon,
                                  "Facebook",
                                ),
                                SizedBox(width: 20),
                                _socialButton(ImagePaths.google_icon, "Google"),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
              ],
            ),
          ),         
        )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout({bool isTablet = false}) {
    return Container(
      width: Utils.windowWidth(context),
      height: Utils.windowHeight(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImagePaths.backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: Utils.windowWidth(context),
            height: isTablet ?  Utils.windowHeight(context) * 0.35 : double.infinity,
            // color: AppColors.themeRed,
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(isTablet ? 12: 80),
            ),
            child: Column(
              mainAxisAlignment: isTablet ? MainAxisAlignment.center : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ScallingConfig.moderateScale(isTablet ? 5 : 30)),
                CustomText(
                  text: "Go Ahead & Set Up Your Account",
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  textAlign: isTablet ?  TextAlign.center: TextAlign.start,                  // textAlign: TextAlign.center,
                  width: isTablet ? Utils.windowWidth(context)  :Utils.windowWidth(context) * 0.6,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                // CustomText(
                //   text: isLogin ? "Your Account" : "Your Account",
                //   fontWeight: FontWeight.bold,
                //   fontSize: 22,
                //   color: AppColors.primaryColor,
                // ),
                SizedBox(height: 3),
                CustomText(
                  maxLines: 2,
                  text: isLogin
                      ? "Sign In To Get The Best Doctor Consultation Experience"
                      : "Sign Up To Enjoy The Best Doctor Consultation Experience",
                  fontSize: 13,
                  textAlign: isTablet ?  TextAlign.center: TextAlign.start,
                  width: isTablet ? Utils.windowWidth(context) :  Utils.windowHeight(context) * 0.4,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.moderateScale(isTablet ? 50 :  15),
                  vertical: ScallingConfig.moderateScale( 22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isTablet ? Utils.windowWidth(context) * 0.4 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 17),
                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: isLogin
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? AppColors.primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      color: !isLogin
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    /// FORM FIELDS
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!isLogin)
                            CustomInputField(
                              hintText: "Username or Email",
                              leadingIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primary500,
                              ),
                              controller: usernameController,
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
                          SizedBox(height: 5),
                          if (isLogin)
                            CustomInputField(
                              hintText: "Username or Email",
                              leadingIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.primary500,
                              ),
                              controller: usernameController,
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
                          SizedBox(height: 5),

                          CustomInputField(
                            hintText: "Enter Your Password",
                            leadingIcon: Icon(
                              Icons.key,
                              color: AppColors.primary500,
                            ),
                            controller: passwordController,
                            isPassword: true,
                            bgColor: AppColors.white,
                            borderRadius: 30,
                            borderColor: AppColors.veryLightGrey,
                            borderWidth: 2,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),

                          if (!isLogin) ...[
                            SizedBox(height: 5),
                            CustomInputField( 
                              controller: confirmPasswordController,
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
                                  return "Please confirm your password";
                                } else if (val !=
                                    passwordController.text.trim()) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                          ],

                          if (isLogin) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (val) {
                                        setState(() => rememberMe = val!);
                                      },
                                      activeColor: AppColors.primary500,
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: isTablet ?  AppColors.white:  AppColors.lightGrey200,
                                        width: 2,
                                      ),
                                    ),
                                    CustomText(
                                      text: "Remember me",
                                      fontSize: isTablet ? 12 : 15,
                                      color: isTablet ?  AppColors.white:  AppColors.lightGrey200,
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ForgetPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password",
                                    style: TextStyle(
                                      color: isTablet ?  AppColors.white:  AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (isLogin) ...[
                            SizedBox(height: 10),
                          ] else ...[
                            SizedBox(height: 80),
                          ],
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => TabsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                isLogin ? "Sign In" : "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          if (isLogin) ...[
                            SizedBox(height: 25),
                            Text(
                              "Or Continue With",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _socialButton(
                                  ImagePaths.facebook_icon,
                                  "Facebook",
                                ),
                                SizedBox(width: 20),
                                _socialButton(ImagePaths.google_icon, "Google"),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Social Button Widget
  Widget _socialButton(String assetPath, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Image.asset(assetPath, width: 30, height: 30),
          SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}
