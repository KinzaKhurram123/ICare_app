import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/auth_left_panel.dart';
import 'package:icare/screens/verification_status_screen.dart';

class WorkWithUsSignup extends StatefulWidget {
  const WorkWithUsSignup({super.key});

  @override
  State<WorkWithUsSignup> createState() => _WorkWithUsSignupState();
}

class _WorkWithUsSignupState extends State<WorkWithUsSignup> {
  int _step = 0; // 0 = Basic Info, 1 = Role Selection, 2 = Compliance

  // Step 1 fields
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // Step 2
  String? _selectedRole;

  // Step 3
  bool _drapAgreed = false;
  bool _termsAgreed = false;
  bool _submitting = false;

  static const _roles = [
    {
      'role': 'Doctor',
      'title': 'Doctor',
      'subtitle': 'Manage Patients & Prescriptions',
      'desc': 'Join as a verified healthcare provider',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF0036BC),
    },
    {
      'role': 'Pharmacy',
      'title': 'Pharmacy',
      'subtitle': 'Prescription Fulfillment',
      'desc': 'Serve patients with medicines & healthcare products',
      'icon': Icons.local_pharmacy_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'role': 'Laboratory',
      'title': 'Laboratory',
      'subtitle': 'Diagnostics & Reports',
      'desc': 'Provide diagnostic tests and lab services',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your role to continue')),
        );
        return;
      }
      setState(() => _step = 2);
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    if (!_drapAgreed || !_termsAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept both agreements to continue')),
      );
      return;
    }
    setState(() => _submitting = true);

    // Simulate submission (would send to admin API)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _submitting = false);

    if (mounted) {
      // Navigate to verification status screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => VerificationStatusScreen(
            role: _selectedRole!,
            applicantName: _nameCtrl.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 5, child: AuthLeftPanel()),
        Expanded(flex: 5, child: _buildRightPanel(context)),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Container(
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
                BoxShadow(
                  color: const Color(0xFF0036BC).withOpacity(0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (_step > 0) {
                      _prevStep();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go('/home');
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0B2D6E)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Work With Us',
                  style: TextStyle(
                    color: Color(0xFF0036BC),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: 'Gilroy-Bold',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button (desktop only)
        if (ResponsiveHelper.isDesktop(context)) ...[
          InkWell(
            onTap: () {
              if (_step > 0) {
                _prevStep();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/home');
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0B2D6E)),
            ),
          ),
          const SizedBox(height: 28),
        ],

        // Step indicator
        _StepIndicator(currentStep: _step),
        const SizedBox(height: 28),

        // Step content
        if (_step == 0) _buildStep1(),
        if (_step == 1) _buildStep2(),
        if (_step == 2) _buildStep3(),

        const SizedBox(height: 24),

        // Already have account
        if (_step == 0)
          Center(
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontFamily: 'Gilroy-Medium'),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Step 1: Basic Info ────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0B2D6E), fontFamily: 'Gilroy-Bold'),
          ),
          const SizedBox(height: 6),
          Text('Tell us a bit about yourself', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 24),
          _inputField(_nameCtrl, 'Full Name', Icons.person_outline_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Name is required' : null),
          const SizedBox(height: 14),
          _inputField(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null),
          const SizedBox(height: 14),
          _inputField(_emailCtrl, 'Email Address', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'Email is required' : null),
          const SizedBox(height: 14),
          _inputField(_cityCtrl, 'City', Icons.location_city_outlined,
              validator: (v) => v == null || v.isEmpty ? 'City is required' : null),
          const SizedBox(height: 28),
          _primaryButton('Continue', Icons.arrow_forward_rounded, _nextStep),
        ],
      ),
    );
  }

  // ── Step 2: Role Selection ────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Role',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0B2D6E), fontFamily: 'Gilroy-Bold'),
        ),
        const SizedBox(height: 6),
        Text('Do you want to work with us as?', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 24),
        ..._roles.map((r) => _roleCard(r)),
        const SizedBox(height: 28),
        _primaryButton('Continue', Icons.arrow_forward_rounded, _nextStep),
      ],
    );
  }

  Widget _roleCard(Map<String, dynamic> r) {
    final color = r['color'] as Color;
    final isSelected = _selectedRole == r['role'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = r['role'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['title'] as String,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isSelected ? color : const Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(r['subtitle'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                )
              else
                Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey[300], size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3: Compliance ────────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compliance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0B2D6E), fontFamily: 'Gilroy-Bold'),
        ),
        const SizedBox(height: 6),
        Text('Please review and accept the following', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 24),

        // DRAP agreement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _drapAgreed ? AppColors.primaryColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _drapAgreed,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _drapAgreed = v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DRAP Policy Agreement',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(
                      'I confirm that I/this entity operates in compliance with DRAP (Drug Regulatory Authority of Pakistan) regulations and applicable healthcare laws.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Terms agreement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _termsAgreed ? AppColors.primaryColor.withOpacity(0.3) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _termsAgreed,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _termsAgreed = v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Terms of Service',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(
                      'I accept the iCare platform Terms of Service and agree to provide accurate information. I understand my account is subject to verification by the iCare admin team.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.primaryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Applying as: $_selectedRole • ${_nameCtrl.text} • ${_cityCtrl.text}',
                  style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold')),
          ),
        ),
      ],
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _primaryButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Gilroy-Bold')),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ── Step Indicator ──────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _steps = ['Basic Info', 'Role', 'Compliance'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: currentStep > stepIndex ? AppColors.primaryColor : const Color(0xFFE2E8F0),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = currentStep > stepIndex;
        final isCurrent = currentStep == stepIndex;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.primaryColor
                    : isCurrent
                        ? AppColors.primaryColor
                        : const Color(0xFFE2E8F0),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex],
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent || isDone ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent || isDone ? AppColors.primaryColor : const Color(0xFF94A3B8),
              ),
            ),
          ],
        );
      }),
    );
  }
}
