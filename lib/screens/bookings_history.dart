import 'package:flutter/material.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

// helper so cards can trigger a refresh on the parent
typedef RefreshCallback = void Function();

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<AppointmentDetail> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    final result = await _appointmentService.getMyAppointmentsDetailed();

    debugPrint('📋 Bookings History - Load result: ${result['success']}');

    if (result['success']) {
      final appointments = result['appointments'] as List<AppointmentDetail>;
      debugPrint('📋 Bookings History - Loaded ${appointments.length} appointments');
      for (var apt in appointments) {
        debugPrint(
          '   - ${apt.status}: ${apt.doctor?.name ?? "Unknown"} on ${apt.date}',
        );
      }

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } else {
      debugPrint('❌ Bookings History - Failed to load: ${result['message']}');
      setState(() => _isLoading = false);
    }
  }

  int _getCountByStatus(String status) {
    return _appointments
        .where((a) => a.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  List<AppointmentDetail> _getAppointmentsByStatus(String status) {
    return _appointments
        .where((a) => a.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  List<AppointmentDetail> get _upcomingAppointments {
    final now = DateTime.now();
    return _appointments.where((a) {
      return a.status.toLowerCase() == 'confirmed' && a.date.isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CustomBackButton(color: Colors.white),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bookings History',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay on top of your schedule with real-time updates',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    _isLoading
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatChip(
                                'Total',
                                _appointments.length,
                                const Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                'Active',
                                _getCountByStatus('confirmed'),
                                const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                'Done',
                                _getCountByStatus('completed'),
                                const Color(0xFF8B5CF6),
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _loadAppointments,
                          child: ListView(
                            padding: EdgeInsets.all(isDesktop ? 32 : 20),
                            children: [
                              // Book Appointment Now button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const DoctorsList()),
                                  ),
                                  icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                                  label: const Text(
                                    'Book Appointment Now',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Pending first
                              _buildCategoryCard(
                                'Pending Bookings',
                                'Awaiting confirmation',
                                _getCountByStatus('pending'),
                                const Color(0xFFF59E0B),
                                Icons.hourglass_empty_rounded,
                                _getAppointmentsByStatus('pending'),
                              ),
                              const SizedBox(height: 16),
                              _buildCategoryCard(
                                'In Progress Bookings',
                                'Currently active appointments',
                                _getCountByStatus('confirmed'),
                                const Color(0xFF3B82F6),
                                Icons.schedule_rounded,
                                _getAppointmentsByStatus('confirmed'),
                              ),
                              const SizedBox(height: 16),
                              _buildCategoryCard(
                                'Upcoming Bookings',
                                'Scheduled for later',
                                _upcomingAppointments.length,
                                const Color(0xFF0EA5E9),
                                Icons.event_rounded,
                                _upcomingAppointments,
                              ),
                              const SizedBox(height: 16),
                              _buildCategoryCard(
                                'Completed Bookings',
                                'Past successful visits',
                                _getCountByStatus('completed'),
                                const Color(0xFF10B981),
                                Icons.check_circle_rounded,
                                _getAppointmentsByStatus('completed'),
                              ),
                              const SizedBox(height: 16),
                              _buildCategoryCard(
                                'Cancelled Bookings',
                                'Appointments you cancelled',
                                _getCountByStatus('cancelled'),
                                const Color(0xFFEF4444),
                                Icons.cancel_rounded,
                                _getAppointmentsByStatus('cancelled'),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    int count,
    Color color,
    IconData icon,
    List<AppointmentDetail> appointments,
  ) {
    return InkWell(
      onTap: count > 0
          ? () => _showAppointmentsList(title, appointments, color)
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: count > 0 ? const Color(0xFF64748B) : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentsList(
    String title,
    List<AppointmentDetail> appointments,
    Color color,
  ) {
    final outerContext = context; // capture before bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (sheetContext2, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${appointments.length} appointment${appointments.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return _buildAppointmentCard(
                      appointment,
                      color,
                      outerContext: outerContext,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _loadAppointments()); // refresh after sheet closes
  }

  Future<void> _confirmCancel(AppointmentDetail appointment, {BuildContext? outerContext}) async {
    final ctx = outerContext ?? context;
    final confirmed = await showDialog<bool>(
      context: ctx,
      useRootNavigator: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('No', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await AppointmentService().cancelAppointment(
      appointmentId: appointment.id,
    );

    if (!mounted) return;

    final scaffoldCtx = outerContext ?? context;
    if (result['success'] == true) {
      ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadAppointments();
    } else {
      ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to cancel appointment'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAppointmentCard(AppointmentDetail appointment, Color color, {BuildContext? outerContext}) {    final isPending = appointment.status.toLowerCase() == 'pending';
    final isConfirmed = appointment.status.toLowerCase() == 'confirmed';
    final isCompleted = appointment.status.toLowerCase() == 'completed';

    Color statusColor = color;
    if (isConfirmed) statusColor = const Color(0xFF10B981);
    if (isCompleted) statusColor = const Color(0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    appointment.doctor?.name.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor?.name ?? 'Doctor',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    if ((appointment.doctor?.role ?? '').isNotEmpty && appointment.doctor?.role != 'Doctor')
                      Text(
                        appointment.doctor!.role,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM dd, yyyy').format(appointment.date),
                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                appointment.timeSlot,
                style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.description_outlined, size: 14, color: const Color(0xFF6366F1)),
                const SizedBox(width: 6),
                const Text(
                  'Prescription & notes available',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          if (isPending || isConfirmed) ...[
            const SizedBox(height: 12),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _confirmCancel(appointment, outerContext: outerContext),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEF4444)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text(
                      'Cancel Appointment',
                      style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
