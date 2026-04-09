import 'package:flutter/material.dart';
import 'package:icare/services/clinical_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class LifestyleTrackerScreen extends StatefulWidget {
  const LifestyleTrackerScreen({super.key});

  @override
  State<LifestyleTrackerScreen> createState() => _LifestyleTrackerScreenState();
}

class _LifestyleTrackerScreenState extends State<LifestyleTrackerScreen> {
  final ClinicalService _clinicalService = ClinicalService();
  bool _isLoading = true;
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _clinicalService.getLifestyleSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Unable to load data. Please try again.')));
      }
    }
  }

  Future<void> _logActivity(String type, String value) async {
    try {
      await _clinicalService.logLifestyleActivity({
        'type': type,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _loadSummary(); // Refresh
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Something went wrong. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Lifestyle Tracker',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailySummary(),
                  const SizedBox(height: 32),
                  _buildTrackerGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Recent Logs'),
                  const SizedBox(height: 16),
                  _buildRecentLogs(),
                ],
              ),
            ),
    );
  }

  Widget _buildDailySummary() {
    final progress = (_summary['overallProgress'] ?? 0.0) as double;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DAILY PROGRESS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great Job!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You have completed ${(progress * 100).toInt()}% of your goals today.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerGrid() {
    final metrics = _summary['metrics'] ?? {};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildTrackerCard(
          'Water Intake',
          metrics['water'] ?? '0 / 2.5 L',
          Icons.water_drop_rounded,
          Colors.blue,
          'water',
        ),
        _buildTrackerCard(
          'Steps',
          metrics['steps'] ?? '0 / 10k',
          Icons.directions_walk_rounded,
          Colors.orange,
          'steps',
        ),
        _buildTrackerCard(
          'Sleep',
          metrics['sleep'] ?? '0 / 8 h',
          Icons.bedtime_rounded,
          Colors.purple,
          'sleep',
        ),
        _buildTrackerCard(
          'Calories',
          metrics['calories'] ?? '0 / 2k',
          Icons.local_fire_department_rounded,
          Colors.red,
          'calories',
        ),
      ],
    );
  }

  Widget _buildTrackerCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String type,
  ) {
    return InkWell(
      onTap: () => _showLogDialog(title, type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDialog(String title, String type) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter value'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _logActivity(type, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildRecentLogs() {
    final logs = (_summary['recentLogs'] ?? []) as List<dynamic>;
    if (logs.isEmpty) return const Center(child: Text('No logs yet.'));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  log['message'] ?? 'Logged Activity',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Text(
                log['timeAgo'] ?? '',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
