import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/connect_now_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/screens/doctor_connect_now_screen.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/doctor_schedule_calendar.dart';
import 'package:icare/screens/doctor_analytics.dart';
import 'package:icare/screens/doctor_notifications.dart';
import 'package:icare/screens/doctor_reviews.dart';
import 'package:icare/screens/doctor_availability.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/my_learning.dart';
import 'package:icare/screens/clinical_audit_screen.dart';
import 'package:icare/screens/soap_notes_screen.dart';
import 'package:icare/screens/doctor_forum_screen.dart';
import 'package:icare/screens/credential_vault_screen.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboard extends ConsumerStatefulWidget {
  const DoctorDashboard({super.key});

  @override
  ConsumerState<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends ConsumerState<DoctorDashboard> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  List<AppointmentDetail> _appointments = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _availableForInstantConsultation = true; // default ON — doctor receives requests when online
  bool _isInConsultation = false; // true when doctor is in active video call

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadInstantConsultToggle();
    // Mark doctor as online when dashboard is active
    _doctorService.setOnlineStatus(true);
  }

  @override
  void dispose() {
    // Mark doctor as offline when leaving dashboard
    _doctorService.setOnlineStatus(false);
    super.dispose();
  }

  Future<void> _loadInstantConsultToggle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool('doctor_instant_consult_available') ?? true;
      if (mounted) setState(() => _availableForInstantConsultation = val);
      // Sync with backend on load so backend knows current state
      ConnectNowService().setInstantAvailability(val);
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _appointmentService.getMyAppointmentsDetailed(),
        _doctorService.getStats().catchError((_) => <String, dynamic>{'success': false, 'stats': {}}),
      ]);

      if (mounted) {
        setState(() {
          final appResult = results[0];
          final statsResult = results[1];
          if (appResult['success'] == true) {
            _appointments = appResult['appointments'] as List<AppointmentDetail>;
          }
          if (statsResult['success'] == true) {
            _stats = statsResult['stats'] ?? {};
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ _loadData error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAppointments() async {
    _loadData();
  }

  List<AppointmentDetail> get _todayAppointments {
    final today = DateTime.now();
    return _appointments.where((a) {
      return a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day;
    }).toList();
  }

  int get _pendingCount =>
      _appointments.where((a) => a.status == 'pending').length;
  int get _confirmedCount =>
      _appointments.where((a) => a.status == 'confirmed').length;
  int get _completedCount =>
      _appointments.where((a) => a.status == 'completed').length;

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(authProvider).user?.name ?? 'Doctor';
    final width = Utils.windowWidth(context);
    final bool isDesktop = width > 900;
    final bool isTablet = width > 600 && width <= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'doctor_workspace'.tr(),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF0F172A)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const DoctorProfileSetup()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isDesktop ? 32 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Welcome Header with rating + satisfaction
                        _buildWelcomeHeader(userName),
                        const SizedBox(height: 16),

                        // 1b. Instant Consultation Toggle
                        _buildInstantConsultToggle(),
                        const SizedBox(height: 24),

                        // 2. Appointment Requests (pending — Accept/Decline)
                        _buildAppointmentRequests(),
                        const SizedBox(height: 24),

                        // 3. Today's Appointments
                        _buildTodayAppointments(),
                        const SizedBox(height: 24),

                        // 4. Earnings Display
                        _buildEarningsCard(),
                        const SizedBox(height: 24),

                        // 5. Consultations Count Card
                        _buildConsultationsCard(),
                        const SizedBox(height: 24),

                        // 6. Clinical Flags (SOAP notes alerts)
                        _buildClinicalFlags(),
                        const SizedBox(height: 24),

                        // 6. Clinical & Professional Features
                        _buildFeatureGrid(isDesktop, isTablet),
                        // Quick Actions intentionally removed per meeting notes
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInstantConsultToggle() {
    return GestureDetector(
      onTap: () {
        if (_isInConsultation) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot change availability during an active consultation'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        setState(() => _availableForInstantConsultation = !_availableForInstantConsultation);
        // Persist toggle state
        _saveInstantConsultToggle(_availableForInstantConsultation);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: _availableForInstantConsultation
              ? const LinearGradient(
                  colors: [Color(0xFF0036BC), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _availableForInstantConsultation ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _availableForInstantConsultation
                ? const Color(0xFF0036BC)
                : const Color(0xFFE2E8F0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (_availableForInstantConsultation
                      ? const Color(0xFF0036BC)
                      : Colors.black)
                  .withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _availableForInstantConsultation
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF0036BC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.video_call_rounded,
                color: _availableForInstantConsultation
                    ? Colors.white
                    : const Color(0xFF0036BC),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available for Instant Consultation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _availableForInstantConsultation
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _availableForInstantConsultation
                        ? 'Patients can connect with you instantly'
                        : 'Toggle ON to receive instant consultation requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: _availableForInstantConsultation
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _availableForInstantConsultation,
              onChanged: _isInConsultation
                  ? null
                  : (val) {
                      setState(() => _availableForInstantConsultation = val);
                      _saveInstantConsultToggle(val);
                    },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
              inactiveThumbColor: const Color(0xFF0036BC),
              inactiveTrackColor:
                  const Color(0xFF0036BC).withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInstantConsultToggle(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('doctor_instant_consult_available', value);
    } catch (_) {}
    // Notify backend so it routes requests correctly
    ConnectNowService().setInstantAvailability(value);
  }

  Widget _buildWelcomeHeader(String userName) {
    final avgRating = _stats['avgRating'] ?? '0.0';
    final satisfaction = _stats['satisfaction'] ?? '0%';
    final profilePic = ref.watch(authProvider).user?.profilePicture;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                ? NetworkImage(profilePic) as ImageProvider
                : null,
            child: (profilePic == null || profilePic.isEmpty)
                ? const Icon(Icons.person, color: AppColors.primaryColor, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Dr. $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            avgRating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sentiment_very_satisfied_rounded, color: Color(0xFF8B5CF6), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            satisfaction.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B21A8),
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
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(bool isDesktop, bool isTablet) {
    final totalConsultations = _stats['totalPatients'] ?? _completedCount;
    final avgRating = _stats['avgRating'] ?? '0.0';
    final satisfaction = _stats['satisfaction'] ?? '0%';

    final cards = [
      _buildStatCard(
        'Consultations',
        totalConsultations,
        Icons.medical_services_rounded,
        const Color(0xFF3B82F6),
      ),
      _buildStatCard(
        'Pending',
        _pendingCount,
        Icons.pending_actions_rounded,
        const Color(0xFFF59E0B),
      ),
      _buildStatCard(
        'rating'.tr(),
        avgRating,
        Icons.star_rounded,
        const Color(0xFFF59E0B),
      ),
      _buildStatCard(
        'satisfaction'.tr(),
        satisfaction,
        Icons.sentiment_very_satisfied_rounded,
        const Color(0xFF8B5CF6),
      ),
    ];

    if (isDesktop || isTablet) {
      return Row(
        children: cards
            .map((c) => Expanded(child: c))
            .expand((w) => [w, const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: cards[2]),
          const SizedBox(width: 12),
          Expanded(child: cards[3]),
        ]),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    dynamic count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final result = await _appointmentService.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
      );
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(status == 'confirmed' ? 'Appointment accepted.' : 'Appointment declined.'),
            backgroundColor: status == 'confirmed' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ));
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message'] ?? 'Failed to update appointment.'),
            backgroundColor: const Color(0xFFEF4444),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Color(0xFFEF4444),
        ));
      }
    }
  }

  Widget _buildAppointmentRequests() {
    final pendingAppointments = _appointments
        .where((a) => a.status == 'pending')
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Appointment Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_pendingCount > 0) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'New ${_pendingCount.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_pendingCount > 5)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const DoctorAppointmentsScreen(),
                  ));
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingAppointments.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'No pending appointment requests.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ),
          )
        else
          ...pendingAppointments.map((appt) => _buildRequestCard(appt)),
      ],
    );
  }

  Widget _buildRequestCard(AppointmentDetail appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Text(
              appointment.patient?.name.substring(0, 1).toUpperCase() ?? 'P',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patient?.name ?? 'Patient',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${appointment.timeSlot}  •  ${DateFormat('dd MMM').format(appointment.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          // Reject button
          GestureDetector(
            onTap: () => _updateAppointmentStatus(appointment.id, 'cancelled'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Accept button
          GestureDetector(
            onTap: () => _updateAppointmentStatus(appointment.id, 'confirmed'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Accept',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "today_appointments".tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _todayAppointments.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'no_appointments'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: _todayAppointments.take(6).map((appointment) {
                  return _buildTodayAppointmentCard(appointment);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTodayAppointmentCard(AppointmentDetail appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final initials = (appointment.patient?.name ?? 'P')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProfileOrAppointmentViewScreen(appointment: appointment),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time chip at top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 11, color: statusColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      appointment.timeSlot,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Avatar
            Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'P' : initials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Patient name
            Text(
              appointment.patient?.name ?? 'Patient',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
            ),
              child: Text(
                appointment.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    // Mock data - backend se aayega
    final previousMonthEarnings = _stats['previousMonthEarnings'] ?? 45000;
    final totalNetEarnings = _stats['totalNetEarnings'] ?? 180000;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Earnings Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PKR ${previousMonthEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Net Earnings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PKR ${totalNetEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsCard() {
    final totalConsultations = _stats['totalPatients'] ?? _completedCount;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF3B82F6),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalConsultations.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  'Total Consultations',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalFlags() {
    // Completed appointments that likely need SOAP notes
    final flagged = _appointments
        .where((a) => a.status == 'completed')
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Clinical Flags',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 10),
            if (flagged.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${flagged.length} pending',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: flagged.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'All SOAP notes are up to date.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFDC2626), size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'These appointments are missing SOAP notes. Tap to complete.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...flagged.asMap().entries.map((entry) {
                      final i = entry.key;
                      final appt = entry.value;
                      return Column(
                        children: [
                          if (i > 0)
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => SoapNotesScreen(
                                    appointment: appt,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.assignment_late_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'This appointment with ${appt.patient?.name ?? 'Patient'}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '#${appt.id.length > 8 ? appt.id.substring(appt.id.length - 8).toUpperCase() : appt.id.toUpperCase()}  ·  ${DateFormat('dd MMM yyyy, hh:mm a').format(appt.date)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            if (isDesktop || isTablet) {
              return Row(
                children: [
                  Expanded(
                    child: _buildActionCardCompact(
                      'Appointments',
                      Icons.calendar_month_rounded,
                      const Color(0xFF3B82F6),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const DoctorAppointmentsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCardCompact(
                      'Availability',
                      Icons.schedule_rounded,
                      const Color(0xFF10B981),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const DoctorScheduleCalendar(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCardCompact(
                      'Records',
                      Icons.folder_rounded,
                      const Color(0xFFF59E0B),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const PatientRecordsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            int crossAxisCount = 2;
            double aspectRatio = 2.2;

            if (isDesktop) {
              crossAxisCount = 5;
              aspectRatio = 1.3;
            } else if (isTablet) {
              crossAxisCount = 3;
              aspectRatio = 1.5;
            } else {
              crossAxisCount = MediaQuery.of(context).size.width < 360 ? 2 : 3;
              aspectRatio = 0.95;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: aspectRatio,
              children: [
                _buildActionCardCompact(
                  'Appointments',
                  Icons.calendar_month_rounded,
                  const Color(0xFF3B82F6),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const DoctorAppointmentsScreen(),
                      ),
                    );
                  },
                ),
                _buildActionCardCompact(
                  'Availability',
                  Icons.schedule_rounded,
                  const Color(0xFF10B981),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const DoctorScheduleCalendar(),
                      ),
                    );
                  },
                ),
                _buildActionCardCompact(
                  'Records',
                  Icons.folder_rounded,
                  const Color(0xFFF59E0B),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const PatientRecordsListScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCardCompact(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column( // Use column for 3-col layout
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildFeatureGrid(bool isDesktop, bool isTablet) {
    final gridCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final clinicalRatio = isDesktop ? 2.0 : (isTablet ? 1.6 : 1.3);
    final profRatio = isDesktop ? 2.4 : (isTablet ? 2.0 : 1.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'clinical_management'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: clinicalRatio,
          children: [
            _buildFeatureCard(
              'Quality Score',
              Icons.rule_folder_rounded,
              const Color(0xFF0F172A),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const ClinicalAuditScreen(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              'forum'.tr(),
              Icons.groups_rounded,
              const Color(0xFF8B5CF6),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const DoctorForumScreen(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              'Certificate',
              Icons.workspace_premium_rounded,
              const Color(0xFF10B981),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const CredentialVaultScreen(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              'availability'.tr(),
              Icons.event_available_rounded,
              const Color(0xFF64748B),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const DoctorAvailability(),
                  ),
                );
              },
            ),
            _buildFeatureCard(
              'Revenue & Analytics',
              Icons.bar_chart_rounded,
              const Color(0xFF10B981),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const DoctorAnalytics(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'professional_development'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: gridCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: profRatio,
          children: [
            _buildFeatureCard(
              'Courses',
              Icons.school_rounded,
              const Color(0xFF8B5CF6),
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (ctx) => const Courses()));
              },
            ),
            _buildFeatureCard(
              'my_learning'.tr(),
              Icons.bookmark_added_rounded,
              const Color(0xFF10B981),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const MyLearningScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
