import 'package:flutter/material.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';

class ClinicalAuditScreen extends StatefulWidget {
  const ClinicalAuditScreen({super.key});

  @override
  State<ClinicalAuditScreen> createState() => _ClinicalAuditScreenState();
}

class _ClinicalAuditScreenState extends State<ClinicalAuditScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _auditLogs = [];
  int _totalAppointments = 0;
  int _completedWithRecords = 0;
  int _pendingDocumentation = 0;

  @override
  void initState() {
    super.initState();
    _loadAuditData();
  }

  Future<void> _loadAuditData() async {
    setState(() => _isLoading = true);
    try {
      final appResult = await AppointmentService().getMyAppointmentsDetailed();
      final recordsResult = await MedicalRecordService().getDoctorRecords();

      if (mounted) {
        final appointments = appResult['success']
            ? (appResult['appointments'] as List)
            : [];
        final records = recordsResult['success']
            ? (recordsResult['records'] as List)
            : [];

        final completed = appointments
            .where((a) => a.status == 'completed')
            .toList();
        final recordPatientIds = records
            .map((r) => r['patient']?['_id'] ?? r['patient'])
            .toSet();

        final logs = <Map<String, dynamic>>[];

        // Flag completed appointments without medical records
        for (final appt in completed) {
          final patientId = appt.patient?.id ?? '';
          if (!recordPatientIds.contains(patientId)) {
            logs.add({
              'message':
                  'Missing medical record for ${appt.patient?.name ?? 'patient'} — ${appt.timeSlot}',
              'status': 'Warning',
              'color': Colors.orange,
            });
          }
        }

        if (logs.isEmpty) {
          logs.add({
            'message': 'All completed appointments have documentation.',
            'status': 'Verified',
            'color': Colors.green,
          });
        }

        setState(() {
          _totalAppointments = appointments.length;
          _completedWithRecords = records.length;
          _pendingDocumentation = logs
              .where((l) => l['status'] == 'Warning')
              .length;
          _auditLogs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _qualityScore {
    if (_totalAppointments == 0) return 1.0;
    final completed = _totalAppointments > 0 ? _completedWithRecords : 0;
    return (completed / _totalAppointments).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Clinical Audit & QA',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadAuditData,
            icon: _isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded, color: AppColors.primaryColor),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQualityScore(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Performance Metrics'),
                  const SizedBox(height: 16),
                  _buildMetricTile('Total Appointments', '$_totalAppointments', AppColors.primaryColor),
                  _buildMetricTile('Medical Records Created', '$_completedWithRecords', Colors.green),
                  _buildMetricTile('Pending Documentation', '$_pendingDocumentation',
                      _pendingDocumentation > 0 ? Colors.orange : Colors.green),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Clinical Flags'),
                  const SizedBox(height: 16),
                  ..._auditLogs.map((log) =>
                      _buildAuditLog(log['message'], log['status'], log['color'])),
                ],
              ),
            ),
    );
  }

  Widget _buildQualityScore() {
    final score = _qualityScore;
    final pct = '${(score * 100).toStringAsFixed(0)}%';
    final color = score >= 0.8 ? Colors.green : score >= 0.5 ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: score, strokeWidth: 8,
                  color: color, backgroundColor: Colors.white10,
                ),
              ),
              Text(pct, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Documentation Score',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  score >= 0.8
                      ? 'Excellent documentation rate.'
                      : score >= 0.5
                          ? 'Some appointments need documentation.'
                          : 'Many appointments missing records.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLog(String message, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
