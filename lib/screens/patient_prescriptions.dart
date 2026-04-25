import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/services/laboratory_service.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/labb_details.dart';
import 'package:icare/screens/pharmacy_details.dart';
import 'package:intl/intl.dart';

class PatientPrescriptions extends ConsumerStatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  ConsumerState<PatientPrescriptions> createState() =>
      _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends ConsumerState<PatientPrescriptions> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  List<dynamic> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _medicalRecordService.getMyRecords();
      if (result['success'] && mounted) {
        final records = result['records'] as List<dynamic>;
        final prescriptions = records.where((r) {
          final p = r['prescription'];
          if (p is Map) {
            final meds = p['medicines'] as List?;
            final tests = p['labTests'] as List?;
            final hasReferral = p['referral'] != null;
            return (meds != null && meds.isNotEmpty) ||
                (tests != null && tests.isNotEmpty) ||
                hasReferral;
          }
          return false;
        }).toList();
        setState(() {
          _prescriptions = prescriptions;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading prescriptions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
          'My Prescriptions',
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
          : _prescriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No prescriptions yet',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF64748B))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrescriptions,
                  child: ListView.builder(
                    padding: EdgeInsets.all(isDesktop ? 40 : 20),
                    itemCount: _prescriptions.length,
                    itemBuilder: (context, index) =>
                        _buildPrescriptionCard(_prescriptions[index]),
                  ),
                ),
    );
  }

  Widget _buildPrescriptionCard(dynamic record) {
    final date = DateTime.parse(record['createdAt']);
    final diagnosis = record['diagnosis'] ?? 'General Prescription';
    final doctorName = record['doctor']?['name'] ?? 'Unknown Doctor';
    final rawId = (record['_id'] ?? record['id'] ?? '').toString();
    final recordNumber = rawId.length >= 6
        ? 'MR-${rawId.substring(rawId.length - 6).toUpperCase()}'
        : 'MR-XXXXXX';
    final medicines =
        (record['prescription']?['medicines'] as List?) ?? [];
    final labTests =
        (record['prescription']?['labTests'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient:
                  LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(diagnosis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Dr. $doctorName',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recordNumber,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── MEDICINES ────────────────────────────────────────
                if (medicines.isNotEmpty) ...[
                  _sectionHeader(
                      Icons.medication_rounded,
                      const Color(0xFF3B82F6),
                      'Medications',
                      '${medicines.length} prescribed'),
                  const SizedBox(height: 12),
                  ...medicines.map((med) => _buildMedicineItem(med)),
                  const SizedBox(height: 12),
                  // Find Pharmacies button
                  _actionButton(
                    icon: Icons.local_pharmacy_rounded,
                    label: 'Find Pharmacies',
                    color: const Color(0xFF3B82F6),
                    onTap: () => _showFindPharmacies(context, medicines),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── LAB TESTS ────────────────────────────────────────
                if (labTests.isNotEmpty) ...[
                  _sectionHeader(
                      Icons.biotech_rounded,
                      const Color(0xFF8B5CF6),
                      'Lab Tests',
                      '${labTests.length} ordered'),
                  const SizedBox(height: 12),
                  ...labTests.map((test) => _buildLabTestItem(test)),
                  const SizedBox(height: 12),
                  // Find Labs button
                  _actionButton(
                    icon: Icons.science_rounded,
                    label: 'Find Labs',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _showFindLabs(context, labTests),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── SPECIALIST REFERRAL ──────────────────────────────
                if (record['prescription']?['referral'] != null) ...[
                  _sectionHeader(
                      Icons.person_search_rounded,
                      const Color(0xFFF59E0B),
                      'Specialist Referral',
                      null),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      final specialty =
                          record['prescription']['referral']['specialty'];
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => DoctorsListWithSpecialty(
                                  specialty: specialty)));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.person_search_rounded,
                                color: Color(0xFFF59E0B), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record['prescription']['referral']
                                          ['specialty'] ??
                                      'Specialist',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A)),
                                ),
                                if (record['prescription']['referral']
                                        ['reason'] !=
                                    null)
                                  Text(
                                    record['prescription']['referral']
                                        ['reason'],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B)),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],

                // Show empty state if no medicines AND no lab tests
                if (medicines.isEmpty &&
                    labTests.isEmpty &&
                    record['prescription']?['referral'] == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No details available',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
      IconData icon, Color color, String title, String? subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            if (subtitle != null)
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildMedicineItem(dynamic medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_rounded,
                  color: Color(0xFF3B82F6), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medicine['name'] ?? 'Medicine',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if ((medicine['dosage'] ?? '').toString().isNotEmpty)
                  _pill('Dosage', medicine['dosage']),
                if ((medicine['frequency'] ?? '').toString().isNotEmpty)
                  _pill('Frequency', medicine['frequency']),
                if ((medicine['duration'] ?? '').toString().isNotEmpty)
                  _pill('Duration', medicine['duration']),
              ],
            ),
          ),
          if ((medicine['instructions'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                '📝 ${medicine['instructions']}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabTestItem(dynamic test) {
    final urgency =
        (test['urgency'] ?? 'Routine').toString().toLowerCase();
    final urgencyColor = urgency == 'stat'
        ? const Color(0xFFEF4444)
        : urgency == 'urgent'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF8B5CF6);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.biotech_rounded,
              color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['name'] ?? 'Lab Test',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                ),
                if ((test['notes'] ?? '').toString().isNotEmpty)
                  Text(test['notes'],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              test['urgency'] ?? 'Routine',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: urgencyColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, dynamic value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600)),
        Text(value?.toString() ?? '',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── FIND LABS BOTTOM SHEET ──────────────────────────────────────────
  void _showFindLabs(BuildContext context, List<dynamic> tests) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FindLabsSheet(tests: tests),
    );
  }

  // ── FIND PHARMACIES BOTTOM SHEET ───────────────────────────────────
  void _showFindPharmacies(BuildContext context, List<dynamic> medicines) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FindPharmaciesSheet(medicines: medicines),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIND LABS SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _FindLabsSheet extends StatefulWidget {
  final List<dynamic> tests;
  const _FindLabsSheet({required this.tests});

  @override
  State<_FindLabsSheet> createState() => _FindLabsSheetState();
}

