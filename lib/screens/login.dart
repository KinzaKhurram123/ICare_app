import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_size_matters/flutter_size_matters.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/forget_password.dart';
import 'package:icare/screens/select_user_type.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/lab_profile_setup.dart';
import 'package:icare/screens/pharmacy_profile_setup.dart';
import 'package:icare/screens/student_profile_setup.dart';
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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController credentialsController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool rememberMe = false;
  bool isLogin = true;
  bool isLoading = false;
  String selectedSignupRole = 'Patient';

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _logoController.forward();
    _checkExistingRole();
  }

  @override
  void dispose() {
    _logoController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    locationController.dispose();
    orgNameController.dispose();
    credentialsController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingRole() async {
    final authState = ref.read(authProvider);
    final existingRole = authState.userRole;

    // If user has a role saved, skip to login directly
    if (existingRole != null && existingRole.isNotEmpty) {
      setState(() {
        isLogin = true; // Force login mode
      });
    }
  }

  List<Widget> _buildDynamicFields({bool isMobile = false}) {
    if (isLogin) return [];

    List<Widget> fields = [];

    Widget buildField(
      String hintText,
      IconData icon,
      TextEditingController controller,
    ) {
      return Padding(
        padding: EdgeInsets.only(top: isMobile ? 5.0 : 16.0),
        child: CustomInputField(
          hintText: hintText,
          leadingIcon: Icon(
            icon,
            color: isMobile ? AppColors.primary500 : const Color(0xFF94A3B8),
            size: 22,
          ),
          controller: controller,
          bgColor: isMobile ? AppColors.white : const Color(0xFFF8FAFC),
          borderRadius: isMobile ? 30 : 14,
          borderColor: isMobile
              ? AppColors.veryLightGrey
              : const Color(0xFFE2E8F0),
          borderWidth: isMobile ? 2 : 1.5,
          validator: (val) {
            if (val == null || val.isEmpty) return "Required";
            return null;
          },
        ),
      );
    }

    switch (selectedSignupRole) {
      case 'Doctor':
        fields.add(
          buildField(
            isMobile ? "License No." : "Medical License Number",
            Icons.badge_outlined,
            licenseController,
          ),
        );
        fields.add(
          buildField(
            "Credentials (e.g. MBBS, MD)",
            Icons.school_outlined,
            credentialsController,
          ),
        );
        fields.add(
          buildField(
            "City / Location",
            Icons.location_on_outlined,
            locationController,
          ),
        );
        break;
      case 'Pharmacy':
        fields.add(
          buildField(
            "Pharmacy / Organization Name",
            Icons.local_pharmacy_outlined,
            orgNameController,
          ),
        );
        fields.add(
          buildField("License Number", Icons.badge_outlined, licenseController),
        );
        fields.add(
          buildField(
            "City / Location",
            Icons.location_on_outlined,
            locationController,
          ),
        );
        break;
      case 'Laboratory':
        fields.add(
          buildField(
            "Lab / Organization Name",
            Icons.biotech_outlined,
            orgNameController,
          ),
        );
        fields.add(
          buildField("License Number", Icons.badge_outlined, licenseController),
        );
        fields.add(
          buildField(
            "City / Location",
            Icons.location_on_outlined,
            locationController,
          ),
        );
        break;
      case 'Instructor':
        fields.add(
          buildField(
            "Credentials / Qualifications",
            Icons.school_outlined,
            credentialsController,
          ),
        );
        fields.add(
          buildField(
            "Organization / Institution",
            Icons.business_outlined,
            orgNameController,
          ),
        );
        break;
      case 'Student':
        fields.add(
          buildField(
            "Institution / University",
            Icons.school_outlined,
            orgNameController,
          ),
        );
        break;
      // Patient: no extra fields needed
    }

    return fields;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isDesktop
          ? _buildDesktopLayout()
          : _buildMobileLayout(isTablet: isTablet),
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
          // LEFT HERO PANEL — healthcare branding + trust indicators
          // ══════════════════════════════════════════════════════════════
          Expanded(
            flex: 5,
            child: Container(
              height: screenHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF001E6C), Color(0xFF0036BC), Color(0xFF035BE5)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -80, left: -80,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100, right: -50,
                    child: Container(
                      width: 350, height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 90, height: 90,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                            ),
                            child: Image.asset(ImagePaths.logo, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            "iCare Virtual Hospital",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your Virtual Healthcare Platform",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Secure consultations, prescriptions\n& health records",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 44),
                          _buildHeroTrust(Icons.shield_rounded, "Data Protected & Secure"),
                          const SizedBox(height: 14),
                          _buildHeroTrust(Icons.verified_user_rounded, "Verified Doctors Only"),
                          const SizedBox(height: 14),
                          _buildHeroTrust(Icons.medical_services_rounded, "Complete Virtual Hospital"),
                          const SizedBox(height: 14),
                          _buildHeroTrust(Icons.people_rounded, "Trusted by Patients Nationwide"),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 48,
                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLogin
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: isLogin
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.3),
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
                                          color: isLogin
                                              ? Colors.white
                                              : const Color(0xFF64748B),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isLogin
                                          ? AppColors.primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: !isLogin
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.3),
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
                                          color: !isLogin
                                              ? Colors.white
                                              : const Color(0xFF64748B),
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
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0B2D6E),
                            fontFamily: "Gilroy-Bold",
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLogin
                              ? "Access your health dashboard securely"
                              : "Join iCare for a better healthcare experience",
                          style: TextStyle(
                            fontSize: 15,
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
                                hintText: isLogin
                                    ? "Username or Email"
                                    : "Full Name",
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
                                  if (!isLogin && val.length < 6) {
                                    return "Password must be at least 6 characters";
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
                                    } else if (val !=
                                        passwordController.text.trim()) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              if (isLogin) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
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
                                          isLogin
                                              ? "Sign In"
                                              : "Create Account",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Gilroy-Bold",
                                          ),
                                        ),
                                ),
                              ),
                              if (isLogin) ...[
                                const SizedBox(height: 32),
                                // Divider with text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
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
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                        thickness: 1,
                                      ),
                                    ),
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
            height: isTablet
                ? Utils.windowHeight(context) * 0.35
                : double.infinity,
            // color: AppColors.themeRed,
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(isTablet ? 12 : 80),
            ),
            child: Column(
              mainAxisAlignment: isTablet
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ScallingConfig.moderateScale(isTablet ? 5 : 30),
                ),
                CustomText(
                  text: "Go Ahead & Set Up Your Account",
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  textAlign: isTablet
                      ? TextAlign.center
                      : TextAlign.start, // textAlign: TextAlign.center,
                  width: isTablet
                      ? Utils.windowWidth(context)
                      : Utils.windowWidth(context) * 0.6,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 3),
                CustomText(
                  text: isLogin
                      ? "Sign In To Get The Best Doctor Consultation Experience"
                      : "Sign Up To Enjoy The Best Doctor Consultation Experience",
                  fontSize: 13,
                  textAlign: isTablet ? TextAlign.center : TextAlign.start,
                  width: isTablet
                      ? Utils.windowWidth(context)
                      : Utils.windowHeight(context) * 0.4,
                  color: AppColors.themeBlack,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: isTablet
                  ? Utils.windowWidth(context) * 0.7
                  : double.infinity,
              height: Utils.windowHeight(context) * 0.67,
              decoration: BoxDecoration(
                color: isTablet
                    ? AppColors.bgColor.withAlpha(70)
                    : AppColors.bgColor,
                // color: AppColors.grayColor.withAlpha(60),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScallingConfig.moderateScale(isTablet ? 50 : 15),
                  vertical: ScallingConfig.moderateScale(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: isTablet
                          ? Utils.windowWidth(context) * 0.4
                          : double.infinity,
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
                              if (!isLogin && val.length < 6) {
                                return "Password must be at least 6 characters";
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
                                        color: isTablet
                                            ? AppColors.white
                                            : AppColors.lightGrey200,
                                        width: 2,
                                      ),
                                    ),
                                    CustomText(
                                      text: "Remember me",
                                      fontSize: isTablet ? 12 : 15,
                                      color: isTablet
                                          ? AppColors.white
                                          : AppColors.lightGrey200,
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
                                      color: isTablet
                                          ? AppColors.white
                                          : AppColors.primaryColor,
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
                          if (isLogin) _buildMobileSocialRow(),
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

  Widget _buildHeroTrust(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSocialRow() {
    return Column(
      children: [
        const SizedBox(height: 25),
        const Text("Or Continue With", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(ImagePaths.facebook_icon, "Facebook"),
            const SizedBox(width: 20),
            _socialButton(ImagePaths.google_icon, "Google"),
          ],
        ),
      ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String assetPath, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Image.asset(assetPath, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTrustRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Gilroy-Medium",
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: "Gilroy-Medium",
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        print("🔐 Starting login process...");

        // Login
        final result = await _authService.login(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (result['success']) {
          print("✅ Login successful, token saved");
          print("🔍 Fetching user profile...");

          // Get the token from the login result
          final token = result['data']['token'];
          print("🔑 Token from login: ${token.substring(0, 20)}...");

          // Fetch user profile with the token directly (don't rely on storage yet)
          final profileResult = await _userService.getUserProfile(token: token);

          print("📥 Profile result: ${profileResult['success']}");

          if (profileResult['success'] && mounted) {
            print("✅ Profile fetched successfully");

            // Store user data in provider
            final userData = profileResult['user'];
            print("📋 User data: $userData");

            final user = app_user.User.fromJson(userData);
            print(
              "👤 User object created: ${user.name}, ${user.email}, ${user.role}",
            );

            ref.read(authProvider.notifier).setUser(user);
            print("✅ User set in provider");

            ref
                .read(authProvider.notifier)
                .setUserToken(result['data']['token']);
            print("✅ Token set in provider");

            // Verify the role is set
            final currentRole = ref.read(authProvider).userRole;
            print("🔍 Current role in provider: '$currentRole'");

            print(
              "✅ Logged in as: ${user.name} (${user.email}) - Role: ${user.role}",
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const TabsScreen()),
            );
          } else {
            print("❌ Failed to fetch profile: ${profileResult['message']}");
            _showError(
              'Failed to load user profile: ${profileResult['message']}',
            );
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
          // licenseNumber: licenseController.text.trim(),
          // location: locationController.text.trim(),
          // organizationName: orgNameController.text.trim(),
          // credentials: credentialsController.text.trim(),
        );
        if (result['success']) {
          // Set token in provider first
          final token = result['data']['token'];
          ref.read(authProvider.notifier).setUserToken(token);

          // Fetch user profile after registration, passing token directly
          final profileResult = await _userService.getUserProfile(token: token);

          if (profileResult['success'] && mounted) {
            final userData = profileResult['user'];
            final user = app_user.User.fromJson(userData);
            ref.read(authProvider.notifier).setUser(user);

            // Redirect based on user role
            if (user.role == 'Laboratory') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const LabProfileSetup()),
              );
            } else if (user.role == 'Pharmacy') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => const PharmacyProfileSetup(),
                ),
              );
            } else if (user.role == 'Student') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => const StudentProfileSetup(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const TabsScreen()),
              );
            }
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

  void _showApprovalDialog(String role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Application Submitted"),
        content: Text(
          "Your application for the role of $role has been submitted for review. You'll be able to log in once approved.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => isLogin = true);
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  String _mapRoleToBackend(String frontendRole) {
    switch (frontendRole.toLowerCase()) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Doctor';
      case 'pharmacy':
        return 'Pharmacy';
      case 'laboratory':
        return 'Laboratory';
      case 'instructor':
        return 'Instructor';
      case 'student':
        return 'Student';
      default:
        return 'Patient';
    }
  }

  void _showError(dynamic error) {
    if (!mounted) return;
    Utils.showErrorSnackBar(context, error);
  }
}
