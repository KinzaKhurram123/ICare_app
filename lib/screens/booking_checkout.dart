import 'package:flutter/material.dart';
import 'package:icare/models/doctor.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_text.dart';
import 'package:icare/screens/payment_method_selection.dart';
import 'package:intl/intl.dart';

class BookingCheckoutScreen extends StatefulWidget {
  const BookingCheckoutScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
  });

  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedTime;

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final TextEditingController _nameController = TextEditingController();
  
  String _appointmentFor = "Myself";
  bool _isBooking = false;

  Future<void> _confirmBooking() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name')),
      );
      return;
    }

    setState(() => _isBooking = true);
    
    final result = await _appointmentService.bookAppointment(
      doctorId: widget.doctor.id,
      date: widget.selectedDate,
      timeSlot: widget.selectedTime,
      reason: "Patient Name: ${_nameController.text}, For: $_appointmentFor",
    );

    setState(() => _isBooking = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentMethodSelection(
            doctor: widget.doctor,
            amount: 1200,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text("Booking Confirmed!", style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        content: Text(
          "Your appointment with Dr. ${widget.doctor.user.name} has been successfully scheduled for ${DateFormat('MMM dd').format(widget.selectedDate)} at ${widget.selectedTime}.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // dialog
                Navigator.of(context).pop(); // checkout
                Navigator.of(context).pop(); // booking
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Go Back", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
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
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 40 : 16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Forms
        Expanded(
          flex: 2,
          child: _buildDetailsSection(),
        ),
        const SizedBox(width: 32),
        // Right Column: Summary
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
        _buildDetailsSection(),
        const SizedBox(height: 24),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildDetailsSection() {
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
          // Appointment For
          const Text("Appointment For", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSelectionChip("Myself"),
              const SizedBox(width: 12),
              _buildSelectionChip("+ Someone else", isSelectable: true),
            ],
          ),
          const SizedBox(height: 40),

          // Patient Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 12),
              const Text("Patient Name", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF374151))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Enter your name",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 40),

          // Payment Method
          const Row(
            children: [
              Icon(Icons.credit_card, color: Colors.grey),
              const SizedBox(width: 12),
              const Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 2),
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("Online Payment", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                const Text("Rs. 1,200", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  widget.doctor.user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. ${widget.doctor.user.name}",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.specialization ?? "General Physician",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryInfoRow("Video consultation", "Rs. 1,200"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "${DateFormat('MMM dd').format(widget.selectedDate)}, ${widget.selectedTime}",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isBooking 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Confirm booking",
                      style: TextStyle(
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

  Widget _buildSummaryInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _buildSelectionChip(String label, {bool isSelectable = false}) {
    bool isSelected = _appointmentFor == label || (label == "Myself" && _appointmentFor == "Myself");
    if (label == "+ Someone else") isSelected = _appointmentFor == "Someone else";

    return GestureDetector(
      onTap: () {
        if (label == "Myself") setState(() => _appointmentFor = "Myself");
        else setState(() => _appointmentFor = "Someone else");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFEDD5) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            if (isSelected && label == "Myself") ...[
              const Icon(Icons.check, size: 14, color: Color(0xFFF97316)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? const Color(0xFFC2410C) : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
