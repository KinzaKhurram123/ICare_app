import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/lab_profile_setup.dart';
import 'package:icare/screens/pharmacy_profile_setup.dart';
import 'package:icare/services/auth_service.dart';
import 'package:icare/services/user_service.dart';
import 'package:icare/models/user.dart' as app_user;
import 'package:icare/utils/imagePaths.dart';
import 'package:icare/utils/theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String role;
  const SignupScreen({super.key, this.role = 'Patient'});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _credentials = TextEditingController();
  final _orgName = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _licenseNumber.dispose();
    _credentials.dispose();
    _orgName.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool get _isPatient => widget.role == 'Patient';
  bool get _isDoctor => widget.role == 'Doctor';
  bool get _isPharmacy => widget.role == 'Pharmacy';
  bool get _isLab => widget.role == 'Laboratory';
  bool get _isInstructor => widget.role == 'Instructor';
  // Pharmacy, Lab, Instructor go to admin review instead of direct signup
  bool get _needsReview => _isPharmacy || _isLab || _isInstructor;

  String get _roleDescription {
    switch (widget.role) {
      case 'Doctor':     return 'Doctor – Manage Patients & Prescriptions';
      case 'Pharmacy':   return 'Pharmacy – Prescription Fulfillment';
      case 'Laboratory': return 'Laboratory – Diagnostics & Reports';
      case 'Instructor': return 'Instructor – Teach Health Programs';
      default:           return 'Patient';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case 'Doctor':     return const Color(0xFF0036BC);
      case 'Pharmacy':   return const Color(0xFF10B981);
      case 'Laboratory': return const Color(0xFF8B5CF6);
      case 'Instructor': return const Color(0xFFF59E0B);
      default:           return AppColors.primaryColor;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showError('Please agree to the Terms & Conditions to continue.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Pharmacy / Lab / Instructor → admin review, no API call
      if (_needsReview) {
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showReviewDialog();
        return;
      }

      // Patient & Doctor → direct account creation
      ref.read(authProvider.notifier).setUserRole(widget.role);

      final result = await _authService.register(
        name: _fullName.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: widget.role,
        phoneNumber: _phone.text.trim(),
      );

      if (result['success']) {
        final token = result['data']['token'];
        ref.read(authProvider.notifier).setUserToken(token);

        final profileResult = await _userService.getUserProfile(token: token);

        if (profileResult['success'] && mounted) {
          final user = app_user.User.fromJson(profileResult['user']);
          ref.read(authProvider.notifier).setUser(user);

          context.go('/dashboard');
        } else {
          _showError(profileResult['message']);
        }
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 52),
        title: const Text(
          'Application Submitted',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Gilroy-Bold'),
        ),
        content: Text(
          'Your ${widget.role} application has been submitted for admin review. You will be notified once approved.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Gilroy-Medium', color: Color(0xFF64748B)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showError(dynamic msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.toString()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ── Reusable field ───────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: 'Gilroy-Medium',
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 20, color: const Color(0xFF94A3B8),
                  ),
                  onPressed: onToggle,
                )
              : null,
          filled: true,
          fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  // ── Form fields list ─────────────────────────────────────────────────────
  List<Widget> _buildFields() {
    return [
      _field(controller: _fullName, label: 'Full Name', icon: Icons.person_outline_rounded),
      if (!_isPatient)
        _field(
          controller: TextEditingController(text: _roleDescription),
          label: 'Role',
          icon: Icons.work_outline_rounded,
          readOnly: true,
          validator: (_) => null,
        ),
      _field(
        controller: _email,
        label: 'Email Address',
        icon: Icons.email_outlined,
        keyboard: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (!v.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
      _field(
        controller: _phone,
        label: 'Phone Number',
        icon: Icons.phone_outlined,
        keyboard: TextInputType.phone,
      ),
      // Doctor-only extra fields
      if (_isDoctor) ...[
        _field(controller: _licenseNumber, label: 'Medical License Number', icon: Icons.badge_outlined),
        _field(controller: _credentials, label: 'Credentials (e.g. MBBS, FCPS)', icon: Icons.school_outlined),
      ],
      _field(
        controller: _password,
        label: 'Password',
        icon: Icons.lock_outline_rounded,
        obscure: _obscurePass,
        onToggle: () => setState(() => _obscurePass = !_obscurePass),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (v.length < 6) return 'Minimum 6 characters';
          return null;
        },
      ),
      _field(
        controller: _confirmPassword,
        label: 'Confirm Password',
        icon: Icons.lock_outline_rounded,
        obscure: _obscureConfirm,
        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required';
          if (v != _password.text) return 'Passwords do not match';
          return null;
        },
      ),
      // Terms & Conditions
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22, height: 22,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                activeColor: AppColors.primaryColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I agree to the ',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontFamily: 'Gilroy-Medium'),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold'),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Submit button ────────────────────────────────────────────────────────
  Widget _submitBtn({double height = 52}) => SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isPatient ? 'Create Account' : 'Create Account',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold',
                  ),
                ),
        ),
      );

  Widget _signInLink() => Center(
        child: GestureDetector(
          onTap: () => context.go('/login'),
          child: RichText(
            text: TextSpan(
              text: 'Already have an account? ',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Gilroy-Medium'),
              children: [
                TextSpan(
                  text: 'Sign In',
                  style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold'),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Left hero panel ──────────────────────────────────────────────────────
  Widget _buildLeftPanel(double height) => Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001E6C), Color(0xFF0036BC), Color(0xFF035BE5)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -80, left: -80, child: _circle(300, 0.04)),
            Positioned(bottom: -100, right: -50, child: _circle(350, 0.03)),
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
                    const Text('iCare Virtual Hospital',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text('Your Virtual Healthcare Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 8),
                    Text('Secure consultations, prescriptions\n& health records',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.6),
                    ),
                    const SizedBox(height: 44),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _trust(Icons.shield_rounded, 'Data Protected & Secure'),
                        const SizedBox(height: 14),
                        _trust(Icons.verified_user_rounded, 'Verified Doctors Only'),
                        const SizedBox(height: 14),
                        _trust(Icons.medical_services_rounded, 'Complete Virtual Hospital'),
                        const SizedBox(height: 14),
                        _trust(Icons.people_rounded, 'Trusted by Patients Nationwide'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _circle(double size, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  Widget _trust(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          ),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      );

  // ── Right form panel ─────────────────────────────────────────────────────
  Widget _buildRightPanel() => Container(
        color: const Color(0xFFF8FAFD),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 480,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0036BC).withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 16)),
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPatient ? 'Create Your Account' : 'Join as ${widget.role}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0B2D6E), fontFamily: 'Gilroy-Bold', letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isPatient ? 'Sign up for a better healthcare experience' : _roleDescription,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500], fontFamily: 'Gilroy-Medium'),
                    ),
                    const SizedBox(height: 28),
                    ..._buildFields(),
                    const SizedBox(height: 8),
                    _submitBtn(),
                    const SizedBox(height: 20),
                    _signInLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(flex: 5, child: _buildLeftPanel(size.height)),
            Expanded(flex: 5, child: _buildRightPanel()),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0036BC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(ImagePaths.logo, width: 30, height: 30),
            const SizedBox(width: 8),
            Text(
              _isPatient ? 'Sign Up' : '${widget.role} Sign Up',
              style: const TextStyle(color: Color(0xFF0036BC), fontWeight: FontWeight.w800, fontSize: 17, fontFamily: 'Gilroy-Bold'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isPatient ? 'Create Your Account' : 'Join as ${widget.role}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0B2D6E), fontFamily: 'Gilroy-Bold'),
              ),
              const SizedBox(height: 4),
              Text(
                _isPatient ? 'Sign up for a better healthcare experience' : _roleDescription,
                style: TextStyle(fontSize: 13, color: Colors.grey[500], fontFamily: 'Gilroy-Medium'),
              ),
              const SizedBox(height: 24),
              ..._buildFields(),
              const SizedBox(height: 8),
              _submitBtn(height: 50),
              const SizedBox(height: 20),
              _signInLink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
