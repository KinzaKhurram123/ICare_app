import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/laboratory_service.dart';
import '../widgets/back_button.dart';
import 'chat_screen.dart';

class LabBookingDetails extends StatefulWidget {
  final Map<String, dynamic> booking;
  const LabBookingDetails({super.key, required this.booking});

  @override
  State<LabBookingDetails> createState() => _LabBookingDetailsState();
}

class _LabBookingDetailsState extends State<LabBookingDetails> with SingleTickerProviderStateMixin {
  final LaboratoryService _labService = LaboratoryService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isUpdating = false;
  bool _isUploading = false;
  late Map<String, dynamic> _booking;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Premium Theme Colors
  static const Color primaryColor = Color(0xFF0B2D6E);
  static const Color secondaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF0EA5E9);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _booking = Map<String, dynamic>.from(widget.booking);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await _labService.updateBookingStatus(_booking['_id'], status);
      setState(() {
        _booking = Map<String, dynamic>.from(updated);
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _uploadReport() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final reportUrl = await _labService.uploadReport(_booking['_id'], bytes.toList(), file.name);
      
      // After upload, actually complete the booking or just attach URL
      await _labService.updateBooking(_booking['_id'], {
        'status': 'completed',
        'reportUrl': reportUrl,
        'completedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _booking['status'] = 'completed';
        _booking['reportUrl'] = reportUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report uploaded and test completed!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _generateInvoice() {
    // Premium Invoice Dialog
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INVOICE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor)),
                      Text('Official Receipt', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Icon(Icons.receipt_long_rounded, color: primaryColor.withOpacity(0.2), size: 48),
                ],
              ),
              const Divider(height: 40),
              _invoiceRow('Patient', _booking['patient']?['name'] ?? 'N/A'),
              _invoiceRow('Test', _booking['testName'] ?? 'N/A'),
              _invoiceRow('Date', DateFormat('dd MMM, yyyy').format(DateTime.parse(_booking['date']))),
              _invoiceRow('Amount', 'PKR ${_booking['price'] ?? 0}'),
              _invoiceRow('Status', _booking['status'].toUpperCase(), valueColor: _getStatusColor(_booking['status'])),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('PKR ${_booking['price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice saved to downloads')),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Booking Details',
          style: TextStyle(fontSize: 18, fontFamily: 'Gilroy-Bold', fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => ChatScreen(
                userId: _booking['patient']?['_id'] ?? _booking['patient']?['id'] ?? '',
                userName: _booking['patient']?['name'] ?? 'Patient',
              )),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryColor),
          ),
        ],
      ),
      body: _isUpdating 
          ? const Center(child: CircularProgressIndicator()) 
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientCard(),
                    const SizedBox(height: 20),
                    _buildTestDetailsCard(),
                    const SizedBox(height: 20),
                    _buildStatusCard(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    if (_booking['status'] != 'completed' && _booking['status'] != 'cancelled')
                      _buildBottomActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPatientCard() {
    final patient = _booking['patient'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryColor, secondaryColor]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 36)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient?['name'] ?? 'Unknown Patient', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(patient?['email'] ?? 'No email provided', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(patient?['phoneNumber'] ?? 'No phone provided', style: const TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TEST INFORMATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          _detailRow(Icons.science_rounded, 'Test Name', _booking['testName'] ?? 'N/A'),
          _detailRow(Icons.payments_rounded, 'Price', 'PKR ${_booking['price'] ?? 0}'),
          _detailRow(Icons.calendar_month_rounded, 'Date', DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(_booking['date']))),
          _detailRow(Icons.history_rounded, 'Booking ID', _booking['bookingNumber'] ?? _booking['_id'].toString().toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = _getStatusColor(_booking['status']);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_getStatusIcon(_booking['status']), color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CURRENT STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(_booking['status'].toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            _actionButton(Icons.receipt_long_rounded, 'Invoice', Colors.green, _generateInvoice),
            const SizedBox(width: 16),
            _actionButton(Icons.biotech_rounded, 'Upload Result', Colors.orange, _uploadReport, isLoading: _isUploading),
            const SizedBox(width: 16),
            _actionButton(Icons.share_rounded, 'Share Details', Colors.blue, () {}),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap, {bool isLoading = false}) {
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        if (_booking['status'] == 'pending')
          ElevatedButton(
            onPressed: () => _updateStatus('confirmed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CONFIRM BOOKING', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        const SizedBox(height: 12),
        if (_booking['status'] == 'confirmed')
          ElevatedButton(
            onPressed: _uploadReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('COMPLETE & UPLOAD REPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _updateStatus('cancelled'),
          child: const Text('CANCEL BOOKING', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.schedule_rounded;
      case 'confirmed': return Icons.check_circle_outline_rounded;
      case 'completed': return Icons.done_all_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }
}
