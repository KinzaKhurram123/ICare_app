import 'package:flutter/material.dart';
import 'package:icare/models/user.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/consultation_service.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:intl/intl.dart';

class PatientHistoryView extends StatefulWidget {
  final User patient;

  const PatientHistoryView({super.key, required this.patient});

  @override
  State<PatientHistoryView> createState() => _PatientHistoryViewState();
}

class _PatientHistoryViewState extends State<PatientHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  final ConsultationService _consultationService = ConsultationService();

  List<dynamic> _appointments = [];
  List<dynamic> _medicalRecords = [];
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final futures = await Future.wait([
      _appointmentService.getMyAppointmentsDetailed(),
      _medicalRecordService.getDoctorRecords(),
      _consultationService.getPatientPrescriptions(patientId: widget.patient.id),
    ]);

    final appointmentsResult = futures[0] as Map<String, dynamic>;
    final recordsResult = futures[1] as Map<String, dynamic>;
    final prescriptionsResult = futures[2] as List<dynamic>;

    if (appointmentsResult['success'] == true) {
      _appointments = (appointmentsResult['appointments'] as List)
          .where((a) => a.patient?.id == widget.patient.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    if (recordsResult['success'] == true) {
      _medicalRecords = (recordsResult['records'] as List)
          .where((r) => r['patient']?['_id'] == widget.patient.id)
          .toList()
        ..sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    }

    _prescriptions = prescriptionsResult
      ..sort((a, b) {
        final aDate = a['prescribedAt'] ?? a['createdAt'] ?? '';
        final bDate = b['prescribedAt'] ?? b['createdAt'] ?? '';
        return bDate.compareTo(aDate);
      });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
              child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryColor)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.patient.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData, tooltip: 'Refresh'),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_month_rounded, size: 16),
                const SizedBox(width: 4),
                Text('Appts (${_appointments.length})'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.description_rounded, size: 16),
                const SizedBox(width: 4),
                Text('Rx (${_prescriptions.length})'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.folder_rounded, size: 16),
                const SizedBox(width: 4),
                Text('Records (${_medicalRecords.length})'),
              ]),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsTab(),
                _buildPrescriptionsTab(),
                _buildMedicalRecordsTab(),
              ],
            ),
    );
  }

  // ── Appointments Tab ──────────────────────────────────────────────────────
  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return _buildEmptyState('No past appointments', Icons.event_busy_rounded);
    }

    // Group by status
    final completed = _appointments.where((a) => a.status.toLowerCase() == 'completed').toList();
    final others = _appointments.where((a) => a.status.toLowerCase() != 'completed').toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary row
          Row(children: [
            _summaryChip('Total', _appointments.length.toString(), AppColors.primaryColor),
            const SizedBox(width: 8),
            _summaryChip('Completed', completed.length.toString(), const Color(0xFF10B981)),
            const SizedBox(width: 8),
            _summaryChip('Others', others.length.toString(), const Color(0xFFF59E0B)),
          ]),
          const SizedBox(height: 16),
          ..._appointments.map((appt) => _buildAppointmentCard(appt)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    final date = appointment.date as DateTime;
    final status = appointment.status.toString();
    final statusColor = _getStatusColor(status);
    final reason = appointment.reason as String? ?? '';
    final timeSlot = appointment.timeSlot as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAppointmentDetail(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_today_rounded, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM dd yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        if (timeSlot.isNotEmpty)
                          Text(timeSlot, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ],
              ),
              if (reason.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.notes_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reason.length > 80 ? '${reason.substring(0, 80)}...' : reason,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Tap to view details', style: TextStyle(fontSize: 11, color: AppColors.primaryColor.withValues(alpha: 0.7))),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryColor.withValues(alpha: 0.7)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetail(dynamic appointment) {
    final date = appointment.date as DateTime;
    final status = appointment.status.toString();
    final statusColor = _getStatusColor(status);
    final reason = appointment.reason as String? ?? 'Not specified';
    final timeSlot = appointment.timeSlot as String? ?? 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.calendar_month_rounded, color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('EEEE, MMMM dd, yyyy').format(date),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                              Text(timeSlot, style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _detailRow(Icons.notes_rounded, 'Reason / Chief Complaint', reason, AppColors.primaryColor),
                    const SizedBox(height: 12),
                    _detailRow(Icons.person_rounded, 'Patient', widget.patient.name, const Color(0xFF3B82F6)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Prescriptions Tab ────────────────────────────────────────────────────
  Widget _buildPrescriptionsTab() {
    if (_prescriptions.isEmpty) {
      return _buildEmptyState('No prescriptions found', Icons.medication_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryChip('Total Prescriptions', _prescriptions.length.toString(), const Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          ..._prescriptions.map((rx) => _buildPrescriptionCard(rx)),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(dynamic rx) {
    final rawDate = rx['prescribedAt'] ?? rx['createdAt'] ?? '';
    DateTime? date;
    try { date = DateTime.parse(rawDate); } catch (_) {}
    final medicines = (rx['medicines'] as List?) ?? [];
    final diagnoses = (rx['diagnoses'] as List?) ?? [];
    final labTests = (rx['labTests'] as List?) ?? [];
    final status = rx['status']?.toString() ?? 'draft';
    final isComplete = rx['isComplete'] == true;
    final statusColor = isComplete ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPrescriptionDetail(rx),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.description_rounded, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Date unknown',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${medicines.length} med${medicines.length != 1 ? 's' : ''} · ${diagnoses.length} diag · ${labTests.length} lab',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(isComplete ? 'COMPLETE' : status.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ],
              ),
              if (diagnoses.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: diagnoses.take(3).map((d) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFCA5A5))),
                    child: Text(
                      '${d['icd10Code'] ?? ''} ${d['diagnosis'] ?? ''}'.trim(),
                      style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                    ),
                  )).toList(),
                ),
              ],
              if (medicines.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: medicines.take(4).map((m) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFA7F3D0))),
                    child: Text(
                      '${m['medicineName'] ?? ''}${m['dose']?.isNotEmpty == true ? ' ${m['dose']}' : ''}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Tap for full prescription', style: TextStyle(fontSize: 11, color: AppColors.primaryColor.withValues(alpha: 0.7))),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryColor.withValues(alpha: 0.7)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrescriptionDetail(dynamic rx) {
    final rawDate = rx['prescribedAt'] ?? rx['createdAt'] ?? '';
    DateTime? date;
    try { date = DateTime.parse(rawDate); } catch (_) {}
    final medicines = (rx['medicines'] as List?) ?? [];
    final diagnoses = (rx['diagnoses'] as List?) ?? [];
    final labTests = (rx['labTests'] as List?) ?? [];
    final doctorNotes = rx['doctorNotes']?.toString() ?? '';
    final soap = rx['soapNotes'] as Map<String, dynamic>?;
    final referral = rx['referralFollowUp'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.description_rounded, color: Color(0xFF8B5CF6), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prescription Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                          if (date != null) Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    // Diagnoses
                    if (diagnoses.isNotEmpty) ...[
                      _rxSectionHeader('Diagnosis', Icons.medical_information_rounded, const Color(0xFFEF4444)),
                      ...diagnoses.map((d) => _rxItem(
                        '${d['icd10Code'] ?? ''}'.isNotEmpty ? '[${d['icd10Code']}] ${d['diagnosis'] ?? ''}' : d['diagnosis']?.toString() ?? '',
                        icon: Icons.circle, iconColor: const Color(0xFFEF4444), small: true,
                      )),
                      const SizedBox(height: 14),
                    ],
                    // Medicines
                    if (medicines.isNotEmpty) ...[
                      _rxSectionHeader('Medications', Icons.medication_rounded, const Color(0xFF10B981)),
                      ...medicines.map((m) {
                        final name = m['medicineName']?.toString() ?? '';
                        final dose = m['dose']?.toString() ?? '';
                        final freq = m['frequencyDisplay']?.toString() ?? m['frequency']?.toString() ?? '';
                        final dur = m['duration']?.toString() ?? '';
                        final notes = m['notes']?.toString() ?? '';
                        return _rxItem(
                          '$name${dose.isNotEmpty ? ' — $dose' : ''}',
                          subtitle: '${freq.isNotEmpty ? freq : ''}${dur.isNotEmpty ? ' · $dur' : ''}${notes.isNotEmpty ? ' · $notes' : ''}',
                          icon: Icons.medication_outlined, iconColor: const Color(0xFF10B981),
                        );
                      }),
                      const SizedBox(height: 14),
                    ],
                    // Lab Tests
                    if (labTests.isNotEmpty) ...[
                      _rxSectionHeader('Lab Tests', Icons.biotech_rounded, const Color(0xFF8B5CF6)),
                      ...labTests.map((t) => _rxItem(t['testName']?.toString() ?? '', icon: Icons.science_outlined, iconColor: const Color(0xFF8B5CF6), small: true)),
                      const SizedBox(height: 14),
                    ],
                    // Doctor Notes
                    if (doctorNotes.isNotEmpty) ...[
                      _rxSectionHeader("Doctor's Notes", Icons.notes_rounded, AppColors.primaryColor),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                        child: Text(doctorNotes, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                      ),
                      const SizedBox(height: 14),
                    ],
                    // SOAP Notes
                    if (soap != null && (soap['subjective']?.toString().isNotEmpty == true || soap['assessment']?.toString().isNotEmpty == true)) ...[
                      _rxSectionHeader('SOAP Notes', Icons.edit_note_rounded, const Color(0xFF0EA5E9)),
                      if (soap['subjective']?.toString().isNotEmpty == true) _rxItem('Subjective: ${soap['subjective']}', icon: Icons.circle, iconColor: const Color(0xFF0EA5E9), small: true),
                      if (soap['assessment']?.toString().isNotEmpty == true) _rxItem('Assessment: ${soap['assessment']}', icon: Icons.circle, iconColor: const Color(0xFF0EA5E9), small: true),
                      if (soap['plan']?.toString().isNotEmpty == true) _rxItem('Plan: ${soap['plan']}', icon: Icons.circle, iconColor: const Color(0xFF0EA5E9), small: true),
                      const SizedBox(height: 14),
                    ],
                    // Referral
                    if (referral != null && referral['referralType'] != null && referral['referralType'] != 'none') ...[
                      _rxSectionHeader('Referral & Follow-up', Icons.event_repeat_rounded, const Color(0xFFEC4899)),
                      _rxItem('Referral: ${referral['referralType']}${referral['referralSpecialty'] != null ? ' — ${referral['referralSpecialty']}' : ''}', icon: Icons.send_rounded, iconColor: const Color(0xFFEC4899), small: true),
                      if (referral['followUpDuration'] != null && referral['followUpDuration'] != 'none')
                        _rxItem('Follow-up: ${referral['followUpDuration']}', icon: Icons.calendar_today_rounded, iconColor: const Color(0xFFEC4899), small: true),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rxSectionHeader(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
      ]),
    );
  }

  Widget _rxItem(String text, {String? subtitle, required IconData icon, required Color iconColor, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: small ? 8 : 16, color: iconColor)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(fontSize: small ? 13 : 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                if (subtitle != null && subtitle.trim().isNotEmpty)
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Medical Records Tab ───────────────────────────────────────────────────
  Widget _buildMedicalRecordsTab() {
    if (_medicalRecords.isEmpty) {
      return _buildEmptyState('No medical records found', Icons.folder_off_rounded);
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryChip('Total Records', _medicalRecords.length.toString(), const Color(0xFF10B981)),
          const SizedBox(height: 16),
          ..._medicalRecords.map((record) => _buildMedicalRecordCard(record)),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(dynamic record) {
    final date = DateTime.parse(record['createdAt']);
    final diagnosis = record['diagnosis']?.toString() ?? 'No diagnosis';
    final symptoms = (record['symptoms'] as List?)?.map((s) => s.toString()).toList() ?? [];
    final hasLabReports = (record['labReportUrls'] as List?)?.isNotEmpty == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRecordDetail(record),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diagnosis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(DateFormat('MMM dd, yyyy').format(date),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  if (hasLabReports)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf_rounded, size: 12, color: Colors.red),
                          SizedBox(width: 3),
                          Text('Labs', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
              if (symptoms.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: symptoms.take(4).map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Tap to view full record', style: TextStyle(fontSize: 11, color: AppColors.primaryColor.withValues(alpha: 0.7))),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryColor.withValues(alpha: 0.7)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetail(dynamic record) {
    final date = DateTime.parse(record['createdAt']);
    final diagnosis = record['diagnosis']?.toString() ?? 'N/A';
    final symptoms = (record['symptoms'] as List?)?.map((s) => s.toString()).toList() ?? [];
    final notes = record['notes']?.toString() ?? '';
    final labReports = record['labReportUrls'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.medical_services_rounded, color: Color(0xFF10B981), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Medical Record', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                          Text(DateFormat('MMMM dd, yyyy').format(date), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _detailRow(Icons.medical_information_rounded, 'Diagnosis', diagnosis, const Color(0xFFEF4444)),
                    if (symptoms.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: symptoms.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                          child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ],
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _detailRow(Icons.notes_rounded, 'Notes', notes, AppColors.primaryColor),
                    ],
                    if (labReports.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Lab Reports', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      ...labReports.map((report) => InkWell(
                        onTap: () {
                          final url = report['url']?.toString() ?? '';
                          if (url.isNotEmpty) debugPrint('Opening: $url');
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  report['testName']?.toString() ?? 'Lab Report',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ),
                              const Icon(Icons.download_rounded, color: AppColors.primaryColor, size: 18),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.8))),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: Icon(icon, size: 56, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return const Color(0xFF10B981);
      case 'pending': return const Color(0xFFF59E0B);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'completed': return const Color(0xFF3B82F6);
      case 'in_progress': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF64748B);
    }
  }
}
