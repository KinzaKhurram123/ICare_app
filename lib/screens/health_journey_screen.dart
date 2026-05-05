import 'package:flutter/material.dart';
import 'package:icare/services/health_tracker_service.dart';
import 'package:icare/services/health_settings_service.dart';
import 'package:icare/models/health_tracker_entry.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/utils/theme.dart';
import 'package:intl/intl.dart';

class HealthJourneyScreen extends StatefulWidget {
  const HealthJourneyScreen({super.key});

  @override
  State<HealthJourneyScreen> createState() => _HealthJourneyScreenState();
}

class _HealthJourneyScreenState extends State<HealthJourneyScreen> {
  final HealthTrackerService _trackerService = HealthTrackerService();
  final HealthSettingsService _settingsService = HealthSettingsService();

  bool _isLoading = true;
  bool _healthModeEnabled = false;
  List<String> _selectedConditions = [];
  List<Map<String, dynamic>> _vitalData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    try {
      final result = await _trackerService.getDashboard();

      if (result['success'] && mounted) {
        setState(() {
          _healthModeEnabled = result['healthModeEnabled'] ?? false;
          _selectedConditions = List<String>.from(result['selectedConditions'] ?? []);
          _vitalData = List<Map<String, dynamic>>.from(result['vitals'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _getVitalConfig(String vitalKey) {
    final configs = {
      'bloodPressure': {
        'name': 'Blood Pressure',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFEF4444),
        'unit': 'mmHg',
      },
      'bloodSugar': {
        'name': 'Blood Glucose',
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF8B5CF6),
        'unit': 'mg/dL',
      },
      'weight': {
        'name': 'Weight',
        'icon': Icons.monitor_weight_rounded,
        'color': const Color(0xFF3B82F6),
        'unit': 'kg',
      },
      'water': {
        'name': 'Water Intake',
        'icon': Icons.local_drink_rounded,
        'color': const Color(0xFF14B8A6),
        'unit': 'glasses',
      },
      'medication': {
        'name': 'Medication',
        'icon': Icons.medication_rounded,
        'color': const Color(0xFFF43F5E),
        'unit': '%',
      },
      'steps': {
        'name': 'Steps',
        'icon': Icons.directions_walk_rounded,
        'color': const Color(0xFF06B6D4),
        'unit': 'steps',
      },
      'sleep': {
        'name': 'Sleep',
        'icon': Icons.bedtime_rounded,
        'color': const Color(0xFF6366F1),
        'unit': 'hours',
      },
      'heartRate': {
        'name': 'Heart Rate',
        'icon': Icons.monitor_heart_rounded,
        'color': const Color(0xFFEC4899),
        'unit': 'bpm',
      },
      'temperature': {
        'name': 'Temperature',
        'icon': Icons.thermostat_rounded,
        'color': const Color(0xFFF59E0B),
        'unit': '°C',
      },
      'oxygenLevel': {
        'name': 'Oxygen Level',
        'icon': Icons.air_rounded,
        'color': const Color(0xFF10B981),
        'unit': '%',
      },
    };
    return configs[vitalKey] ?? {};
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
          'My Health Journey',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHealthModeCard(),
                        const SizedBox(height: 24),
                        if (_vitalData.isEmpty)
                          _buildEmptyState()
                        else ...[
                          const Text(
                            'Your Health Vitals',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: _vitalData.length,
                            itemBuilder: (context, index) {
                              final vitalInfo = _vitalData[index];
                              return _buildVitalCard(vitalInfo);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHealthModeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _healthModeEnabled
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF64748B), const Color(0xFF475569)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_healthModeEnabled ? const Color(0xFF10B981) : const Color(0xFF64748B))
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _healthModeEnabled ? Icons.health_and_safety_rounded : Icons.dashboard_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _healthModeEnabled ? 'Health Mode Active' : 'Health Mode Inactive',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _healthModeEnabled
                      ? _selectedConditions.join(', ')
                      : 'Showing all vitals',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _healthModeEnabled
                      ? 'Tracking vitals for your conditions'
                      : 'Enable Health Mode in Settings',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(Map<String, dynamic> vitalInfo) {
    final vitalKey = vitalInfo['vitalKey'];
    final config = _getVitalConfig(vitalKey);
    final latestEntry = vitalInfo['latestEntry'] != null
        ? HealthTrackerEntry.fromJson(vitalInfo['latestEntry'])
        : null;
    final summary = vitalInfo['summary'] != null
        ? VitalSummary.fromJson(vitalInfo['summary'])
        : null;

    final Color color = config['color'] ?? Colors.grey;
    final bool hasData = latestEntry != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                child: Icon(config['icon'], color: color, size: 20),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (latestEntry.status == 'Normal' || latestEntry.status == 'Healthy')
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    latestEntry.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: (latestEntry.status == 'Normal' || latestEntry.status == 'Healthy')
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            config['name'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasData ? latestEntry.value : '--',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  config['unit'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (summary != null && summary.count > 0)
            Text(
              '7-day avg: ${summary.average?.toStringAsFixed(1) ?? '--'}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            )
          else
            Text(
              hasData
                  ? DateFormat('MMM dd, HH:mm').format(latestEntry.timestamp)
                  : 'No data yet',
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timeline_rounded,
                color: AppColors.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start Your Health Journey',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your vitals in the Health Tracker to see your health journey here.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
