import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/doctor_service.dart';
import 'package:icare/screens/doctor_reviews.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class DoctorAnalytics extends ConsumerStatefulWidget {
  const DoctorAnalytics({super.key});

  @override
  ConsumerState<DoctorAnalytics> createState() => _DoctorAnalyticsState();
}

class _DoctorAnalyticsState extends ConsumerState<DoctorAnalytics> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();

  List<AppointmentDetail> _appointments = [];
  List<Map<String, dynamic>> _patientReviews = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Each call is independent — one failure won't block the others
      final results = await Future.wait([
        _appointmentService.getMyAppointmentsDetailed()
            .catchError((_) => <String, dynamic>{'success': false}),
        _doctorService.getStats()
            .catchError((_) => <String, dynamic>{'success': false, 'stats': {}}),
        _doctorService.getMyPatientReviews()
            .catchError((_) => <String, dynamic>{'success': false, 'reviews': []}),
      ]);

      if (!mounted) return;

      setState(() {
        final appointmentsResult = results[0];
        final statsResult       = results[1];
        final reviewsResult     = results[2];

        if (appointmentsResult['success'] == true) {
          _appointments = appointmentsResult['appointments'] as List<AppointmentDetail>;
        }
        if (statsResult['success'] == true) {
          _stats = statsResult['stats'] ?? {};
        }
        _patientReviews = reviewsResult['success'] == true
            ? List<Map<String, dynamic>>.from(reviewsResult['reviews'] ?? [])
            : [];

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Returns [start, endExclusive] as a 2-element list (avoids Dart record syntax for web compat).
  List<DateTime> _rangeBounds() {
    final now = DateTime.now();
    if (_customRange != null) {
      final s = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
      final e = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day);
      return [s, e.add(const Duration(days: 1))];
    }
    switch (_selectedPeriod) {
      case 'This Week':
        final wd = now.weekday;
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: wd - 1));
        return [start, start.add(const Duration(days: 7))];
      case 'This Year':
        final s = DateTime(now.year, 1, 1);
        return [s, DateTime(now.year + 1, 1, 1)];
      case 'This Month':
      default:
        final s = DateTime(now.year, now.month, 1);
        return [s, DateTime(now.year, now.month + 1, 1)];
    }
  }

  bool _dateInRange(DateTime d, DateTime start, DateTime endEx) {
    final day = DateTime(d.year, d.month, d.day);
    return !day.isBefore(start) && day.isBefore(endEx);
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initial = _customRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initial,
      helpText: 'Select date range',
    );
    if (picked != null && mounted) {
      setState(() {
        _customRange = picked;
        _selectedPeriod = 'Custom';
      });
    }
  }

  Map<String, dynamic> get _statistics {
    final bounds = _rangeBounds();
    final start = bounds[0];
    final endEx = bounds[1];
    final filtered = _appointments.where((a) => _dateInRange(a.date, start, endEx)).toList();

    final fee = (_stats['consultationFee'] is num)
        ? (_stats['consultationFee'] as num).toDouble()
        : double.tryParse('${_stats['consultationFee'] ?? 0}') ?? 0.0;

    final completedInPeriod = filtered.where((a) => a.status == 'completed').length;
    final periodRevenue = completedInPeriod * fee;

    final now = DateTime.now();
    final lmStart = DateTime(now.year, now.month - 1, 1);
    final lmEnd = DateTime(now.year, now.month, 1);
    final lastMonthCompleted = _appointments
        .where((a) =>
            a.status == 'completed' &&
            !a.date.isBefore(lmStart) &&
            a.date.isBefore(lmEnd))
        .length;
    final lastMonthRevenue = lastMonthCompleted * fee;

    final uniqueInPeriod = filtered
        .map((a) => a.patient?.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    final daysInRange = endEx.difference(start).inDays.clamp(1, 3650);

    return {
      'total': filtered.length,
      'completed': filtered.where((a) => a.status == 'completed').length,
      'missed': filtered.where((a) => a.status.toLowerCase() == 'missed').length,
      'cancelled': filtered.where((a) => a.status == 'cancelled').length,
      'pending': filtered.where((a) => a.status == 'pending').length,
      'periodRevenue': periodRevenue,
      'lastMonthRevenue': lastMonthRevenue,
      'allTimeRevenue': _stats['revenue'] ?? 0,
      'uniquePatientsInPeriod': uniqueInPeriod,
      'daysInRange': daysInRange,
      'satisfaction': _stats['satisfaction'] ?? '0%',
      'avgRating': _stats['avgRating'] ?? _stats['rating'] ?? '0.0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Revenue & Analytics',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDesktop),
    );
  }

  Widget _buildBody(bool isDesktop) {
    // Compute stats safely — if _statistics throws, show error instead of crashing
    Map<String, dynamic> stats;
    try {
      stats = _statistics;
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            const Text('Could not compute analytics.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 24),
              _buildRevenueAnalytics(stats),
              const SizedBox(height: 24),
              _buildOverviewCards(stats, isDesktop),
              const SizedBox(height: 16),
              _buildReviewsPreview(),
              const SizedBox(height: 24),
              _buildPerformanceMetrics(stats),
              const SizedBox(height: 24),
              _buildAppointmentBreakdown(stats),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueAnalytics(Map<String, dynamic> stats) {
    final num lastMonth = stats['lastMonthRevenue'] ?? 0;
    final num period = stats['periodRevenue'] ?? 0;
    final num allTime = stats['allTimeRevenue'] ?? 0;

    String fmt(num v) => 'PKR ${v.toStringAsFixed(0)}';

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Revenue & Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRevenueCard(
                  'Last month',
                  fmt(lastMonth),
                  Icons.calendar_today_rounded,
                  const Color(0xFF8B5CF6),
                  'Completed consultations (previous calendar month)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueCard(
                  'Selected period',
                  fmt(period),
                  Icons.event_note_rounded,
                  const Color(0xFF10B981),
                  'Completed consultations in the current filter / range',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRevenueCard(
            'All-time total',
            fmt(allTime),
            Icons.savings_rounded,
            const Color(0xFF3B82F6),
            'All completed consultations to date',
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(
    String label,
    String amount,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a human-readable date range label for the current selection.
  String _rangeLabel() {
    final bounds = _rangeBounds();
    final start = bounds[0];
    final endEx = bounds[1];
    final end = endEx.subtract(const Duration(days: 1));
    final fmt = DateFormat('d MMM yyyy');
    if (_selectedPeriod == 'Custom' && _customRange != null) {
      return '${fmt.format(start)} – ${fmt.format(end)}';
    }
    if (_selectedPeriod == 'This Week') {
      return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)}';
    }
    if (_selectedPeriod == 'This Month') {
      return DateFormat('MMMM yyyy').format(start);
    }
    if (_selectedPeriod == 'This Year') {
      return '${start.year}';
    }
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'This Year'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
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
                    final isSelected = _selectedPeriod == period;
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                            _customRange = null;
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
              ),
            ),
            const SizedBox(width: 8),
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickCustomRange,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        color: _selectedPeriod == 'Custom'
                            ? AppColors.primaryColor
                            : const Color(0xFF64748B),
                      ),
                      if (_selectedPeriod == 'Custom') ...[
                        const SizedBox(width: 4),
                        const Text('Custom', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryColor)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Date range label
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF94A3B8)),
            const SizedBox(width: 5),
            Text(
              _rangeLabel(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> stats, bool isDesktop) {
    final reviewCount = _patientReviews.length;

    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Appointments', stats['total'] ?? 0, Icons.calendar_month_rounded, const Color(0xFF3B82F6))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Completed', stats['completed'] ?? 0, Icons.check_circle_rounded, const Color(0xFF10B981))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Missed', stats['missed'] ?? 0, Icons.warning_rounded, const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Reviews', reviewCount, Icons.rate_review_rounded, const Color(0xFF8B5CF6),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorReviews())))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Patient Satisfaction', stats['satisfaction'] ?? '0%', Icons.sentiment_very_satisfied_rounded, const Color(0xFF6366F1))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Avg. Rating', stats['avgRating'] ?? '0.0', Icons.star_rounded, const Color(0xFFF59E0B))),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', stats['total'] ?? 0, Icons.calendar_month_rounded, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Completed', stats['completed'] ?? 0, Icons.check_circle_rounded, const Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Missed', stats['missed'] ?? 0, Icons.warning_rounded, const Color(0xFF64748B))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Reviews', reviewCount, Icons.rate_review_rounded, const Color(0xFF8B5CF6),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DoctorReviews())))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Satisfaction', stats['satisfaction'] ?? '0%', Icons.sentiment_very_satisfied_rounded, const Color(0xFF6366F1))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Avg. Rating', stats['avgRating'] ?? '0.0', Icons.star_rounded, const Color(0xFFF59E0B))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    dynamic count,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    final inner = Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (onTap != null) ...[
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.6)),
              ],
            ],
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

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: inner,
        ),
      );
    }
    return inner;
  }

  Widget _buildReviewsPreview() {
    if (_patientReviews.isEmpty) {
      return const SizedBox.shrink();
    }
    final preview = _patientReviews.take(3).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
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
              const Text(
                'Recent patient reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DoctorReviews()),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...preview.map(_buildReviewPreviewTile),
        ],
      ),
    );
  }

  Widget _buildReviewPreviewTile(Map<String, dynamic> r) {
    final name = r['patientName']?.toString() ?? 'Patient';
    final stars = r['rating'];
    final comment = r['comment']?.toString() ?? '';
    DateTime? at;
    final raw = r['ratedAt'];
    if (raw is String) at = DateTime.tryParse(raw);
    final dateStr = at != null ? '${at.day}/${at.month}/${at.year}' : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                if (comment.isNotEmpty)
                  Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$stars★',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(Map<String, dynamic> stats) {
    final int total     = (stats['total']     as int?) ?? 0;
    final int completed = (stats['completed'] as int?) ?? 0;
    final int cancelled = (stats['cancelled'] as int?) ?? 0;
    final int missed    = (stats['missed']    as int?) ?? 0;

    final double completionValue = total > 0 ? (completed / total) * 100 : 0.0;
    final double cancellationValue = total > 0 ? (cancelled / total) * 100 : 0.0;
    final double missedValue = total > 0 ? (missed / total) * 100 : 0.0;

    final String completionRate = completionValue.toStringAsFixed(1);
    final String cancellationRate = cancellationValue.toStringAsFixed(1);
    final String missedRate = missedValue.toStringAsFixed(1);

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
          _buildMetricRow('Completion Rate', completionRate, const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildMetricRow('Cancellation Rate', cancellationRate, const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          _buildMetricRow('Missed Rate', missedRate, const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color color, {
    bool usePercentSuffix = true,
  }) {
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
            usePercentSuffix ? '$value%' : value,
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
          _buildBreakdownItem('Completed', (stats['completed'] as int?) ?? 0, const Color(0xFF10B981)),
          _buildBreakdownItem('Pending',   (stats['pending']   as int?) ?? 0, const Color(0xFFF59E0B)),
          _buildBreakdownItem('Cancelled', (stats['cancelled'] as int?) ?? 0, const Color(0xFFEF4444)),
          _buildBreakdownItem('Missed',    (stats['missed']    as int?) ?? 0, const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, Color color) {
    final total = (_statistics['total'] as int?) ?? 0;
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
            'Health Program Compliance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSmallStat(
                  'Assigned',
                  '12',
                  Icons.assignment_turned_in_rounded,
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallStat(
                  'Avg. Progress',
                  '65%',
                  Icons.trending_up_rounded,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Top Active Programs',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _buildProgramMiniCard('Diabetes Management', 0.85, '8 Patients'),
          _buildProgramMiniCard('Hypertension Control', 0.45, '4 Patients'),
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
