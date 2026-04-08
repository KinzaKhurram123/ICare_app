import 'dart:async';
import 'package:flutter/material.dart';
import '../services/laboratory_service.dart';
import '../widgets/back_button.dart';
import 'package:intl/intl.dart';
import 'package:icare/screens/lab_booking_details.dart';
import 'package:icare/utils/error_handler.dart';
import 'package:icare/screens/upload_lab_report_screen.dart';

class LabBookingsManagement extends StatefulWidget {
  final String? initialFilter;
  final String? title;
  const LabBookingsManagement({super.key, this.initialFilter, this.title});

  @override
  State<LabBookingsManagement> createState() => _LabBookingsManagementState();
}

class _LabBookingsManagementState extends State<LabBookingsManagement>
    with TickerProviderStateMixin {
  final LaboratoryService _labService = LaboratoryService();
  Timer? _refreshTimer;
  bool _isLoading = true;
  List<dynamic> _bookings = [];
  String? _labId;
  late String _selectedFilter;
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
    _selectedFilter = widget.initialFilter ?? 'all';
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadBookings();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && !_isLoading) {
        _silentLoadBookings();
      }
    });
  }

  Future<void> _silentLoadBookings() async {
    try {
      if (_labId == null) {
        final profile = await _labService.getProfile();
        _labId = profile['_id'];
      }

      final bookings = await _labService.getBookings(
        _labId!,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      if (mounted) {
        setState(() {
          _bookings = bookings;
        });
      }
    } catch (e) {
      debugPrint('Silent refresh error: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _labService.getProfile();
      _labId = profile['_id'];
      if (_labId == null) throw Exception('Laboratory ID not found');

      final bookings = await _labService.getBookings(
        _labId!,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMessage = ErrorHandler.getFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: ErrorHandler.isRetryable(e)
                ? SnackBarAction(
                    label: ErrorHandler.getActionText(e),
                    textColor: Colors.white,
                    onPressed: _loadBookings,
                  )
                : null,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    try {
      await _labService.updateBookingStatus(bookingId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _loadBookings();
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: ErrorHandler.isRetryable(e)
                ? SnackBarAction(
                    label: ErrorHandler.getActionText(e),
                    textColor: Colors.white,
                    onPressed: () => _updateStatus(bookingId, newStatus),
                  )
                : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          widget.title ?? 'Bookings Management',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _bookings.isEmpty
                ? _buildEmptyState()
                : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lab Bookings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and track all test bookings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.science_rounded, size: 48, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', 'all', Icons.list_rounded),
          _buildFilterChip('Urgent', 'urgent', Icons.priority_high_rounded),
          _buildFilterChip('Pending', 'pending', Icons.schedule_rounded),
          _buildFilterChip(
            'Confirmed',
            'confirmed',
            Icons.check_circle_outline_rounded,
          ),
          _buildFilterChip('Completed', 'completed', Icons.done_all_rounded),
          _buildFilterChip('Cancelled', 'cancelled', Icons.cancel_outlined),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    final color = _getStatusColor(value);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: () {
          setState(() => _selectedFilter = value);
          _loadBookings();
        },
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : color),
        label: Text(label),
        backgroundColor: isSelected ? color : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No bookings found',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    // Filter bookings by urgency if urgent filter is selected
    final filteredBookings = _selectedFilter == 'urgent'
        ? _bookings.where((b) => b['urgency'] == 'Urgent').toList()
        : _bookings;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadBookings,
        child: filteredBookings.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) =>
                    _buildBookingCard(filteredBookings[index]),
              ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final date = DateTime.tryParse(booking['date'] ?? '') ?? DateTime.now();
    final patient = booking['patient'];
    final testName = booking['testName'] ?? 'Test';
    final isDoctorOrdered = booking['medicalRecord'] != null;
    final doctorName = booking['doctor']?['name'];
    final urgency = booking['urgency'] ?? 'Normal';
    final isUrgent = urgency == 'Urgent';
    final diagnosisNotes = booking['diagnosisNotes'];
    final specialInstructions = booking['specialInstructions'];

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => LabBookingDetails(booking: booking),
          ),
        );
        _loadBookings();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUrgent
                ? Colors.red.withOpacity(0.4)
                : isDoctorOrdered
                ? const Color(0xFF8B5CF6).withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            width: isUrgent || isDoctorOrdered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency and Doctor-ordered badges
            Row(
              children: [
                if (isUrgent)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.priority_high_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isDoctorOrdered)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medical_services_rounded,
                          size: 14,
                          color: Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Doctor Ordered${doctorName != null ? ' by Dr. $doctorName' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (isUrgent || isDoctorOrdered) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTestIcon(testName), color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        patient?['name'] ?? 'Patient',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // Diagnosis notes
            if (diagnosisNotes != null && diagnosisNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 14,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Diagnosis Notes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      diagnosisNotes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Special instructions
            if (specialInstructions != null &&
                specialInstructions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      specialInstructions,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (status.toLowerCase() == 'pending')
                  TextButton.icon(
                    onPressed: () => _updateStatus(booking['_id'], 'confirmed'),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Confirm'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                if (status.toLowerCase() == 'confirmed' ||
                    status.toLowerCase() == 'completed')
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => UploadLabReportScreen(booking: booking),
                        ),
                      );
                      _loadBookings();
                    },
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Upload'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                Text(
                  'PKR ${booking['price'] ?? 0}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTestIcon(String testName) {
    final name = testName.toLowerCase();
    if (name.contains('blood')) return Icons.bloodtype_rounded;
    if (name.contains('covid')) return Icons.coronavirus_rounded;
    return Icons.science_rounded;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
