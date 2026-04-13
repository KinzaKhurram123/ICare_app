import 'dart:ui';
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
import 'package:icare/services/biometric_service.dart';
import 'package:icare/services/google_auth_service.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/widgets/custom_text_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool initialSignup;
  final String initialRole;
  final bool hideSignup;
  const LoginScreen({
    super.key,
    this.initialSignup = false,
    this.initialRole = 'Patient',
    this.hideSignup = false,
  });
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
  final BiometricService _biometricService = BiometricService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool rememberMe = false;
  bool isLogin = true;
  bool isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String selectedSignupRole = 'Patient';

  @override
  void initState() {
    super.initState();
    // Apply initial signup mode and role if provided
    if (widget.initialSignup) {
      isLogin = false;
      selectedSignupRole = widget.initialRole;
    }
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 3.0, end: 1.0).animate(
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
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final available = await _biometricService.isAvailable();
    final enabled = await _biometricService.isEnabled();
    if (mounted) setState(() { _biometricAvailable = available; _biometricEnabled = enabled; });
    // Auto-prompt biometric if enabled and user has a saved token
    if (available && enabled) {
      final token = await SharedPref().getToken();
      if (token != null && token.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 600));
        _triggerBiometricLogin();
      }
    }
  }

  Future<void> _triggerBiometricLogin() async {
    final label = await _biometricService.getBiometricLabel();
    final success = await _biometricService.authenticate(
      reason: 'Use $label to sign in to iCare',
    );
    if (!mounted) return;
    if (!success) {
      // User cancelled — just let them type manually, no error needed
      return;
    }
    // Token already stored — just load profile and navigate
    final token = await SharedPref().getToken();
    if (token == null || token.isEmpty) {
      // Token expired — ask user to login with password
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Session expired. Please login with your password.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => isLoading = true);
    ref.read(authProvider.notifier).setUserToken(token);
    final profileResult = await _userService.getUserProfile(token: token);
    if (profileResult['success'] && mounted) {
      final user = app_user.User.fromJson(profileResult['user']);
      ref.read(authProvider.notifier).setUser(user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TabsScreen()),
      );
    } else {
      if (mounted) setState(() => isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not load profile. Please login with password.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _offerBiometricEnrollment() async {
    if (!_biometricAvailable || _biometricEnabled) return;
    final label = await _biometricService.getBiometricLabel();
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.fingerprint_rounded, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Text('Enable $label Login')),
        ]),
        content: Text('Sign in faster next time using $label instead of your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _biometricService.enable();
              if (mounted) setState(() => _biometricEnabled = true);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
            child: Text('Enable $label'),
          ),
        ],
      ),
    );
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
    // Don't override if we're coming from Sign Up / Work With Us flow
    if (widget.initialSignup) return;

    final authState = ref.read(authProvider);
    final existingRole = authState.userRole;

    // If user has a role saved, keep login mode
    if (existingRole != null && existingRole.isNotEmpty && mounted) {
      // Don't change isLogin here — let the user decide
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
        fields.add(buildField(
          isMobile ? "License No." : "Medical License Number",
          Icons.badge_outlined,
          licenseController,
        ));
        fields.add(buildField(
          "Credentials (e.g. MBBS, MD)",
          Icons.school_outlined,
          credentialsController,
        ));
        fields.add(buildField(
          "City / Location",
          Icons.location_on_outlined,
          locationController,
        ));
        break;
      case 'Pharmacy':
        fields.add(buildField(
          "Pharmacy / Organization Name",
          Icons.local_pharmacy_outlined,
          orgNameController,
        ));
        fields.add(buildField(
          "License Number",
          Icons.badge_outlined,
          licenseController,
        ));
        fields.add(buildField(
          "City / Location",
          Icons.location_on_outlined,
          locationController,
        ));
        break;
      case 'Laboratory':
        fields.add(buildField(
          "Lab / Organization Name",
          Icons.biotech_outlined,
          orgNameController,
        ));
        fields.add(buildField(
          "License Number",
          Icons.badge_outlined,
          licenseController,
        ));
        fields.add(buildField(
          "City / Location",
          Icons.location_on_outlined,
          locationController,
        ));
        break;
      case 'Instructor':
        fields.add(buildField(
          "Credentials / Qualifications",
          Icons.school_outlined,
          credentialsController,
        ));
        fields.add(buildField(
          "Organization / Institution",
          Icons.business_outlined,
          orgNameController,
        ));
        break;
      case 'Student':
        fields.add(buildField(
          "Institution / University",
          Icons.school_outlined,
          orgNameController,
        ));
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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/images/bgImage.jpeg", fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: const Color(0xFF0F172A).withOpacity(0.5)),
        ),
        Center(
          child: Container(
            width: 1000,
            height: 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 8,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // LEFT HERO PANEL
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 40,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ScaleTransition(
                                  scale: _logoScaleAnimation,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      ImagePaths.logo,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "iCare Virtual\nHealthcare Platform",
                                        style: TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFamily: "Gilroy-Bold",
                                          height: 1.1,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Secure consultations, prescriptions & health records",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      _buildFeatureItem(
                                        Icons.check_circle_outline_rounded,
                                        "Book doctors online anytime",
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFeatureItem(
                                        Icons.medical_services_outlined,
                                        "Get digital prescriptions",
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFeatureItem(
                                        Icons.description_outlined,
                                        "Access lab reports instantly",
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    children: [
                                      _buildTrustRow(
                                        Icons.shield_rounded,
                                        "Data Protected & Secure",
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTrustRow(
                                        Icons.verified_user_rounded,
                                        "Verified Doctors & Specialists",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // RIGHT FORM PANEL
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 48,
                          ),
                          child: Center(
                            child: SingleChildScrollView(
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
                                            onTap: () =>
                                                setState(() => isLogin = true),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isLogin
                                                    ? AppColors.primaryColor
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                                boxShadow: isLogin
                                                    ? [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .primaryColor
                                                              .withOpacity(0.3),
                                                          blurRadius: 12,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
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
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    fontFamily: "Gilroy-Bold",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!widget.hideSignup)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () =>
                                                setState(() => isLogin = false),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeInOut,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: !isLogin
                                                    ? AppColors.primaryColor
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                                boxShadow: !isLogin
                                                    ? [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .primaryColor
                                                              .withOpacity(0.3),
                                                          blurRadius: 12,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
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
                                                        : const Color(
                                                            0xFF64748B,
                                                          ),
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
                                    isLogin
                                        ? "Welcome Back!"
                                        : "Create Your Account",
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
                                          if (!widget.initialSignup) ...[
                                          const SizedBox(height: 16),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                                width: 1.5,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedSignupRole,
                                                isExpanded: true,
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 'Patient',
                                                    child: Text(
                                                      'Patient - Consult & Manage Health',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Doctor',
                                                    child: Text(
                                                      'Doctor - Manage Patients & Prescriptions',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Pharmacy',
                                                    child: Text(
                                                      'Pharmacy - Prescription Fulfillment',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Laboratory',
                                                    child: Text(
                                                      'Laboratory - Diagnostics & Reports',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Instructor',
                                                    child: Text(
                                                      'Instructor - Teach Health Programs',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Student',
                                                    child: Text(
                                                      'Student - Learn & Grow',
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (val) {
                                                  if (val != null)
                                                    setState(
                                                      () => selectedSignupRole =
                                                          val,
                                                    );
                                                },
                                              ),
                                            ),
                                          ),
                                          ], // end !initialSignup
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
                                            borderColor: const Color(
                                              0xFFE2E8F0,
                                            ),
                                            borderWidth: 1.5,
                                            validator: (val) {
                                              if (val == null || val.isEmpty)
                                                return "Please enter your email";
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
                                            borderColor: const Color(
                                              0xFFE2E8F0,
                                            ),
                                            borderWidth: 1.5,
                                            validator: (val) {
                                              if (val == null || val.isEmpty)
                                                return "Please enter your phone number";
                                              return null;
                                            },
                                          ),
                                          ..._buildDynamicFields(
                                            isMobile: false,
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
                                            if (val == null || val.isEmpty)
                                              return "Please enter your password";
                                            if (!isLogin && val.length < 6)
                                              return "Password must be at least 6 characters";
                                            return null;
                                          },
                                        ),
                                        if (!isLogin) ...[
                                          const SizedBox(height: 16),
                                          CustomInputField(
                                            controller:
                                                confirmPasswordController,
                                            hintText: "Confirm Password",
                                            leadingIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                              color: Color(0xFF94A3B8),
                                              size: 22,
                                            ),
                                            isPassword: true,
                                            bgColor: const Color(0xFFF8FAFC),
                                            borderRadius: 14,
                                            borderColor: const Color(
                                              0xFFE2E8F0,
                                            ),
                                            borderWidth: 1.5,
                                            validator: (val) {
                                              if (val == null || val.isEmpty)
                                                return "Please confirm your password";
                                              if (val !=
                                                  passwordController.text
                                                      .trim())
                                                return "Passwords do not match";
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
                                                      onChanged: (val) =>
                                                          setState(
                                                            () => rememberMe =
                                                                val!,
                                                          ),
                                                      activeColor: AppColors
                                                          .primaryColor,
                                                      checkColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                      ),
                                                      side: const BorderSide(
                                                        color: Color(
                                                          0xFFCBD5E1,
                                                        ),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    "Remember me",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            ForgetPassword(),
                                                      ),
                                                    ),
                                                child: const Text(
                                                  "Forgot Password?",
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 28),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 54,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : _handleSubmit,
                                            child: isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        if (isLogin) ...[
                                          const SizedBox(height: 32),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.grey[300],
                                                  thickness: 1,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Text(
                                                  "Quick Sign In",
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 13,
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
                                                child: GestureDetector(
                                                  onTap: _handleGoogleSignIn,
                                                  child: _webSocialButton(
                                                    ImagePaths.google_icon,
                                                    "Google",
                                                  ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
            padding: EdgeInsets.symmetric(
              horizontal: ScallingConfig.moderateScale(15),
              vertical: ScallingConfig.moderateScale(isTablet ? 12 : 80),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                CustomText(
                  text: "Go Ahead & Set Up Your Account",
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  fontSize: 22,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 3),
                CustomText(
                  text: isLogin
                      ? "Sign In To Get The Best Doctor Consultation Experience"
                      : "Sign Up To Enjoy The Best Doctor Consultation Experience",
                  fontSize: 13,
                  color: AppColors.themeBlack,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                minHeight: Utils.windowHeight(context) * 0.67,
                maxHeight: Utils.windowHeight(context) * 0.85,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              _buildToggleButton(true, "Login"),
                              if (!widget.hideSignup)
                              _buildToggleButton(false, "Sign up"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (!isLogin) ...[
                                if (!widget.initialSignup) _buildRoleDropdown(),
                                if (!widget.initialSignup) const SizedBox(height: 5),
                                _buildMobileField(
                                  "Full Name",
                                  Icons.person_outline,
                                  usernameController,
                                ),
                                const SizedBox(height: 5),
                                _buildMobileField(
                                  "Email Address",
                                  Icons.email_outlined,
                                  emailController,
                                ),
                                const SizedBox(height: 5),
                                _buildMobileField(
                                  "Phone Number",
                                  Icons.phone_outlined,
                                  phoneController,
                                ),
                                ..._buildDynamicFields(isMobile: true),
                              ] else ...[
                                _buildMobileField(
                                  "Username or Email",
                                  Icons.person_outline,
                                  usernameController,
                                ),
                              ],
                              const SizedBox(height: 5),
                              _buildMobileField(
                                "Enter Your Password",
                                Icons.key,
                                passwordController,
                                isPassword: true,
                              ),
                              if (!isLogin) ...[
                                const SizedBox(height: 5),
                                _buildMobileField(
                                  "Confirm Password",
                                  Icons.key,
                                  confirmPasswordController,
                                  isPassword: true,
                                ),
                              ],
                              if (isLogin) _buildRememberForgotRow(),
                              const SizedBox(height: 20),
                              _buildSubmitButton(),
                              if (isLogin && _biometricEnabled)
                                _buildBiometricButton(),
                              if (isLogin) _buildMobileSocialRow(),
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

  Widget _buildToggleButton(bool value, String label) {
    bool selected = isLogin == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.veryLightGrey, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSignupRole,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Patient', child: Text('Patient — Consult & Manage Health')),
            DropdownMenuItem(value: 'Doctor', child: Text('Doctor — Manage Patients & Prescriptions')),
            DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy — Prescription Fulfillment')),
            DropdownMenuItem(value: 'Laboratory', child: Text('Laboratory — Diagnostics & Reports')),
            DropdownMenuItem(value: 'Instructor', child: Text('Instructor — Teach Health Programs')),
            DropdownMenuItem(value: 'Student', child: Text('Student — Learn & Grow')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => selectedSignupRole = val);
          },
        ),
      ),
    );
  }

  Widget _buildMobileField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return CustomInputField(
      hintText: hint,
      leadingIcon: Icon(icon, color: AppColors.primary500),
      controller: controller,
      isPassword: isPassword,
      bgColor: AppColors.white,
      borderRadius: 30,
      borderColor: AppColors.veryLightGrey,
      borderWidth: 2,
    );
  }

  Widget _buildRememberForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (val) => setState(() => rememberMe = val!),
              activeColor: AppColors.primary500,
            ),
            const Text("Remember me", style: TextStyle(fontSize: 14)),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ForgetPassword())),
          child: const Text(
            "Forgot Password",
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: isLoading ? null : _triggerBiometricLogin,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(30),
            color: AppColors.primaryColor.withOpacity(0.05),
          ),
          child: isLoading
              ? const Center(child: SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint_rounded, color: AppColors.primaryColor, size: 26),
                    const SizedBox(width: 10),
                    Text('Sign in with Biometric',
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Text(
                isLogin ? "Sign In" : "Sign Up",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
      ),
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
            _socialButton(ImagePaths.facebook_icon, "Facebook", onTap: null),
            const SizedBox(width: 20),
            _socialButton(ImagePaths.google_icon, "Google", onTap: _handleGoogleSignIn),
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

  Widget _socialButton(String assetPath, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final result = await _googleAuthService.signInWithGoogle();
      if (result['success'] == true && mounted) {
        final userData = result['user'] as Map<String, dynamic>;
        final token = result['data']['token']?.toString() ?? '';
        ref.read(authProvider.notifier).setUserToken(token);
        final user = app_user.User.fromJson(userData);
        ref.read(authProvider.notifier).setUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TabsScreen()),
        );
      } else if (mounted) {
        final msg = result['message']?.toString() ?? 'Google sign in failed';
        if (msg != 'Sign in cancelled') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        final result = await _authService.login(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (result['success']) {
          final token = result['data']['token'];
          final profileResult = await _userService.getUserProfile(token: token);
          if (profileResult['success'] && mounted) {
            final user = app_user.User.fromJson(profileResult['user']);
            ref.read(authProvider.notifier).setUser(user);
            ref.read(authProvider.notifier).setUserToken(token);
            await _offerBiometricEnrollment();
            if (mounted) Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const TabsScreen()),
            );
          } else {
            _showError('Failed to load user profile');
          }
        } else {
          _showError(result['message']);
        }
      } else {
        String backendRole = _mapRoleToBackend(selectedSignupRole);
        final result = await _authService.register(
          name: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: backendRole,
          phoneNumber: phoneController.text.trim(),
        );
        if (result['success']) {
          final isApproved = result['data']['isApproved'] ?? false;
          if (!isApproved) {
            _showApprovalDialog(backendRole);
          } else {
            final token = result['data']['token'];
            ref.read(authProvider.notifier).setUserToken(token);
            final profileResult = await _userService.getUserProfile(
              token: token,
            );
            if (profileResult['success'] && mounted) {
              final user = app_user.User.fromJson(profileResult['user']);
              ref.read(authProvider.notifier).setUser(user);
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
