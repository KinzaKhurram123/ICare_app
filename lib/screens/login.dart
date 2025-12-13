import 'package:flutter/material.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/screens/forget_password.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Screen',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
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
            // Positioned(
            //   top: ScallingConfig.moderateScale(40),
            //   right: ScallingConfig.moderateScale(20),
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //     ),
            //     onPressed: () {},
            //     child: Text(
            //       "Skip",
            //       style: TextStyle(color: AppColors.primaryColor),
            //     ),
            //   ),
            // ),

            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScallingConfig.moderateScale(15),
                vertical: ScallingConfig.moderateScale(80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScallingConfig.moderateScale(30)),
                  CustomText(
                    text: isLogin ? "Go Ahead & Set Up" : "Go Ahead & Set Up",
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primaryColor,
                  ),
                  CustomText(
                    text: isLogin ? "Your Account" : "Your Account",
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 3),
                  CustomText(
                    maxLines: 2,
                    text: isLogin
                        ? "Sign In To Get The Best Doctor Consultation Experience"
                        : "Sign Up To Enjoy The Best Doctor Consultation Experience",
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
                width: double.infinity,
                height: Utils.windowHeight(context) * 0.67,
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScallingConfig.moderateScale(15),
                    vertical: ScallingConfig.moderateScale(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> ForgetPassword()));
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
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => TabsScreen()));
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
                                  _socialButton(
                                    ImagePaths.google_icon,
                                    "Google",
                                  ),
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
