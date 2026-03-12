import 'package:flutter/material.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class HealthTracker extends StatefulWidget {
  const HealthTracker({super.key});

  @override
  State<HealthTracker> createState() => _HealthTrackerState();
}

class _HealthTrackerState extends State<HealthTracker> {
  // Mock data - in production, fetch from backend
  final List<Map<String, dynamic>> _vitals = [
    {
      'type': 'Blood Pressure',
      'value': '120/80',
      'unit': 'mmHg',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFEF4444),
      'status': 'Normal',
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'type': 'Heart Rate',
      'value': '72',
      'unit': 'bpm',
      'icon': Icons.monitor_heart_rounded,
      'color': const Color(0xFFEC4899),
      'status': 'Normal',
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'type': 'Blood Glucose',
      'value': '95',
      'unit': 'mg/dL',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF8B5CF6),
      'status': 'Normal',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'type': 'Weight',
      'value': '70',
      'unit': 'kg',
      'icon': Icons.monitor_weight_rounded,
      'color': const Color(0xFF3B82F6),
      'status': 'Healthy',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'type': 'Temperature',
      'value': '36.6',
      'unit': '°C',
      'icon': Icons.thermostat_rounded,
      'color': const Color(0xFFF59E0B),
      'status': 'Normal',
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'type': 'Oxygen Level',
      'value': '98',
      'unit': '%',
      'icon': Icons.air_rounded,
      'color': const Color(0xFF10B981),
      'status': 'Normal',
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 3)),
    },
  ];

  void _addVitalReading(String type) {
    showDialog(
      context: context,
      builder: (context) => _AddVitalDialog(
        vitalType: type,
        onSave: (value) {
          // In production, save to backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$type reading saved: $value')),
          );
        },
      ),
    );
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
          'Health Tracker',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 40 : 20),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthSummary(),
                const SizedBox(height: 24),
                const Text(
                  'Vital Signs',
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
                  itemCount: _vitals.length,
                  itemBuilder: (context, index) => _buildVitalCard(_vitals[index]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
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
            child: const Icon(Icons.favorite_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Health',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Good',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All vitals within normal range',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(Map<String, dynamic> vital) {
    return InkWell(
      onTap: () => _addVitalReading(vital['type']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (vital['color'] as Color).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: (vital['color'] as Color).withValues(alpha: 0.1),
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
                    color: (vital['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(vital['icon'], color: vital['color'], size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vital['status'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              vital['type'],
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
                  vital['value'],
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
                    vital['unit'],
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
            Text(
              DateFormat('MMM dd, HH:mm').format(vital['lastUpdated']),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVitalDialog extends StatefulWidget {
  final String vitalType;
  final Function(String) onSave;

  const _AddVitalDialog({required this.vitalType, required this.onSave});

  @override
  State<_AddVitalDialog> createState() => _AddVitalDialogState();
}

class _AddVitalDialogState extends State<_AddVitalDialog> {
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _save() {
    if (_valueController.text.isEmpty) return;
    widget.onSave(_valueController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add ${widget.vitalType} Reading',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'Enter reading',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
