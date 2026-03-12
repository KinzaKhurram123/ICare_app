
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/forget_password.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/services/auth_service.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool rememberMe = false;
  bool isLogin = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    print("====> $isTablet  ${Utils.windowWidth(context)} ");

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isDesktop ?  _buildDesktopLayout() : _buildMobileLayout(isTablet: isTablet),
    );
  }

  Widget _buildDesktopLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Row(
        children: [
          // ══════════════════════════════════════════════════════════════
          // LEFT HERO PANEL — gradient + branding
          // ══════════════════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: SizedBox(
              height: screenHeight,
              child: Image.asset(
                "assets/images/splash.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════════════
          // RIGHT FORM PANEL
          // ══════════════════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFF8FAFD),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0036BC).withOpacity(0.06),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Login / Signup Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isLogin ? AppColors.primaryColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: isLogin
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor.withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: isLogin ? Colors.white : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          fontFamily: "Gilroy-Bold",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: !isLogin ? AppColors.primaryColor : Colors.transparent,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: !isLogin
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor.withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: !isLogin ? Colors.white : const Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          fontFamily: "Gilroy-Bold",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Welcome Text
                        Text(
                          isLogin ? "Welcome Back!" : "Create Your Account",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B2D6E),
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLogin
                              ? "Sign in to access your health dashboard"
                              : "Join iCare for a better healthcare experience",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                            fontFamily: "Gilroy-Medium",
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Username field (always shown)
                              CustomInputField(
                                hintText: isLogin ? "Username or Email" : "Full Name",
                                leadingIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 22,
                                ),
                                controller: usernameController,
                                bgColor: const Color(0xFFF8FAFC),
                                borderRadius: 14,
                                borderColor: const Color(0xFFE2E8F0),
                                borderWidth: 1.5,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Please enter your username";
                                  }
                                  return null;
                                },
                              ),
                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                CustomInputField(
                                  hintText: "Email Address",
                                  leadingIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 22,
                                  ),
                                  controller: emailController,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter your email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomInputField(
                                  hintText: "Phone Number",
                                  leadingIcon: const Icon(
                                    Icons.phone_outlined,
                                    color: Color(0xFF94A3B8),
                                    size: 22,
                                  ),
                                  controller: phoneController,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter your phone number";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 16),

                              CustomInputField(
                                hintText: "Password",
                                leadingIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 22,
                                ),
                                controller: passwordController,
                                isPassword: true,
                                bgColor: const Color(0xFFF8FAFC),
                                borderRadius: 14,
                                borderColor: const Color(0xFFE2E8F0),
                                borderWidth: 1.5,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  return null;
                                },
                              ),

                              if (!isLogin) ...[
                                const SizedBox(height: 16),
                                CustomInputField(
                                  controller: confirmPasswordController,
                                  hintText: "Confirm Password",
                                  leadingIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 22,
                                  ),
                                  isPassword: true,
                                  bgColor: const Color(0xFFF8FAFC),
                                  borderRadius: 14,
                                  borderColor: const Color(0xFFE2E8F0),
                                  borderWidth: 1.5,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please confirm your password";
                                    } else if (val != passwordController.text.trim()) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              if (isLogin) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: rememberMe,
                                            onChanged: (val) {
                                              setState(() => rememberMe = val!);
                                            },
                                            activeColor: AppColors.primaryColor,
                                            checkColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFCBD5E1),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Remember me",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                            fontFamily: "Gilroy-Medium",
                                          ),
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
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          fontFamily: "Gilroy-SemiBold",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Sign In / Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: isLoading ? null : _handleSubmit,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          isLogin ? "Sign In" : "Create Account",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Gilroy-Bold",
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (ctx) => SelectUserType()),
                                ),
                                child: const Text(
                                  "Switch Role / Testing Bypass",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              if (isLogin) ...[
                                const SizedBox(height: 32),
                                // Divider with text
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "Or continue with",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Gilroy-Medium",
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _webSocialButton(
                                        ImagePaths.google_icon,
                                        "Google",
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _webSocialButton(
                                        ImagePaths.facebook_icon,
                                        "Facebook",
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _webSocialButton(String assetPath, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: "Gilroy-SemiBold",
            ),
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
                          if (!isLogin) SizedBox(height: 5),
                          if (!isLogin)
                            CustomInputField(
                              hintText: "Email Address",
                              leadingIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primary500,
                              ),
                              controller: emailController,
                              bgColor: AppColors.white,
                              borderRadius: 30,
                              borderColor: AppColors.veryLightGrey,
                              borderWidth: 2,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter your email";
                                }
                                return null;
                              },
                            ),
                          if (!isLogin) SizedBox(height: 5),
                          if (!isLogin)
                            CustomInputField(
                              hintText: "Phone Number",
                              leadingIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.primary500,
                              ),
                              controller: phoneController,
                              bgColor: AppColors.white,
                              borderRadius: 30,
                              borderColor: AppColors.veryLightGrey,
                              borderWidth: 2,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter your phone number";
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
                            const SizedBox(height: 32),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (ctx) => SelectUserType()),
                              ),
                              child: const Text(
                                "Switch Role / Testing Bypass",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Gilroy-Bold",
                                ),
                              ),
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
                              onPressed: isLoading ? null : _handleSubmit,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isLogin ? "Sign In" : "Sign Up",
                                      style: const TextStyle(
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // Login
        final result = await _authService.login(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (result['success']) {
          // Fetch user profile after login
          final profileResult = await _userService.getUserProfile();
          
          if (profileResult['success'] && mounted) {
            // Store user data in provider
            final userData = profileResult['user'];
            final user = app_user.User.fromJson(userData);
            ref.read(authProvider.notifier).setUser(user);
            ref.read(authProvider.notifier).setUserToken(result['data']['token']);
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const TabsScreen()),
            );
          } else {
            _showError('Failed to load user profile');
          }
        } else {
          _showError(result['message']);
        }
      } else {
        // Sign Up - Get role from provider
        final selectedRole = ref.read(authProvider).userRole;
        
        if (selectedRole.isEmpty) {
          _showError('Please select your role first');
          setState(() => isLoading = false);
          return;
        }

        // Map frontend roles to backend roles
        String backendRole = _mapRoleToBackend(selectedRole);

        final result = await _authService.register(
          name: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: backendRole,
          phoneNumber: phoneController.text.trim(),
        );

        if (result['success']) {
          // Fetch user profile after registration
          final profileResult = await _userService.getUserProfile();
          
          if (profileResult['success'] && mounted) {
            final userData = profileResult['user'];
            final user = app_user.User.fromJson(userData);
            ref.read(authProvider.notifier).setUser(user);
            ref.read(authProvider.notifier).setUserToken(result['data']['token']);
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const TabsScreen()),
            );
          } else {
            _showError('Failed to load user profile');
          }
        } else {
          _showError(result['message']);
        }
      }
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _mapRoleToBackend(String frontendRole) {
    // Map frontend roles to backend enum values
    switch (frontendRole.toLowerCase()) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacy';
      case 'lab_technician':
        return 'Laboratory';
      case 'instructor':
        return 'Instructor';
      case 'student':
        return 'Student';
      default:
        return 'Patient';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
