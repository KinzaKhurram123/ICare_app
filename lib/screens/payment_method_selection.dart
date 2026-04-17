import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/screens/tabs.dart';

class PaymentMethodSelection extends StatefulWidget {
  const PaymentMethodSelection({
    super.key,
    required this.doctor,
    this.amount = 1200,
  });

  final Doctor doctor;
  final double amount;

  @override
  State<PaymentMethodSelection> createState() => _PaymentMethodSelectionState();
}

class _PaymentMethodSelectionState extends State<PaymentMethodSelection> {
  String? _selectedMethod;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {
      "id": "card",
      "title": "Credit or Debit Card",
      "subtitle": "VISA / Mastercard",
      "icon": Icons.credit_card_rounded,
    },
    {
      "id": "easypaisa",
      "title": "Easy Paisa",
      "icon": Icons.account_balance_wallet_outlined,
    },
    {
      "id": "jazzcash",
      "title": "Jazz Cash",
      "icon": Icons.wallet_rounded,
    },
    {
      "id": "bank",
      "title": "Bank Transfer",
      "icon": Icons.account_balance_outlined,
    },
  ];

  void _handlePayment() async {
    if (_selectedMethod == null) return;

    setState(() => _isProcessing = true);
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              "Payment Successful",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              "Your appointment with Dr. ${widget.doctor.user.name} is now confirmed.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const TabsScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Go to My Appointments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 40 : 16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Top Alert Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Doctor's slot is on hold for you. Pay to confirm.",
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Payment Methods
        Expanded(
          flex: 2,
          child: _buildMethodsList(),
        ),
        const SizedBox(width: 32),
        // Right: Order Summary
        Expanded(
          flex: 1,
          child: _buildSummaryCard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMethodsList(),
        const SizedBox(height: 24),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildMethodsList() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose a payment method",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF111827), letterSpacing: -0.3),
          ),
          const SizedBox(height: 24),
          ..._methods.map((method) => _buildMethodItem(method)).toList(),
        ],
      ),
    );
  }

  Widget _buildMethodItem(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(method['icon'], color: isSelected ? AppColors.primaryColor : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isSelected ? AppColors.primaryColor : const Color(0xFF1F2937),
                    ),
                  ),
                  if (method['subtitle'] != null)
                    Text(
                      method['subtitle'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Details",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF111827), letterSpacing: -0.3),
          ),
          const SizedBox(height: 24),
          _buildDetailRow("Original Fee", "Rs. ${widget.amount.toInt()}"),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Payable",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF4B5563)),
              ),
              Text(
                "Rs. ${widget.amount.toInt()}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_selectedMethod == null || _isProcessing) ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Pay Rs. ${widget.amount.toInt()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}
