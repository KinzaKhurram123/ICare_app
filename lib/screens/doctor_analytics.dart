import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class DoctorAnalytics extends ConsumerStatefulWidget {
  const DoctorAnalytics({super.key});

  @override
  ConsumerState<DoctorAnalytics> createState() => _DoctorAnalyticsState();
}

class _DoctorAnalyticsState extends ConsumerState<DoctorAnalytics> {
  final AppointmentService _appointmentService = AppointmentService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  final DoctorService _doctorService = DoctorService();

  List<AppointmentDetail> _appointments = [];
  List<dynamic> _medicalRecords = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final appointmentsResult = await _appointmentService
          .getMyAppointmentsDetailed();
      final recordsResult = await _medicalRecordService.getDoctorRecords();
      final statsResult = await _doctorService.getStats();

      if (mounted) {
        setState(() {
          if (appointmentsResult['success']) {
            _appointments =
                appointmentsResult['appointments'] as List<AppointmentDetail>;
          }
          if (recordsResult['success']) {
            _medicalRecords = recordsResult['records'] as List<dynamic>;
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

  Map<String, dynamic> get _statistics {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final filteredAppointments = _appointments
        .where((a) => a.date.isAfter(startDate))
        .toList();
    final filteredRecords = _medicalRecords.where((r) {
      final date = DateTime.parse(r['createdAt']);
      return date.isAfter(startDate);
    }).toList();

    return {
      'total': filteredAppointments.length,
      'completed': filteredAppointments
          .where((a) => a.status == 'completed')
          .length,
      'cancelled': filteredAppointments
          .where((a) => a.status == 'cancelled')
          .length,
      'pending': filteredAppointments
          .where((a) => a.status == 'pending')
          .length,
      'records': filteredRecords.length,
      'patients':
          _stats['totalPatients'] ??
          filteredAppointments.map((a) => a.patient?.id).toSet().length,
      'revenue': _stats['revenue'] ?? 0,
      'satisfaction': _stats['satisfaction'] ?? '0%',
      'avgRating': _stats['avgRating'] ?? '0.0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final stats = _statistics;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Analytics & Reports',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 40 : 20),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1200 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 24),
                      _buildOverviewCards(stats, isDesktop),
                      const SizedBox(height: 24),
                      _buildPerformanceMetrics(stats),
                      const SizedBox(height: 24),
                      _buildAppointmentBreakdown(stats),
                      const SizedBox(height: 24),
                      _buildHealthProgramAnalytics(stats),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'This Year'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Appointments',
                      stats['total']!,
                      Icons.calendar_month_rounded,
                      const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      stats['completed']!,
                      Icons.check_circle_rounded,
                      const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Medical Records',
                      stats['records']!,
                      Icons.folder_rounded,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Unique Patients',
                      stats['patients']!,
                      Icons.people_rounded,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      'PKR ${stats['revenue']}',
                      Icons.payments_rounded,
                      const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Patient Satisfaction',
                      stats['satisfaction'],
                      Icons.sentiment_very_satisfied_rounded,
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Avg. Rating',
                      stats['avgRating'],
                      Icons.star_rounded,
                      const Color(0xFFF59E0B),
                    ),
                  ),
                ],
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
                    'Total',
                    stats['total']!,
                    Icons.calendar_month_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    stats['completed']!,
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Revenue',
                    'PKR ${stats['revenue']}',
                    Icons.payments_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Rating',
                    stats['avgRating'],
                    Icons.star_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    dynamic count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> stats) {
    final int total = stats['total'] ?? 0;
    final int completed = stats['completed'] ?? 0;
    final int cancelled = stats['cancelled'] ?? 0;
    final int patients = stats['patients'] ?? 0;

    final double completionValue = total > 0 ? (completed / total) * 100 : 0.0;
    final double cancellationValue = total > 0
        ? (cancelled / total) * 100
        : 0.0;
    final double avgPatientsValue = patients / 30;

    final String completionRate = completionValue.toStringAsFixed(1);
    final String cancellationRate = cancellationValue.toStringAsFixed(1);
    final String avgPatients = avgPatientsValue.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            'Completion Rate',
            completionRate,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Cancellation Rate',
            cancellationRate,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Average Patients/Day',
            avgPatients,
            const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentBreakdown(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildBreakdownItem(
            'Completed',
            stats['completed'] as int,
            const Color(0xFF10B981),
          ),
          _buildBreakdownItem(
            'Pending',
            stats['pending'] as int,
            const Color(0xFFF59E0B),
          ),
          _buildBreakdownItem(
            'Cancelled',
            stats['cancelled'] as int,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, Color color) {
    final total = _statistics['total'] as int;
    final percentage = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProgramAnalytics(Map<String, dynamic> stats) {
    // Count unique patients who have appointments
    final uniquePatients = _appointments.map((a) => a.patient?.id).toSet().length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSmallStat('Unique Patients', '$uniquePatients',
                  Icons.people_rounded, const Color(0xFF6366F1))),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallStat('Medical Records', '${_medicalRecords.length}',
                  Icons.folder_rounded, const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Appointment Status Breakdown',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          _buildProgramMiniCard('Completed', stats['completed'] / (stats['total'] > 0 ? stats['total'] : 1),
              '${stats['completed']} appointments'),
          _buildProgramMiniCard('Pending', stats['pending'] / (stats['total'] > 0 ? stats['total'] : 1),
              '${stats['pending']} appointments'),
        ],
      ),
    );
  }

  Widget _buildSmallStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramMiniCard(
    String title,
    double progress,
    String patientCount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                patientCount,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