class _FindLabsSheetState extends State<_FindLabsSheet> {
  final LaboratoryService _labService = LaboratoryService();
  List<dynamic> _labs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLabs();
  }

  Future<void> _fetchLabs() async {
    try {
      final labs = await _labService.getAllLaboratories();
      if (mounted) setState(() { _labs = labs; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.science_rounded,
                            color: Color(0xFF8B5CF6), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Find Labs',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A))),
                            Text('Select a lab to book your tests',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Ordered tests chips
                  const Text('Ordered Tests:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.tests.map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDDD6FE)),
                      ),
                      child: Text(t['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C3AED),
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),
            // Labs list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _labs.isEmpty
                      ? const Center(
                          child: Text('No labs found',
                              style:
                                  TextStyle(color: Color(0xFF64748B))))
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _labs.length,
                          itemBuilder: (ctx, i) =>
                              _labTile(_labs[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labTile(dynamic lab) {
    final name = lab['labName']?.toString() ??
        lab['lab_name']?.toString() ??
        lab['name']?.toString() ??
        'Laboratory';
    final address = lab['address']?.toString() ?? lab['location']?.toString() ?? '';
    final phone = lab['phone']?.toString() ?? lab['phoneNumber']?.toString() ?? '';

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabDetails(labData: lab),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.science_rounded,
                  color: Color(0xFF8B5CF6), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Expanded(
                          child: Text(address,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.phone_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Text(phone,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ]),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIND PHARMACIES SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _FindPharmaciesSheet extends StatefulWidget {
  final List<dynamic> medicines;
  const _FindPharmaciesSheet({required this.medicines});

  @override
  State<_FindPharmaciesSheet> createState() => _FindPharmaciesSheetState();
}

class _FindPharmaciesSheetState extends State<_FindPharmaciesSheet> {
  final PharmacyService _pharmacyService = PharmacyService();
  List<dynamic> _pharmacies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPharmacies();
  }

  Future<void> _fetchPharmacies() async {
    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      if (mounted) setState(() { _pharmacies = pharmacies; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_pharmacy_rounded,
                            color: Color(0xFF3B82F6), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Find Pharmacies',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A))),
                            Text('Select a pharmacy for your medicines',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Prescribed Medicines:',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.medicines.map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(m['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pharmacies.isEmpty
                      ? const Center(
                          child: Text('No pharmacies found',
                              style: TextStyle(color: Color(0xFF64748B))))
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _pharmacies.length,
                          itemBuilder: (ctx, i) =>
                              _pharmacyTile(_pharmacies[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pharmacyTile(dynamic pharmacy) {
    final name = pharmacy['pharmacyName']?.toString() ??
        pharmacy['pharmacy_name']?.toString() ??
        pharmacy['name']?.toString() ??
        'Pharmacy';
    final address = pharmacy['address']?.toString() ?? pharmacy['location']?.toString() ?? '';
    final phone = pharmacy['phone']?.toString() ?? pharmacy['phoneNumber']?.toString() ?? '';

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsScreen(
              pharmacy: Map<String, dynamic>.from(pharmacy is Map ? pharmacy : {}),
              prescribedMedicines: widget.medicines,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_pharmacy_rounded,
                  color: Color(0xFF3B82F6), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Expanded(
                          child: Text(address,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.phone_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Text(phone,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B))),
                    ]),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
