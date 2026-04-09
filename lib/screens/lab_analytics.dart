import 'package:flutter/material.dart';
import '../services/laboratory_service.dart';
import '../widgets/back_button.dart';

class LabAnalytics extends StatefulWidget {
  const LabAnalytics({super.key});

  @override
  State<LabAnalytics> createState() => _LabAnalyticsState();
}

class _LabAnalyticsState extends State<LabAnalytics>
    with TickerProviderStateMixin {
  final LaboratoryService _labService = LaboratoryService();
  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  String _selectedPeriod = 'This Month';
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _labService.getProfile();
      final bookings = await _labService.getBookings(profile['_id']);

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

      final filteredBookings = bookings.where((b) {
        final date = DateTime.parse(b['date']);
        return date.isAfter(startDate);
      }).toList();

      final testCounts = <String, int>{};
      for (var booking in filteredBookings) {
        final testName = booking['testName'] ?? 'Unknown';
        testCounts[testName] = (testCounts[testName] ?? 0) + 1;
      }

      final topTests = testCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final revenue = filteredBookings.fold<double>(0, (sum, b) {
        return sum + (b['price'] ?? 0).toDouble();
      });

      setState(() {
        _analytics = {
          'totalBookings': filteredBookings.length,
          'allTimeBookings': bookings.length,
          'completedBookings': filteredBookings
              .where((b) => b['status'] == 'completed')
              .length,
          'pendingBookings': filteredBookings
              .where((b) => b['status'] == 'pending')
              .length,
          'confirmedBookings': filteredBookings
              .where((b) => b['status'] == 'confirmed')
              .length,
          'cancelledBookings': filteredBookings
              .where((b) => b['status'] == 'cancelled')
              .length,
          'topTests': topTests.take(5),
          'revenue': revenue,
          'avgBookingsPerDay': filteredBookings.length / 30,
        };
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to load data. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Analytics & Insights',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPeriodSelector(),
                          const SizedBox(height: 24),
                          _buildOverviewCards(isDesktop),
                          const SizedBox(height: 24),
                          _buildRevenueCard(),
                          const SizedBox(height: 24),
                          _buildStatusBreakdown(),
                          const SizedBox(height: 24),
                          _buildTopTests(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'This Year'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _selectedPeriod = period);
                _loadAnalytics();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildOverviewCards(bool isDesktop) {
    // Premium unified gradient
    final gradient = LinearGradient(colors: [primaryColor, secondaryColor]);

    final cards = [
      {
        'title': 'Total Bookings',
        'value': _analytics?['totalBookings']?.toString() ?? '0',
        'icon': Icons.calendar_today_rounded,
        'gradient': gradient,
      },
      {
        'title': 'Completed',
        'value': _analytics?['completedBookings']?.toString() ?? '0',
        'icon': Icons.check_circle_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
      },
      {
        'title': 'Pending',
        'value': _analytics?['pendingBookings']?.toString() ?? '0',
        'icon': Icons.schedule_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
      },
      {
        'title': 'Confirmed',
        'value': _analytics?['confirmedBookings']?.toString() ?? '0',
        'icon': Icons.verified_rounded,
        'gradient': LinearGradient(colors: [accentColor, Color(0xFF0284C7)]),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktop) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildStatCard(card),
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard(cards[0])),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(cards[1])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(cards[2])),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(cards[3])),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: card['gradient'] as LinearGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              card['icon'] as IconData,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card['value'] as String,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card['title'] as String,
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

  Widget _buildRevenueCard() {
    final revenue = _analytics?['revenue'] ?? 0;
    final avgPerDay = _analytics?['avgBookingsPerDay'] ?? 0;

    return Container(
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
            color: primaryColor.withValues(alpha: 0.3),
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
                Text(
                  'Estimated Revenue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PKR ${revenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${avgPerDay.toStringAsFixed(1)} bookings/day avg',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Status Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildStatusRow(
            'Completed',
            _analytics?['completedBookings'] ?? 0,
            _analytics?['totalBookings'] ?? 1,
            const Color(0xFF10B981),
            Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Confirmed',
            _analytics?['confirmedBookings'] ?? 0,
            _analytics?['totalBookings'] ?? 1,
            accentColor,
            Icons.verified_rounded,
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Pending',
            _analytics?['pendingBookings'] ?? 0,
            _analytics?['totalBookings'] ?? 1,
            const Color(0xFFF59E0B),
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            'Cancelled',
            _analytics?['cancelledBookings'] ?? 0,
            _analytics?['totalBookings'] ?? 1,
            const Color(0xFFEF4444),
            Icons.cancel_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(1)
        : '0.0';
    final progress = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count ($percentage%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopTests() {
    final topTests = _analytics?['topTests'] as Iterable? ?? [];

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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Most Requested Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (topTests.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No test data available',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...topTests.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? primaryColor
                            : primaryColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        test.key,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${test.value}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
