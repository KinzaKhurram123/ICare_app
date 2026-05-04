import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/services/laboratory_service.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/screens/doctors_list.dart';
import 'package:icare/screens/labb_details.dart';
import 'package:icare/screens/pharmacy_details.dart';
import 'package:icare/screens/pharmacy_prescription_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class PatientPrescriptions extends ConsumerStatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  ConsumerState<PatientPrescriptions> createState() =>
      _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends ConsumerState<PatientPrescriptions> {
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  List<dynamic> _prescriptions = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
        _applyFilter();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_prescriptions);
      return;
    }
    _filtered = _prescriptions.where((r) {
      final diagnosis = (r['diagnosis'] ?? '').toString().toLowerCase();
      final doctorName = (r['doctor']?['name'] ?? '').toString().toLowerCase();
      final date = r['createdAt'] != null
          ? DateFormat('MMM dd, yyyy')
              .format(DateTime.parse(r['createdAt'].toString()))
              .toLowerCase()
          : '';
      final rawId = (r['_id'] ?? r['id'] ?? '').toString();
      final mrNumber = rawId.length >= 6
          ? 'mr-${rawId.substring(rawId.length - 6).toLowerCase()}'
          : '';
      // Also search medicine names
      final meds = (r['prescription']?['medicines'] as List?) ?? [];
      final medNames = meds
          .map((m) => (m is Map ? m['name'] : m).toString().toLowerCase())
          .join(' ');
      // Also search lab test names
      final labs = (r['prescription']?['labTests'] as List?) ??
          (r['labTests'] as List?) ??
          [];
      final labNames = labs
          .map((t) => (t is Map ? (t['name'] ?? t['testName']) : t)
              .toString()
              .toLowerCase())
          .join(' ');

      return diagnosis.contains(_searchQuery) ||
          doctorName.contains(_searchQuery) ||
          date.contains(_searchQuery) ||
          mrNumber.contains(_searchQuery) ||
          medNames.contains(_searchQuery) ||
          labNames.contains(_searchQuery);
    }).toList();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _medicalRecordService.getMyRecords();
      debugPrint('🔍 PRESCRIPTION DEBUG: API result success = ${result['success']}');

      if (result['success'] && mounted) {
        final records = result['records'] as List<dynamic>;
        debugPrint('🔍 PRESCRIPTION DEBUG: Total records = ${records.length}');

        final prescriptions = records.where((r) {
          final p = r['prescription'];
          final meds = p is Map ? (p['medicines'] as List?) : null;

          // labTests can be at top level OR inside prescription
          final testsInPrescription = p is Map ? (p['labTests'] as List?) : null;
          final testsAtTopLevel = r['labTests'] as List?;
          final tests = testsInPrescription ?? testsAtTopLevel;

          final hasReferral = p is Map && p['referral'] != null;

          debugPrint('🔍 Record ${r['_id']}: meds=${meds?.length ?? 0}, testsInPrescription=${testsInPrescription?.length ?? 0}, testsAtTopLevel=${testsAtTopLevel?.length ?? 0}, hasReferral=$hasReferral');

          return (meds != null && meds.isNotEmpty) ||
              (tests != null && tests.isNotEmpty) ||
              hasReferral;
        }).toList();

        debugPrint('🔍 PRESCRIPTION DEBUG: Filtered prescriptions = ${prescriptions.length}');

        setState(() {
          _prescriptions = prescriptions;
          _filtered = List.from(prescriptions);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Error loading prescriptions: $e');
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
          : Column(
              children: [
                // ── Search Bar ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(
                      isDesktop ? 40 : 16, 12, isDesktop ? 40 : 16, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search by diagnosis, doctor, medicine, lab test…',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8), size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF94A3B8), size: 18),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.5),
                            width: 1.5),
                      ),
                    ),
                  ),
                ),
                // ── Result count ────────────────────────────────────────
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        isDesktop ? 40 : 16, 8, isDesktop ? 40 : 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _filtered.isEmpty
                            ? 'No results for "$_searchQuery"'
                            : '${_filtered.length} result${_filtered.length == 1 ? '' : 's'} for "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 12,
                          color: _filtered.isEmpty
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // ── List ────────────────────────────────────────────────
                Expanded(
                  child: _filtered.isEmpty && _searchQuery.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 56,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No prescriptions match\n"$_searchQuery"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      : _prescriptions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 64,
                                      color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  const Text('No prescriptions yet',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF64748B))),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadPrescriptions,
                              child: ListView.builder(
                                padding: EdgeInsets.all(isDesktop ? 40 : 20),
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) =>
                                    _buildPrescriptionCard(_filtered[index]),
                              ),
                            ),
                ),
              ],
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
    // labTests can be at top level OR inside prescription
    final labTests = (record['prescription']?['labTests'] as List?)
        ?? (record['labTests'] as List?)
        ?? [];

    debugPrint('🔍 CARD DEBUG for ${record['_id']}: medicines=${medicines.length}, labTests=${labTests.length}');
    debugPrint('   labTests content: $labTests');

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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── MY PRESCRIPTION TILE (full details) ──────────────
                _clickableTile(
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFF0EA5E9),
                  bgColor: const Color(0xFFE0F2FE),
                  title: 'My Prescription',
                  subtitle: 'Patient info, SOAP notes & full details',
                  arrowColor: const Color(0xFF0EA5E9),
                  onTap: () => _showPrescriptionDetail(context, record, medicines, labTests, recordNumber),
                ),
                const SizedBox(height: 12),

                // ── MEDICINES TILE (clickable) ────────────────────────
                if (medicines.isNotEmpty) ...[
                  _clickableTile(
                    icon: Icons.medication_rounded,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                    title: 'Medicines',
                    subtitle: '${medicines.length} prescribed by doctor',
                    arrowColor: const Color(0xFF3B82F6),
                    onTap: () => _showMedicinesDetail(context, medicines),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── LAB TESTS TILE (clickable) ────────────────────────
                if (labTests.isNotEmpty) ...[
                  _clickableTile(
                    icon: Icons.biotech_rounded,
                    color: const Color(0xFF8B5CF6),
                    bgColor: const Color(0xFFF5F3FF),
                    title: 'Lab Tests',
                    subtitle: '${labTests.length} tests ordered',
                    arrowColor: const Color(0xFF8B5CF6),
                    onTap: () => _showLabTestsDetail(context, labTests),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── SPECIALIST REFERRAL TILE ──────────────────────────
                if (record['prescription']?['referral'] != null) ...[
                  _clickableTile(
                    icon: Icons.person_search_rounded,
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFFFBEB),
                    title: record['prescription']['referral']['specialty'] ?? 'Specialist Referral',
                    subtitle: record['prescription']['referral']['reason'] ?? 'Referred by doctor',
                    arrowColor: const Color(0xFFF59E0B),
                    onTap: () {
                      final specialty = record['prescription']['referral']['specialty'];
                      Navigator.push(context, MaterialPageRoute(
                          builder: (ctx) => DoctorsListWithSpecialty(specialty: specialty)));
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MY PRESCRIPTION FULL DETAIL SHEET ──────────────────────────────────
  void _showPrescriptionDetail(
    BuildContext context,
    dynamic record,
    List<dynamic> medicines,
    List<dynamic> labTests,
    String recordNumber,
  ) {
    final patientData = record['patient'];
    final doctorData = record['doctor'];
    final date = DateTime.parse(record['createdAt']);

    // Patient info
    final patientName = patientData is Map
        ? (patientData['name'] ?? patientData['username'] ?? 'Patient').toString()
        : 'Patient';
    final patientEmail = patientData is Map
        ? (patientData['email'] ?? '').toString()
        : '';
    final patientGender = patientData is Map
        ? (patientData['gender'] ?? '').toString()
        : '';
    final patientAge = patientData is Map
        ? (patientData['age'] ?? '').toString()
        : '';

    // Doctor info
    final doctorName = doctorData is Map
        ? (doctorData['name'] ?? doctorData['username'] ?? 'Doctor').toString()
        : 'Doctor';

    // Determine if "For Myself" — if patient has a valid MR number (has _id)
    final patientId = patientData is Map
        ? (patientData['_id'] ?? patientData['id'] ?? '').toString()
        : '';
    final hasMrNumber = patientId.isNotEmpty && patientId.length >= 6;
    final mrNumber = hasMrNumber
        ? 'MR-${patientId.substring(patientId.length - 6).toUpperCase()}'
        : null;

    // Diagnosis / SOAP notes
    final diagnosis = (record['diagnosis'] ?? 'General Consultation').toString();
    final notes = (record['notes'] ?? '').toString();
    final followUpDate = record['followUpDate'] != null
        ? DateTime.tryParse(record['followUpDate'].toString())
        : null;
    final followUpDays = record['followUpDays'];
    final followUpMonths = record['followUpMonths'];

    // Assigned courses
    final assignedCourses = (record['assignedCourses'] as List?) ?? [];

    // Vital signs
    final vitals = record['vitalSigns'] as Map?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              // Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Prescription',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                          Text(DateFormat('MMMM dd, yyyy').format(date),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                    if (mrNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(mrNumber,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    // ── PATIENT INFO CARD ─────────────────────────────
                    _prescriptionSection(
                      icon: Icons.person_rounded,
                      color: const Color(0xFF0EA5E9),
                      title: 'Patient Information',
                      child: Column(
                        children: [
                          _infoRow('Name', patientName),
                          if (patientGender.isNotEmpty)
                            _infoRow('Gender', patientGender),
                          if (patientAge.isNotEmpty)
                            _infoRow('Age', '$patientAge years'),
                          if (patientEmail.isNotEmpty)
                            _infoRow('Email', patientEmail),
                          if (mrNumber != null)
                            _infoRow('MR Number', mrNumber,
                                highlight: true)
                          else
                            _infoRow('Appointment For', 'Someone Else',
                                highlight: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── DOCTOR INFO ───────────────────────────────────
                    _prescriptionSection(
                      icon: Icons.medical_services_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Consulting Doctor',
                      child: _infoRow('Doctor', 'Dr. $doctorName'),
                    ),
                    const SizedBox(height: 12),

                    // ── DIAGNOSIS ─────────────────────────────────────
                    _prescriptionSection(
                      icon: Icons.local_hospital_rounded,
                      color: const Color(0xFFEF4444),
                      title: 'Diagnosis',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Text(diagnosis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A))),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── SOAP NOTES / CLINICAL NOTES ───────────────────
                    if (notes.isNotEmpty) ...[
                      _prescriptionSection(
                        icon: Icons.notes_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'Clinical Notes',
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Text(notes,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                  height: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── VITAL SIGNS ───────────────────────────────────
                    if (vitals != null && vitals.isNotEmpty) ...[
                      _prescriptionSection(
                        icon: Icons.monitor_heart_rounded,
                        color: const Color(0xFFF59E0B),
                        title: 'Vital Signs',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if ((vitals['bloodPressure'] ?? '').toString().isNotEmpty)
                              _vitalChip('BP', vitals['bloodPressure'].toString()),
                            if (vitals['temperature'] != null)
                              _vitalChip('Temp', '${vitals['temperature']}°C'),
                            if (vitals['heartRate'] != null)
                              _vitalChip('Heart Rate', '${vitals['heartRate']} bpm'),
                            if (vitals['weight'] != null)
                              _vitalChip('Weight', '${vitals['weight']} kg'),
                            if (vitals['height'] != null)
                              _vitalChip('Height', '${vitals['height']} cm'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── MEDICINES ─────────────────────────────────────
                    if (medicines.isNotEmpty) ...[
                      _prescriptionSection(
                        icon: Icons.medication_rounded,
                        color: const Color(0xFF3B82F6),
                        title: 'Prescribed Medicines',
                        child: Column(
                          children: medicines
                              .map((m) => _buildMedicineItem(m))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── LAB TESTS ─────────────────────────────────────
                    if (labTests.isNotEmpty) ...[
                      _prescriptionSection(
                        icon: Icons.biotech_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'Ordered Lab Tests',
                        child: Column(
                          children: labTests
                              .map((t) => _buildLabTestItem(t))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── ASSIGNED COURSES ──────────────────────────────
                    if (assignedCourses.isNotEmpty) ...[
                      _prescriptionSection(
                        icon: Icons.school_rounded,
                        color: const Color(0xFF10B981),
                        title: 'Assigned Courses',
                        child: Column(
                          children: assignedCourses.map((course) {
                            final courseName = course is Map
                                ? (course['title'] ?? course['name'] ?? 'Course').toString()
                                : course.toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_circle_rounded,
                                      color: Color(0xFF10B981), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(courseName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A))),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── FOLLOW UP ─────────────────────────────────────
                    if (followUpDate != null ||
                        (followUpDays != null && followUpDays != 0) ||
                        (followUpMonths != null && followUpMonths != 0)) ...[
                      _prescriptionSection(
                        icon: Icons.event_repeat_rounded,
                        color: const Color(0xFF0EA5E9),
                        title: 'Follow Up',
                        child: _infoRow(
                          'Next Visit',
                          followUpDate != null
                              ? DateFormat('MMMM dd, yyyy').format(followUpDate)
                              : followUpDays != null && followUpDays != 0
                                  ? 'In $followUpDays days'
                                  : 'In $followUpMonths months',
                        ),
                      ),
                      const SizedBox(height: 12),
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

  Widget _prescriptionSection({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlight
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }

  Widget _vitalChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  // ── CLICKABLE TILE ───────────────────────────────────────────────────────
  Widget _clickableTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required Color arrowColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 16),
          ],
        ),
      ),
    );
  }

  // ── MEDICINES DETAIL SHEET ───────────────────────────────────────────────
  void _showMedicinesDetail(BuildContext context, List<dynamic> medicines) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication_rounded,
                          color: Color(0xFF3B82F6), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prescribed Medicines',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A))),
                          Text('Tap "Find Pharmacies" to order',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Medicines list
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: medicines.length,
                  itemBuilder: (_, i) => _buildMedicineItem(medicines[i]),
                ),
              ),
              // Find Pharmacies button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFindPharmacies(context, medicines);
                    },
                    icon: const Icon(Icons.local_pharmacy_rounded),
                    label: const Text('Find Pharmacies',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── LAB TESTS DETAIL SHEET ───────────────────────────────────────────────
  void _showLabTestsDetail(BuildContext context, List<dynamic> labTests) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.biotech_rounded,
                          color: Color(0xFF8B5CF6), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ordered Lab Tests',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A))),
                          Text('Tap "Find Labs" to book',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: labTests.length,
                  itemBuilder: (_, i) => _buildLabTestItem(labTests[i]),
                ),
              ),
              // Find Labs button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFindLabs(context, labTests);
                    },
                    icon: const Icon(Icons.science_rounded),
                    label: const Text('Find Labs',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    // Handle both String (legacy) and Map format
    final testName = test is Map
        ? (test['name'] ?? test['testName'] ?? 'Lab Test').toString()
        : test.toString();
    final urgency = test is Map
        ? (test['urgency'] ?? 'Routine').toString().toLowerCase()
        : 'routine';
    final testNotes = test is Map ? (test['notes'] ?? '').toString() : '';
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
                  testName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A)),
                ),
                if (testNotes.isNotEmpty)
                  Text(testNotes,
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
              urgency == 'stat' ? 'STAT' : urgency == 'urgent' ? 'Urgent' : 'Routine',
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
  List<dynamic> _filteredLabs = [];
  bool _isLoading = true;
  String? _error;
  double? _userLat;
  double? _userLng;

  // 'nearest' or 'search'
  String _mode = 'nearest';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLabs();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final completer = Completer<List<double>?>();
      js.context['navigator']['geolocation'].callMethod('getCurrentPosition', [
        js.allowInterop((pos) {
          final coords = pos['coords'];
          completer.complete([
            (coords['latitude'] as num).toDouble(),
            (coords['longitude'] as num).toDouble(),
          ]);
        }),
        js.allowInterop((err) => completer.complete(null)),
      ]);
      final pos = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (pos != null && mounted) {
        setState(() {
          _userLat = pos[0];
          _userLng = pos[1];
          _sortByDistance();
        });
        _fetchLabs();
      }
    } catch (_) {
      // Location unavailable
    }
  }

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _sortByDistance() {
    if (_userLat == null || _userLng == null) return;
    _labs.sort((a, b) {
      final aLat = ((a['latitude'] ?? a['lat']) as num?)?.toDouble();
      final aLng = ((a['longitude'] ?? a['lng']) as num?)?.toDouble();
      final bLat = ((b['latitude'] ?? b['lat']) as num?)?.toDouble();
      final bLng = ((b['longitude'] ?? b['lng']) as num?)?.toDouble();
      if (aLat == null || aLng == null) return 1;
      if (bLat == null || bLng == null) return -1;
      return _haversineDistance(_userLat!, _userLng!, aLat, aLng)
          .compareTo(_haversineDistance(_userLat!, _userLng!, bLat, bLng));
    });
    _filteredLabs = List.from(_labs);
  }

  void _filterByLocation(String query) {
    if (query.isEmpty) {
      setState(() => _filteredLabs = List.from(_labs));
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredLabs = _labs.where((l) {
        final name = (l['lab_name'] ?? l['labName'] ?? l['name'] ?? '').toString().toLowerCase();
        final address = (l['address'] ?? '').toString().toLowerCase();
        final city = (l['city'] ?? '').toString().toLowerCase();
        return name.contains(q) || address.contains(q) || city.contains(q);
      }).toList();
    });
  }

  String? _getDistance(dynamic lab) {
    if (_userLat == null || _userLng == null) return null;
    final lat = ((lab['latitude'] ?? lab['lat']) as num?)?.toDouble();
    final lng = ((lab['longitude'] ?? lab['lng']) as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    final dist = _haversineDistance(_userLat!, _userLng!, lat, lng);
    if (dist < 1) return '${(dist * 1000).toStringAsFixed(0)} m';
    return '${dist.toStringAsFixed(1)} km';
  }

  Future<void> _fetchLabs() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final labs = await _labService.getAllLaboratories();
      if (mounted) {
        setState(() {
          _labs = labs;
          _filteredLabs = List.from(labs);
          _isLoading = false;
          if (_userLat != null) _sortByDistance();
        });
      }
    } catch (e) {
      debugPrint('❌ Find Labs error: $e');
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
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
                  const SizedBox(height: 12),

                  // ── Mode toggle: Nearest | Search by Location ──────────
                  Row(
                    children: [
                      _modeBtn('nearest', Icons.near_me_rounded, 'Nearest', const Color(0xFF8B5CF6)),
                      const SizedBox(width: 10),
                      _modeBtn('search', Icons.location_searching_rounded, 'Search by Location', const Color(0xFF8B5CF6)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nearest banner
                  if (_mode == 'nearest')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _userLat != null ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _userLat != null
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFFF59E0B).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _userLat != null ? Icons.my_location_rounded : Icons.location_searching_rounded,
                            size: 16,
                            color: _userLat != null ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _userLat != null
                                  ? 'Sorted by nearest to your location'
                                  : 'Allow location to see nearest labs first',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: _userLat != null ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Search field
                  if (_mode == 'search')
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _filterByLocation,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter area, city or address...',
                        prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF8B5CF6), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
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
                    children: widget.tests.map((t) {
                      final n = t is Map
                          ? (t['name'] ?? t['testName'] ?? '').toString()
                          : t.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Text(n,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
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
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 40),
                              const SizedBox(height: 12),
                              const Text('Could not load labs', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _fetchLabs,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredLabs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.science_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    _mode == 'search' ? 'No labs found in this area' : 'No labs found',
                                    style: const TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: _filteredLabs.length,
                              itemBuilder: (ctx, i) => _labTile(_filteredLabs[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String mode, IconData icon, String label, Color color) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mode = mode;
            _searchCtrl.clear();
            if (mode == 'nearest') {
              _filteredLabs = List.from(_labs);
              if (_userLat != null) _sortByDistance();
            } else {
              _filteredLabs = List.from(_labs);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  )),
            ],
          ),
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
    final distance = _getDistance(lab);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabDetails(
              labData: lab,
              prescribedTests: widget.tests.map((t) {
                if (t is String) return t;
                if (t is Map) return (t['name'] ?? t['testName'] ?? t['test_name'] ?? '').toString();
                return t.toString();
              }).where((n) => n.isNotEmpty).toList(),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
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
  List<dynamic> _filteredPharmacies = [];
  bool _isLoading = true;
  double? _userLat;
  double? _userLng;

  // 'nearest' or 'search'
  String _mode = 'nearest';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPharmacies();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final completer = Completer<List<double>?>();
      js.context['navigator']['geolocation'].callMethod('getCurrentPosition', [
        js.allowInterop((pos) {
          final coords = pos['coords'];
          completer.complete([
            (coords['latitude'] as num).toDouble(),
            (coords['longitude'] as num).toDouble(),
          ]);
        }),
        js.allowInterop((err) => completer.complete(null)),
      ]);
      final pos = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (pos != null && mounted) {
        setState(() {
          _userLat = pos[0];
          _userLng = pos[1];
          _sortByDistance();
        });
        _fetchPharmacies();
      }
    } catch (_) {}
  }

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _sortByDistance() {
    if (_userLat == null || _userLng == null) return;
    _pharmacies.sort((a, b) {
      final aLat = ((a['latitude'] ?? a['lat']) as num?)?.toDouble();
      final aLng = ((a['longitude'] ?? a['lng']) as num?)?.toDouble();
      final bLat = ((b['latitude'] ?? b['lat']) as num?)?.toDouble();
      final bLng = ((b['longitude'] ?? b['lng']) as num?)?.toDouble();
      if (aLat == null || aLng == null) return 1;
      if (bLat == null || bLng == null) return -1;
      return _haversineDistance(_userLat!, _userLng!, aLat, aLng)
          .compareTo(_haversineDistance(_userLat!, _userLng!, bLat, bLng));
    });
    _filteredPharmacies = List.from(_pharmacies);
  }

  void _filterByLocation(String query) {
    if (query.isEmpty) {
      setState(() => _filteredPharmacies = List.from(_pharmacies));
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredPharmacies = _pharmacies.where((p) {
        final name = (p['pharmacy_name'] ?? p['pharmacyName'] ?? p['name'] ?? '').toString().toLowerCase();
        final address = (p['address'] ?? '').toString().toLowerCase();
        final city = (p['city'] ?? '').toString().toLowerCase();
        return name.contains(q) || address.contains(q) || city.contains(q);
      }).toList();
    });
  }

  String? _getDistance(dynamic pharmacy) {
    if (_userLat == null || _userLng == null) return null;
    final lat = ((pharmacy['latitude'] ?? pharmacy['lat']) as num?)?.toDouble();
    final lng = ((pharmacy['longitude'] ?? pharmacy['lng']) as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    final dist = _haversineDistance(_userLat!, _userLng!, lat, lng);
    if (dist < 1) return '${(dist * 1000).toStringAsFixed(0)} m';
    return '${dist.toStringAsFixed(1)} km';
  }

  Future<void> _fetchPharmacies() async {
    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      if (mounted) {
        setState(() {
          _pharmacies = pharmacies;
          _filteredPharmacies = List.from(pharmacies);
          _isLoading = false;
          if (_userLat != null) _sortByDistance();
        });
      }
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            Text('Select a pharmacy for your medicines',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Mode toggle: Nearest | Search by Location ──────────
                  Row(
                    children: [
                      _modeBtn('nearest', Icons.near_me_rounded, 'Nearest', const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _modeBtn('search', Icons.location_searching_rounded, 'Search by Location', const Color(0xFF3B82F6)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Nearest: location status banner ───────────────────
                  if (_mode == 'nearest')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _userLat != null ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _userLat != null
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFFF59E0B).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _userLat != null ? Icons.my_location_rounded : Icons.location_searching_rounded,
                            size: 16,
                            color: _userLat != null ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _userLat != null
                                  ? 'Sorted by nearest to your location'
                                  : 'Allow location to see nearest pharmacies first',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: _userLat != null ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Search by Location: text field ────────────────────
                  if (_mode == 'search')
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _filterByLocation,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter area, city or address...',
                        prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF3B82F6), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),

                  const SizedBox(height: 12),
                  // Prescribed medicines chips
                  const Text('Prescribed Medicines:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: widget.medicines.map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(m['name'] ?? '',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPharmacies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_pharmacy_outlined, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                _mode == 'search' ? 'No pharmacies found in this area' : 'No pharmacies found',
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: _filteredPharmacies.length,
                          itemBuilder: (ctx, i) => _pharmacyTile(_filteredPharmacies[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String mode, IconData icon, String label, Color color) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mode = mode;
            _searchCtrl.clear();
            if (mode == 'nearest') {
              _filteredPharmacies = List.from(_pharmacies);
              if (_userLat != null) _sortByDistance();
            } else {
              _filteredPharmacies = List.from(_pharmacies);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  )),
            ],
          ),
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
    final distance = _getDistance(pharmacy);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyPrescriptionScreen(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
