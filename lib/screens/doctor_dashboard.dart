import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/utils/utils.dart';
import 'package:icare/screens/doctor_appointments.dart';
import 'package:icare/screens/profile_or_appointement_view.dart';
import 'package:icare/screens/doctor_profile_setup.dart';
import 'package:icare/screens/patient_records_list.dart';
import 'package:icare/screens/doctor_schedule_calendar.dart';
import 'package:icare/screens/doctor_availability.dart';
import 'package:icare/screens/courses.dart';
import 'package:icare/screens/my_learning.dart';
import 'package:icare/screens/clinical_audit_screen.dart';
import 'package:icare/screens/doctor_forum_screen.dart';
import 'package:icare/screens/credential_vault_screen.dart';
import 'package:icare/screens/subscription_chronic_care_screen.dart';
import 'package:easy_localization/easy_localization.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final appResult = await _appointmentService.getMyAppointmentsDetailed();
      final statsResult = await _doctorService.getStats();

      if (mounted) {
        setState(() {
          if (appResult['success']) {
            _appointments =
                appResult['appointments'] as List<AppointmentDetail>;
          }
          if (statsResult['success']) {
            _stats = statsResult['stats'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
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

  List<AppointmentDetail> get _pendingAppointments {
    return _appointments.where((a) => a.status == 'pending').toList();
  }

  int get _pendingCount =>
      _appointments.where((a) => a.status == 'pending').length;
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
                        // Welcome Header
                        _buildWelcomeHeader(userName),
                        const SizedBox(height: 24),

                        // Appointment Requests
                        _buildAppointmentRequests(),
                        const SizedBox(height: 24),

                        // Today's Appointments
                        _buildTodayAppointments(),
                        const SizedBox(height: 24),

                        // Statistics Cards
                        _buildStatisticsCards(isDesktop, isTablet),
                        const SizedBox(height: 24),

                        // Quick Actions
                        _buildQuickActions(isDesktop, isTablet),
                        const SizedBox(height: 24),

                        // Clinical & Professional Features
                        _buildFeatureGrid(isDesktop, isTablet),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    final avgRating = _stats['avgRating']?.toString() ?? '0.0';
    final satisfaction = _stats['satisfaction']?.toString() ?? '0%';

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
            child: const Icon(
              Icons.person,
              color: AppColors.primaryColor,
              size: 30,
            ),
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    avgRating,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.sentiment_very_satisfied_rounded, color: Color(0xFF8B5CF6), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    satisfaction,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(bool isDesktop, bool isTablet) {
    final consultations = _stats['totalConsultations'] ?? _completedCount;
    final avgRating = _stats['avgRating'] ?? '0.0';
    final satisfaction = _stats['satisfaction'] ?? '0%';

    if (isDesktop || isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Consultations',
              consultations,
              Icons.medical_services_rounded,
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Pending Requests',
              _pendingCount,
              Icons.pending_actions_rounded,
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'rating'.tr(),
              avgRating,
              Icons.star_rounded,
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'satisfaction'.tr(),
              satisfaction,
              Icons.sentiment_very_satisfied_rounded,
              const Color(0xFF8B5CF6),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Consultations',
                consultations,
                Icons.medical_services_rounded,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending Requests',
                _pendingCount,
                Icons.pending_actions_rounded,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'rating'.tr(),
                avgRating,
                Icons.star_rounded,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'satisfaction'.tr(),
                satisfaction,
                Icons.sentiment_very_satisfied_rounded,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
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

  Widget _buildTodayAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "today_appointments".tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
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
            : Column(
                children: _todayAppointments.take(3).map((appointment) {
                  return _buildTodayAppointmentCard(appointment);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTodayAppointmentCard(AppointmentDetail appointment) {
    final statusColor = _getStatusColor(appointment.status);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProfileOrAppointmentViewScreen(appointment: appointment),
          ),
        ).then((_) => _loadData());
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                appointment.patient?.name.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
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
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.timeSlot,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildAppointmentRequests() {
    final pending = _pendingAppointments;
    if (pending.isEmpty) {
      return const SizedBox(); // don't show the widget if no requests
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Appointment Requests",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            if (pending.length > 5)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const DoctorAppointmentsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('view_all'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: pending.take(5).map((appointment) {
            return _buildPendingAppointmentCard(appointment);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPendingAppointmentCard(AppointmentDetail appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFF59E0B).withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                appointment.patient?.name.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
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
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(appointment.date)} • ${appointment.timeSlot}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  final result = await AppointmentService().updateAppointmentStatus(
                    appointmentId: appointment.id,
                    status: 'confirmed',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['success'] == true ? 'Appointment accepted' : (result['message'] ?? 'Failed')),
                      backgroundColor: result['success'] == true ? const Color(0xFF10B981) : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ));
                    if (result['success'] == true) _loadData();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 20),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final result = await AppointmentService().updateAppointmentStatus(
                    appointmentId: appointment.id,
                    status: 'cancelled',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(result['success'] == true ? 'Appointment declined' : (result['message'] ?? 'Failed')),
                      backgroundColor: result['success'] == true ? const Color(0xFFEF4444) : Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ));
                    if (result['success'] == true) _loadData();
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
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
                      'appointments'.tr(),
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
                      'availability'.tr(),
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
                      'records'.tr(),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCardCompact(
                      'profile'.tr(),
                      Icons.person_rounded,
                      const Color(0xFF8B5CF6),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const DoctorProfileSetup(),
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
                  'appointments'.tr(),
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
                  'availability'.tr(),
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
                  'records'.tr(),
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
                _buildActionCardCompact(
                  'profile'.tr(),
                  Icons.person_rounded,
                  const Color(0xFF8B5CF6),
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const DoctorProfileSetup(),
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
              'clinical_audit'.tr(),
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
              'care_programs'.tr(),
              Icons.monitor_heart_rounded,
              const Color(0xFFEF4444),
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const SubscriptionChronicCareScreen(),
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
              'vault'.tr(),
              Icons.verified_user_rounded,
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
              'courses'.tr(),
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
