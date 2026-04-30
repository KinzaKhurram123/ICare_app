import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/video_call_web.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:intl/intl.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<AppointmentDetail> _appointments = [];
  bool _isLoading = true;
  String _currentUserId = '';
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndAppointments();
  }

  Future<void> _loadUserAndAppointments() async {
    final user = await SharedPref().getUserData();
    if (mounted && user != null) {
      setState(() {
        _currentUserId = user.id ?? '';
        _currentUserName = user.name ?? user.email ?? 'User';
      });
    }
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final result = await _appointmentService.getMyAppointmentsDetailed();
    if (result['success']) {
      setState(() {
        _appointments = result['appointments'] as List<AppointmentDetail>;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  int _getCountByStatus(String status) =>
      _appointments.where((a) => a.status.toLowerCase() == status.toLowerCase()).length;

  List<AppointmentDetail> _getAppointmentsByStatus(String status) =>
      _appointments.where((a) => a.status.toLowerCase() == status.toLowerCase()).toList();

  List<AppointmentDetail> get _inProgressAppointments => _getAppointmentsByStatus('in_progress');

  List<AppointmentDetail> get _upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.status.toLowerCase() == 'confirmed' && a.date.isAfter(now))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Utils.windowWidth(context) > 600;
    final pad = isDesktop ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Collapsing gradient header ──────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              collapsedHeight: 60,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF1E3A5F),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back button row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text('Home',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.calendar_month_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bookings History',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Stay on top of your schedule',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 16),
                          // Stats chips
                          if (!_isLoading)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _statChip('Total', _appointments.length,
                                    const Color(0xFF3B82F6)),
                                const SizedBox(width: 10),
                                _statChip('Live',
                                    _getCountByStatus('in_progress'),
                                    const Color(0xFFEF4444)),
                                const SizedBox(width: 10),
                                _statChip('Done',
                                    _getCountByStatus('completed'),
                                    const Color(0xFF8B5CF6)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Collapsed title
                title: const Text(
                  'Bookings History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                ),
                centerTitle: true,
              ),
            ),

            // ── Body content ────────────────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: EdgeInsets.all(pad),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Book Now button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DoctorsList()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: const Text('Book Appointment Now',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // In Progress card
                    _buildInProgressCard(),
                    const SizedBox(height: 12),

                    // Category cards
                    _categoryCard(
                      'Upcoming Bookings',
                      'Scheduled for later',
                      _upcomingAppointments.length,
                      const Color(0xFF0EA5E9),
                      Icons.access_time_rounded,
                      _upcomingAppointments,
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      'Cancelled Bookings',
                      'Appointments you cancelled',
                      _getCountByStatus('cancelled'),
                      const Color(0xFFEF4444),
                      Icons.cancel_outlined,
                      _getAppointmentsByStatus('cancelled'),
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      'Completed Bookings',
                      'Past successful visits',
                      _getCountByStatus('completed'),
                      const Color(0xFF10B981),
                      Icons.check_circle_outline_rounded,
                      _getAppointmentsByStatus('completed'),
                    ),
                    const SizedBox(height: 12),
                    _categoryCard(
                      'Pending Bookings',
                      'Awaiting confirmation',
                      _getCountByStatus('pending'),
                      const Color(0xFFF59E0B),
                      Icons.hourglass_empty_rounded,
                      _getAppointmentsByStatus('pending'),
                    ),
                    const SizedBox(height: 20),

                    if (_appointments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text('No bookings yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── In Progress card with smart Rejoin ──────────────────────────────────
  Widget _buildInProgressCard() {
    final appts = _inProgressAppointments;
    const color = Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.videocam_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consultation In Progress',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A))),
                    SizedBox(height: 4),
                    Text('Tap Rejoin to continue your video call',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text('${appts.length}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ],
          ),
          if (appts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            ...appts.map((a) => _rejoinRow(a)),
          ],
        ],
      ),
    );
  }

  Widget _rejoinRow(AppointmentDetail appt) {
    // Only the appointment with a valid channelName gets an active Rejoin button
    final hasChannel =
        appt.channelName != null && appt.channelName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: hasChannel
            ? const Color(0xFFFFF1F1)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasChannel
              ? const Color(0xFFEF4444).withValues(alpha: 0.25)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasChannel
                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                    : [Colors.grey.shade400, Colors.grey.shade300],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (appt.doctor?.name ?? 'D').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.doctor?.name ?? 'Doctor',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasChannel
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8)),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(appt.date),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          // ── Rejoin button: active only if channelName is valid ──
          hasChannel
              ? ElevatedButton.icon(
                  onPressed: () => _rejoinConsultation(appt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.video_call_rounded, size: 18),
                  label: const Text('Rejoin',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_call_rounded,
                          size: 18, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text('Rejoin',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _rejoinConsultation(AppointmentDetail appt) {
    final channel = appt.channelName;
    if (channel == null || channel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No active video session for this appointment')),
      );
      return;
    }
    if (kIsWeb) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCall(
            channelName: channel,
            remoteUserName: appt.doctor?.name ?? 'Doctor',
            currentUserId: _currentUserId,
            currentUserName: _currentUserName,
            appointmentId: appt.id,
            patientId: appt.patient?.id,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video call is available on web')),
      );
    }
  }

  // ── Category card ────────────────────────────────────────────────────────
  Widget _categoryCard(
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
          border:
              Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4)),
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
                color: count > 0
                    ? const Color(0xFF64748B)
                    : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────
  void _showAppointmentsList(
    String title,
    List<AppointmentDetail> appointments,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Sheet header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A))),
                              Text(
                                '${appointments.length} appointment${appointments.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B)),
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
                  itemBuilder: (_, i) =>
                      _appointmentCard(appointments[i], color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appointmentCard(AppointmentDetail appt, Color color) {
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                appt.doctor?.name.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.doctor?.name ?? 'Doctor',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM dd, yyyy').format(appt.date),
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time_rounded,
                        size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(appt.timeSlot,
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (appt.status == 'completed')
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileOrAppointmentViewScreen(appointment: appt),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Details',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
