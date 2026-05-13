// In-Consultation Prescription Form — Single Page Accordion
// Updated: May 11, 2026

import 'package:flutter/material.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/models/enhanced_prescription.dart';
import 'package:icare/models/lifestyle_advice.dart';
import 'package:icare/screens/patient_history_form_screen.dart';
import 'package:icare/services/consultation_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/services/icd_service.dart';

class InConsultationPrescriptionForm extends StatefulWidget {
  final AppointmentDetail appointment;
  final String consultationId;
  final Function(bool)? onPrescriptionComplete;

  const InConsultationPrescriptionForm({
    super.key,
    required this.appointment,
    required this.consultationId,
    this.onPrescriptionComplete,
  });

  @override
  State<InConsultationPrescriptionForm> createState() =>
      _InConsultationPrescriptionFormState();
}

class _InConsultationPrescriptionFormState
    extends State<InConsultationPrescriptionForm> {
  final ConsultationService _consultationService = ConsultationService();

  // Accordion expanded state (9 sections)
  // Open: Doctor's Notes (1), Diagnosis (3), Medications (4), Lab Tests (5) by default
  final List<bool> _expanded = [false, true, false, true, true, true, false, false, false];

  // Form Controllers
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _doctorNotesController = TextEditingController();

  // Diagnosis inline search state
  final TextEditingController _diagSearchController = TextEditingController();
  List<Map<String, dynamic>> _diagSearchResults = [];
  bool _diagSearching = false;

  // Lab test search filter
  final TextEditingController _labSearchController = TextEditingController();

  // Medicine search state
  final TextEditingController _medSearchController = TextEditingController();
  String? _selectedMedName;
  final TextEditingController _medDoseCtrl = TextEditingController();
  MedicationFrequency _medFreq = MedicationFrequency.bd;
  String _medDurationValue = '';
  String _medDurationUnit = 'Days';
  final TextEditingController _medNotesCtrl = TextEditingController();

  static const _commonMeds = [
    'Paracetamol 500mg', 'Paracetamol 1g', 'Amoxicillin 250mg', 'Amoxicillin 500mg',
    'Metformin 500mg', 'Metformin 1g', 'Amlodipine 5mg', 'Amlodipine 10mg',
    'Atorvastatin 10mg', 'Atorvastatin 20mg', 'Atorvastatin 40mg',
    'Omeprazole 20mg', 'Omeprazole 40mg', 'Pantoprazole 40mg',
    'Aspirin 75mg', 'Aspirin 150mg', 'Clopidogrel 75mg',
    'Metoprolol 25mg', 'Metoprolol 50mg', 'Lisinopril 5mg', 'Lisinopril 10mg',
    'Losartan 50mg', 'Losartan 100mg', 'Ciprofloxacin 500mg', 'Ciprofloxacin 250mg',
    'Azithromycin 250mg', 'Azithromycin 500mg', 'Prednisolone 5mg', 'Prednisolone 10mg',
    'Salbutamol 2mg', 'Salbutamol 4mg', 'Cetirizine 10mg', 'Levothyroxine 50mcg',
    'Levothyroxine 100mcg', 'Glibenclamide 5mg', 'Insulin (Regular)', 'Insulin (NPH)',
  ];

  // Data
  String? _patientHistoryId;
  List<DiagnosisItem> _diagnoses = [];
  List<PrescriptionMedicine> _medicines = [];
  List<LabTestItem> _labTests = [];
  LifestyleAdvice? _lifestyleAdvice;
  ReferralFollowUp? _referralFollowUp;
  List<String> _assignedCourses = [];

  bool _isSaving = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _loadDraftIfExists();
  }

  Future<void> _loadDraftIfExists() async {
    try {
      final result = await _consultationService.getPrescriptionDraft(
        widget.consultationId,
      );
      if (result != null && result['success'] == true && result['prescription'] != null) {
        final prescription = EnhancedPrescription.fromJson(result['prescription'] as Map<String, dynamic>);
        _populateFormWithDraft(prescription);
      }
    } catch (e) {
      // No draft exists, start fresh
    }
  }

  void _populateFormWithDraft(EnhancedPrescription prescription) {
    setState(() {
      _patientHistoryId = prescription.patientHistoryId;
      if (prescription.soapNotes != null) {
        _subjectiveController.text = prescription.soapNotes!.subjective;
        _objectiveController.text = prescription.soapNotes!.objective;
        _assessmentController.text = prescription.soapNotes!.assessment;
        _planController.text = prescription.soapNotes!.plan;
      }
      _doctorNotesController.text = prescription.doctorNotes;
      _diagnoses = prescription.diagnoses;
      _medicines = prescription.medicines;
      _labTests = prescription.labTests;
      _lifestyleAdvice = prescription.lifestyleAdvice;
      _referralFollowUp = prescription.referralFollowUp;
      _assignedCourses = prescription.assignedCourseIds;
      _isComplete = prescription.isComplete;
    });
  }

  Future<void> _saveDraft() async {
    setState(() => _isSaving = true);

    try {
      final prescription = _buildPrescriptionObject(isComplete: false);
      final result = await _consultationService.savePrescriptionDraft(
        consultationId: widget.consultationId,
        prescriptionData: prescription.toJson(),
      );

      if (result['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save draft: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _completePrescription() async {
    // Validate
    final prescription = _buildPrescriptionObject(isComplete: true);
    final validationError = prescription.validateCompletion();
    
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build minimal payload — only send fields backend can handle
      final payload = _buildMinimalPayload(prescription);

      final result = await _consultationService.completePrescription(
        consultationId: widget.consultationId,
        prescriptionData: payload,
      );

      if (result['success'] == true && mounted) {
        setState(() => _isComplete = true);
        widget.onPrescriptionComplete?.call(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription completed successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted) {
        final msg = result['message']?.toString() ?? result['error']?.toString() ?? 'Server error — please try again';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $msg'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Build minimal payload — only send what backend expects for /prescription/complete
  Map<String, dynamic> _buildMinimalPayload(EnhancedPrescription rx) {
    final payload = <String, dynamic>{
      'patientId': rx.patientId,
      'doctorId': rx.doctorId,
      'consultationId': rx.consultationId,
      'isComplete': true,
      'status': 'active',
      'prescribedAt': rx.prescribedAt.toIso8601String(),
    };

    // SOAP Notes — only if any content
    if (rx.soapNotes != null) {
      final s = rx.soapNotes!;
      if (s.subjective.isNotEmpty || s.objective.isNotEmpty || s.assessment.isNotEmpty || s.plan.isNotEmpty) {
        payload['soapNotes'] = {
          'subjective': s.subjective,
          'objective': s.objective,
          'assessment': s.assessment,
          'plan': s.plan,
        };
      }
    }

    // Doctor notes
    if (rx.doctorNotes.trim().isNotEmpty) {
      payload['doctorNotes'] = rx.doctorNotes.trim();
    }

    // Patient history
    if (rx.patientHistoryId != null && rx.patientHistoryId!.isNotEmpty) {
      payload['patientHistoryId'] = rx.patientHistoryId;
    }

    // Diagnoses — only non-empty
    if (rx.diagnoses.isNotEmpty) {
      payload['diagnoses'] = rx.diagnoses.map((d) => {
        'icd10Code': d.icd10Code,
        'diagnosis': d.diagnosis,
      }).toList();
    } else {
      payload['diagnoses'] = [];
    }

    // Medicines — only non-empty
    if (rx.medicines.isNotEmpty) {
      payload['medicines'] = rx.medicines.map((m) => {
        'medicineName': m.medicineName,
        'dose': m.dose,
        'frequency': m.frequency.toString().split('.').last,
        'duration': m.duration,
        if (m.notes != null && m.notes!.isNotEmpty) 'notes': m.notes,
      }).toList();
    } else {
      payload['medicines'] = [];
    }

    // Lab tests
    if (rx.labTests.isNotEmpty) {
      payload['labTests'] = rx.labTests.map((t) => {
        'testName': t.testName,
        'isUrgent': t.isUrgent,
      }).toList();
    } else {
      payload['labTests'] = [];
    }

    // Referral — only if not 'none'
    if (rx.referralFollowUp != null) {
      final ref = rx.referralFollowUp!;
      final refType = ref.referralType?.toString().split('.').last ?? 'none';
      final followUp = ref.followUpDuration?.toString().split('.').last ?? 'none';
      if (refType != 'none' || followUp != 'none') {
        payload['referralFollowUp'] = {
          'referralType': refType,
          if (ref.referralSpecialty?.isNotEmpty == true) 'referralSpecialty': ref.referralSpecialty,
          if (ref.referralNotes?.isNotEmpty == true) 'referralNotes': ref.referralNotes,
          'followUpDuration': followUp,
          if (ref.followUpNotes?.isNotEmpty == true) 'followUpNotes': ref.followUpNotes,
        };
      }
    }

    // Lifestyle — only if any meaningful content exists
    if (rx.lifestyleAdvice != null) {
      final la = rx.lifestyleAdvice!;
      final hasContent = (la.diet?.recommendations.isNotEmpty == true) ||
          (la.exercise?.type.isNotEmpty == true) ||
          (la.sleep?.recommendedHours.isNotEmpty == true) ||
          (la.stress?.recommendations.isNotEmpty == true) ||
          (la.otherAdvice.isNotEmpty);
      if (hasContent) {
        payload['lifestyleAdvice'] = _cleanJson(la.toJson());
      }
    }

    // Assigned courses
    if (rx.assignedCourseIds.isNotEmpty) {
      payload['assignedCourseIds'] = rx.assignedCourseIds;
    }

    return payload;
  }

  /// Recursively remove null values from JSON to avoid backend validation errors
  Map<String, dynamic> _cleanJson(Map<String, dynamic> json) {
    final result = <String, dynamic>{};
    json.forEach((key, value) {
      if (value == null) return;
      if (value is Map<String, dynamic>) {
        final cleaned = _cleanJson(value);
        if (cleaned.isNotEmpty) result[key] = cleaned;
      } else if (value is List) {
        final cleanedList = value.map((item) {
          if (item is Map<String, dynamic>) return _cleanJson(item);
          return item;
        }).where((item) => item != null).toList();
        result[key] = cleanedList;
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  EnhancedPrescription _buildPrescriptionObject({required bool isComplete}) {
    return EnhancedPrescription(
      patientId: widget.appointment.patient!.id,
      doctorId: widget.appointment.doctor!.id,
      consultationId: widget.consultationId,
      patientHistoryId: _patientHistoryId,
      soapNotes: SOAPNotes(
        subjective: _subjectiveController.text,
        objective: _objectiveController.text,
        assessment: _assessmentController.text,
        plan: _planController.text,
      ),
      doctorNotes: _doctorNotesController.text,
      diagnoses: _diagnoses,
      medicines: _medicines,
      labTests: _labTests,
      lifestyleAdvice: _lifestyleAdvice,
      referralFollowUp: _referralFollowUp,
      assignedCourseIds: _assignedCourses,
      status: isComplete ? PrescriptionStatus.active : PrescriptionStatus.draft,
      isComplete: isComplete,
      prescribedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _doctorNotesController.dispose();
    super.dispose();
  }

  // ── Accordion helper ──────────────────────────────────────────────────────
  Widget _accordion({
    required int index,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget child,
    int? badgeCount,
  }) {
    final isOpen = _expanded[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen ? color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
          width: isOpen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header — tap to expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded[index] = !isOpen),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            if (badgeCount != null && badgeCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('$badgeCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ],
                        ),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: isOpen ? color : const Color(0xFF94A3B8),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isOpen) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
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
          'Prescription Form',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            TextButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Draft'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: _completePrescription,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Patient info strip ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: AppColors.primaryColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.appointment.patient?.name ?? 'Patient'}  •  Consultation ID: ${widget.consultationId.length >= 6 ? widget.consultationId.substring(widget.consultationId.length - 6).toUpperCase() : widget.consultationId}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  if (_isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 13),
                          SizedBox(width: 4),
                          Text('Complete', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── 1. Patient History ──────────────────────────────────────
            _accordion(
              index: 0,
              icon: Icons.history_edu_rounded,
              color: const Color(0xFF6366F1),
              title: '1. Patient History',
              subtitle: _patientHistoryId != null ? 'Completed ✓' : 'Complete patient history form',
              child: _buildHistoryContent(),
            ),

            // ── 2. Doctor's Notes (SOAP) — Required ────────────────────
            _accordion(
              index: 1,
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF0EA5E9),
              title: "2. Doctor's Notes *",
              subtitle: 'Required — SOAP notes',
              child: _buildSOAPContent(),
            ),

            // ── 3. Additional Notes — Required ──────────────────────────
            _accordion(
              index: 2,
              icon: Icons.notes_rounded,
              color: const Color(0xFF64748B),
              title: '3. Additional Notes *',
              subtitle: 'Required — clinical observations',
              child: _buildDoctorNotesContent(),
            ),

            // ── 4. Diagnosis — Required ─────────────────────────────────
            _accordion(
              index: 3,
              icon: Icons.medical_information_rounded,
              color: const Color(0xFFEF4444),
              title: '4. Diagnosis *',
              subtitle: 'Required — ICD-10 codes and diagnosis',
              badgeCount: _diagnoses.length,
              child: _buildDiagnosisContent(),
            ),

            // ── 5. Medications ──────────────────────────────────────────
            _accordion(
              index: 4,
              icon: Icons.medication_rounded,
              color: const Color(0xFF10B981),
              title: '5. Medications',
              subtitle: 'Prescribe medicines with dose & frequency',
              badgeCount: _medicines.length,
              child: _buildMedicationsContent(),
            ),

            // ── 6. Lab Tests ────────────────────────────────────────────
            _accordion(
              index: 5,
              icon: Icons.biotech_rounded,
              color: const Color(0xFF8B5CF6),
              title: '6. Lab Tests',
              subtitle: 'Order diagnostic tests',
              badgeCount: _labTests.length,
              child: _buildLabTestsContent(),
            ),

            // ── 7. Lifestyle Advice (Optional) ─────────────────────────
            _accordion(
              index: 6,
              icon: Icons.spa_rounded,
              color: const Color(0xFFF59E0B),
              title: '7. Lifestyle Advice (Optional)',
              subtitle: 'Diet, exercise, sleep recommendations',
              child: _buildLifestyleContent(),
            ),

            // ── 8. Referral & Follow-up ─────────────────────────────────
            _accordion(
              index: 7,
              icon: Icons.event_repeat_rounded,
              color: const Color(0xFFEC4899),
              title: '8. Referral & Follow-up',
              subtitle: 'Specialist referral and follow-up schedule',
              child: _buildReferralContent(),
            ),

            // ── 9. Course Assignment ────────────────────────────────────
            _accordion(
              index: 8,
              icon: Icons.school_rounded,
              color: const Color(0xFF06B6D4),
              title: '9. Course Assignment',
              subtitle: 'Assign health awareness courses',
              badgeCount: _assignedCourses.length,
              child: _buildCoursesContent(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Section 1: Patient History ───────────────────────────────────────────
  Widget _buildHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_patientHistoryId != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text('Patient history completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                TextButton(onPressed: _openHistoryForm, child: const Text('Edit')),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _openHistoryForm,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Complete History Form'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  void _openHistoryForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PatientHistoryFormScreen(
          appointment: widget.appointment,
          consultationId: widget.consultationId,
          onHistoryComplete: (historyId) {
            setState(() => _patientHistoryId = historyId);
          },
        ),
      ),
    );
  }

  // ── Section 2: SOAP Notes ─────────────────────────────────────────────────
  Widget _buildSOAPContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(controller: _subjectiveController, label: 'Subjective', hint: "Patient's symptoms and complaints...", maxLines: 3),
        const SizedBox(height: 12),
        _buildTextField(controller: _objectiveController, label: 'Objective', hint: 'Clinical findings and observations...', maxLines: 3),
        const SizedBox(height: 12),
        _buildTextField(controller: _assessmentController, label: 'Assessment', hint: 'Clinical assessment and diagnosis...', maxLines: 3),
        const SizedBox(height: 12),
        _buildTextField(controller: _planController, label: 'Plan', hint: 'Treatment plan and recommendations...', maxLines: 3),
      ],
    );
  }

  // ── Section 4: Diagnosis ──────────────────────────────────────────────────
  Widget _buildDiagnosisContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline ICD-10 search bar
        TextField(
          controller: _diagSearchController,
          onChanged: _searchICD,
          decoration: InputDecoration(
            hintText: 'Search ICD-10 code or diagnosis name...',
            prefixIcon: _diagSearching
                ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                : const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
            suffixIcon: _diagSearchController.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() { _diagSearchController.clear(); _diagSearchResults = []; }))
                : null,
            filled: true,
            fillColor: const Color(0xFFFEF2F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFCA5A5))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFCA5A5))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        // Search results
        if (_diagSearchResults.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: _diagSearchResults.take(6).map((code) => InkWell(
                onTap: () {
                  final desc = code['description']?.toString() ?? '';
                  final icd = code['code']?.toString() ?? '';
                  if (desc.isNotEmpty) {
                    setState(() {
                      _diagnoses.add(DiagnosisItem(diagnosis: desc, icd10Code: icd));
                      _diagSearchController.clear();
                      _diagSearchResults = [];
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                        child: Text(code['code']?.toString() ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(code['description']?.toString() ?? '', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (_diagnoses.isEmpty)
          _emptyState(Icons.medical_information_outlined, 'Search and add diagnoses above')
        else
          ...List.generate(_diagnoses.length, (index) {
            final d = _diagnoses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(6)),
                    child: Text(d.icd10Code, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(d.diagnosis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => setState(() => _diagnoses.removeAt(index)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Future<void> _searchICD(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _diagSearchResults = []; _diagSearching = false; });
      return;
    }
    setState(() => _diagSearching = true);
    try {
      final results = await ICDService.searchICDCodes(query);
      if (mounted) setState(() { _diagSearchResults = List<Map<String, dynamic>>.from(results); _diagSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _diagSearching = false);
    }
  }

  // ── Section 5: Medications ────────────────────────────────────────────────
  Widget _buildMedicationsContent() {
    final searchText = _medSearchController.text.toLowerCase();
    final suggestions = searchText.isEmpty
        ? <String>[]
        : _commonMeds.where((m) => m.toLowerCase().contains(searchText)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _medSearchController,
          onChanged: (_) => setState(() => _selectedMedName = null),
          decoration: InputDecoration(
            hintText: 'Search medicine (e.g. Paracetamol, Amoxicillin)...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
            suffixIcon: _medSearchController.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() { _medSearchController.clear(); _selectedMedName = null; }))
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        // Suggestions
        if (suggestions.isNotEmpty && _selectedMedName == null) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: suggestions.take(6).map((med) => InkWell(
                onTap: () => setState(() {
                  _selectedMedName = med;
                  _medSearchController.text = med;
                  _medDoseCtrl.clear();
                  _medFreq = MedicationFrequency.bd;
                  _medDurationValue = '';
                  _medDurationUnit = 'Days';
                  _medNotesCtrl.clear();
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_outlined, size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 10),
                      Text(med, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
        // Dosage form (shown when medicine selected)
        if (_selectedMedName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medication_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_selectedMedName!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF065F46)))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _medDoseCtrl,
                  decoration: InputDecoration(
                    labelText: 'Dose',
                    hintText: 'e.g. 500mg, 250mg, 1g',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true, fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<MedicationFrequency>(
                  value: _medFreq,
                  decoration: InputDecoration(labelText: 'Frequency', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
                  items: MedicationFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(_freqLabel(f)))).toList(),
                  onChanged: (v) => setState(() => _medFreq = v!),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(flex: 2, child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _medDurationValue = v,
                    decoration: InputDecoration(labelText: 'Duration', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(
                    value: _medDurationUnit,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: ['Days', 'Weeks', 'Months'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _medDurationUnit = v!),
                  )),
                ]),
                const SizedBox(height: 10),
                TextField(
                  controller: _medNotesCtrl,
                  decoration: InputDecoration(labelText: 'Notes (optional)', hintText: 'e.g. Take after meals', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  TextButton(onPressed: () => setState(() { _selectedMedName = null; _medSearchController.clear(); }), child: const Text('Cancel')),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedMedName != null) {
                        setState(() {
                          _medicines.add(PrescriptionMedicine(
                            medicineName: _selectedMedName!,
                            dose: _medDoseCtrl.text.trim(),
                            frequency: _medFreq,
                            duration: _medDurationValue.isEmpty ? '' : '$_medDurationValue $_medDurationUnit',
                            notes: _medNotesCtrl.text.trim().isEmpty ? null : _medNotesCtrl.text.trim(),
                          ));
                          _selectedMedName = null;
                          _medSearchController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add to Prescription'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ]),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_medicines.isEmpty)
          _emptyState(Icons.medication_outlined, 'Search and add medications above')
        else
          ...List.generate(_medicines.length, (index) {
            final m = _medicines[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.medicineName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('${m.dose} · ${m.frequencyDisplay} · ${m.duration}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => setState(() => _medicines.removeAt(index)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _freqLabel(MedicationFrequency f) {
    switch (f) {
      case MedicationFrequency.od: return 'OD – Once Daily';
      case MedicationFrequency.bd: return 'BD – Twice Daily';
      case MedicationFrequency.tds: return 'TDS – Three Times Daily';
      case MedicationFrequency.qid: return 'QID – Four Times Daily';
      case MedicationFrequency.sos: return 'SOS – As Needed';
      case MedicationFrequency.stat: return 'STAT – Immediately';
      case MedicationFrequency.weekly: return 'Weekly';
      case MedicationFrequency.monthly: return 'Monthly';
    }
  }

  // ── Section 6: Lab Tests ──────────────────────────────────────────────────
  Widget _buildLabTestsContent() {
    final filterText = _labSearchController.text.toLowerCase();
    final filteredTests = filterText.isEmpty
        ? CommonLabTests.tests
        : CommonLabTests.tests.where((t) => t.toLowerCase().contains(filterText)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _labSearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search lab test...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
            suffixIcon: _labSearchController.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() => _labSearchController.clear()))
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F3FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDD6FE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDDD6FE))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        if (_labTests.isNotEmpty) ...[
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _labTests.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t.testName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _labTests.removeWhere((x) => x.testName == t.testName)),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 14),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 4),
        ],
        if (filteredTests.isEmpty)
          const Padding(padding: EdgeInsets.all(12), child: Text('No tests match', style: TextStyle(color: Color(0xFF94A3B8)))),
        ...filteredTests.map((test) {
          final isSelected = _labTests.any((t) => t.testName == test);
          return CheckboxListTile(
            dense: true,
            title: Text(test, style: const TextStyle(fontSize: 13)),
            value: isSelected,
            activeColor: const Color(0xFF8B5CF6),
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _labTests.add(LabTestItem(testName: test, isUrgent: false));
                } else {
                  _labTests.removeWhere((t) => t.testName == test);
                }
              });
            },
          );
        }),
      ],
    );
  }

  // ── Section 7: Lifestyle Advice ──────────────────────────────────────────
  Widget _buildLifestyleContent() {
    final advice = _lifestyleAdvice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick templates row
        const Text('Quick Templates', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LifestyleAdviceTemplates.dietTemplates.map((t) => ActionChip(
            label: Text(t['name'] as String),
            avatar: const Icon(Icons.restaurant_outlined, size: 14),
              onPressed: () => _applyDietTemplate(t),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Diet Advice
          _lifestyleSection(
            title: 'Diet Advice',
            icon: Icons.restaurant_outlined,
            color: const Color(0xFF10B981),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lifestyleField('Recommendations', advice?.diet?.recommendations ?? '', (v) => _updateLifestyleAdvice(dietRec: v)),
              const SizedBox(height: 10),
              _lifestyleField('Foods to Avoid', advice?.diet?.foodsToAvoid.join(', ') ?? '', (v) => _updateLifestyleAdvice(dietAvoid: v)),
              const SizedBox(height: 10),
              _lifestyleField('Foods to Include', advice?.diet?.foodsToInclude.join(', ') ?? '', (v) => _updateLifestyleAdvice(dietInclude: v)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _lifestyleField('Meal Timing', advice?.diet?.mealTiming ?? '', (v) => _updateLifestyleAdvice(mealTiming: v))),
                  const SizedBox(width: 12),
                  Expanded(child: _lifestyleField('Hydration', advice?.diet?.hydration ?? '', (v) => _updateLifestyleAdvice(hydration: v))),
                ],
              ),
            ]),
          ),

          // Exercise Advice
          _lifestyleSection(
            title: 'Exercise Advice',
            icon: Icons.fitness_center_outlined,
            color: const Color(0xFF3B82F6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: LifestyleAdviceTemplates.exerciseTemplates.map((t) => ActionChip(
                  label: Text(t['name'] as String, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _applyExerciseTemplate(t),
                )).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _lifestyleField('Type', advice?.exercise?.type ?? '', (v) => _updateLifestyleAdvice(exerciseType: v))),
                  const SizedBox(width: 12),
                  Expanded(child: _lifestyleField('Frequency', advice?.exercise?.frequency ?? '', (v) => _updateLifestyleAdvice(exerciseFreq: v))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _lifestyleField('Duration', advice?.exercise?.duration ?? '', (v) => _updateLifestyleAdvice(exerciseDur: v))),
                  const SizedBox(width: 12),
                  Expanded(child: _lifestyleField('Intensity', advice?.exercise?.intensity ?? '', (v) => _updateLifestyleAdvice(exerciseIntensity: v))),
                ],
              ),
              const SizedBox(height: 10),
              _lifestyleField('Precautions', advice?.exercise?.precautions.join(', ') ?? '', (v) => _updateLifestyleAdvice(exercisePrecautions: v)),
            ]),
          ),

          // Sleep Advice
          _lifestyleSection(
            title: 'Sleep Advice',
            icon: Icons.bedtime_outlined,
            color: const Color(0xFF8B5CF6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: LifestyleAdviceTemplates.sleepTemplates.map((t) => ActionChip(
                  label: Text(t['name'] as String, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _applySleepTemplate(t),
                )).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _lifestyleField('Recommended Hours', advice?.sleep?.recommendedHours ?? '', (v) => _updateLifestyleAdvice(sleepHours: v))),
                  const SizedBox(width: 12),
                  Expanded(child: _lifestyleField('Sleep Schedule', advice?.sleep?.sleepSchedule ?? '', (v) => _updateLifestyleAdvice(sleepSchedule: v))),
                ],
              ),
              const SizedBox(height: 10),
              _lifestyleField('Sleep Hygiene Tips', advice?.sleep?.sleepHygieneTips.join(', ') ?? '', (v) => _updateLifestyleAdvice(sleepTips: v)),
            ]),
          ),

          // Stress Management
          _lifestyleSection(
            title: 'Stress Management',
            icon: Icons.spa_outlined,
            color: const Color(0xFFF59E0B),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: LifestyleAdviceTemplates.stressTemplates.map((t) => ActionChip(
                  label: Text(t['name'] as String, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _applyStressTemplate(t),
                )).toList(),
              ),
              const SizedBox(height: 10),
              _lifestyleField('Techniques', advice?.stress?.techniques.join(', ') ?? '', (v) => _updateLifestyleAdvice(stressTechniques: v)),
              const SizedBox(height: 10),
              _lifestyleField('Recommendations', advice?.stress?.recommendations ?? '', (v) => _updateLifestyleAdvice(stressRec: v)),
            ]),
          ),

          // Other Advice
          _lifestyleSection(
            title: 'Other Advice',
            icon: Icons.note_alt_outlined,
            color: const Color(0xFF64748B),
            child: _lifestyleField(
              'Additional Recommendations',
              _lifestyleAdvice?.otherAdvice.join('\n') ?? '',
              (v) => _updateLifestyleAdvice(otherAdvice: v),
              maxLines: 4,
            ),
          ),
        ],
      );
  }

  Widget _lifestyleSection({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  Widget _lifestyleField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: value),
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  void _applyDietTemplate(Map<String, dynamic> t) {
    setState(() {
      _lifestyleAdvice = LifestyleAdvice(
        consultationId: widget.consultationId,
        prescriptionId: '',
        diet: DietAdvice(
          recommendations: t['recommendations'] as String,
          foodsToAvoid: List<String>.from(t['foodsToAvoid'] as List),
          foodsToInclude: List<String>.from(t['foodsToInclude'] as List),
          mealTiming: t['mealTiming'] as String,
          hydration: t['hydration'] as String,
        ),
        exercise: _lifestyleAdvice?.exercise,
        sleep: _lifestyleAdvice?.sleep,
        stress: _lifestyleAdvice?.stress,
        smoking: _lifestyleAdvice?.smoking,
        alcohol: _lifestyleAdvice?.alcohol,
        weight: _lifestyleAdvice?.weight,
        otherAdvice: _lifestyleAdvice?.otherAdvice ?? [],
        createdAt: DateTime.now(),
      );
    });
  }

  void _applyExerciseTemplate(Map<String, dynamic> t) {
    setState(() {
      _lifestyleAdvice = LifestyleAdvice(
        consultationId: widget.consultationId,
        prescriptionId: '',
        diet: _lifestyleAdvice?.diet,
        exercise: ExerciseAdvice(
          type: t['type'] as String,
          frequency: t['frequency'] as String,
          duration: t['duration'] as String,
          intensity: t['intensity'] as String,
          precautions: List<String>.from(t['precautions'] as List),
        ),
        sleep: _lifestyleAdvice?.sleep,
        stress: _lifestyleAdvice?.stress,
        smoking: _lifestyleAdvice?.smoking,
        alcohol: _lifestyleAdvice?.alcohol,
        weight: _lifestyleAdvice?.weight,
        otherAdvice: _lifestyleAdvice?.otherAdvice ?? [],
        createdAt: DateTime.now(),
      );
    });
  }

  void _applySleepTemplate(Map<String, dynamic> t) {
    setState(() {
      _lifestyleAdvice = LifestyleAdvice(
        consultationId: widget.consultationId,
        prescriptionId: '',
        diet: _lifestyleAdvice?.diet,
        exercise: _lifestyleAdvice?.exercise,
        sleep: SleepAdvice(
          recommendedHours: t['recommendedHours'] as String,
          sleepSchedule: t['sleepSchedule'] as String,
          sleepHygieneTips: List<String>.from(t['sleepHygieneTips'] as List),
        ),
        stress: _lifestyleAdvice?.stress,
        smoking: _lifestyleAdvice?.smoking,
        alcohol: _lifestyleAdvice?.alcohol,
        weight: _lifestyleAdvice?.weight,
        otherAdvice: _lifestyleAdvice?.otherAdvice ?? [],
        createdAt: DateTime.now(),
      );
    });
  }

  void _applyStressTemplate(Map<String, dynamic> t) {
    setState(() {
      _lifestyleAdvice = LifestyleAdvice(
        consultationId: widget.consultationId,
        prescriptionId: '',
        diet: _lifestyleAdvice?.diet,
        exercise: _lifestyleAdvice?.exercise,
        sleep: _lifestyleAdvice?.sleep,
        stress: StressManagement(
          techniques: List<String>.from(t['techniques'] as List),
          recommendations: t['recommendations'] as String,
        ),
        smoking: _lifestyleAdvice?.smoking,
        alcohol: _lifestyleAdvice?.alcohol,
        weight: _lifestyleAdvice?.weight,
        otherAdvice: _lifestyleAdvice?.otherAdvice ?? [],
        createdAt: DateTime.now(),
      );
    });
  }

  void _updateLifestyleAdvice({
    String? dietRec, String? dietAvoid, String? dietInclude, String? mealTiming, String? hydration,
    String? exerciseType, String? exerciseFreq, String? exerciseDur, String? exerciseIntensity, String? exercisePrecautions,
    String? sleepHours, String? sleepSchedule, String? sleepTips,
    String? stressTechniques, String? stressRec,
    String? otherAdvice,
  }) {
    final existing = _lifestyleAdvice;
    setState(() {
      _lifestyleAdvice = LifestyleAdvice(
        consultationId: widget.consultationId,
        prescriptionId: existing?.prescriptionId ?? '',
        diet: DietAdvice(
          recommendations: dietRec ?? existing?.diet?.recommendations ?? '',
          foodsToAvoid: dietAvoid != null ? dietAvoid.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : existing?.diet?.foodsToAvoid ?? [],
          foodsToInclude: dietInclude != null ? dietInclude.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : existing?.diet?.foodsToInclude ?? [],
          mealTiming: mealTiming ?? existing?.diet?.mealTiming ?? '',
          hydration: hydration ?? existing?.diet?.hydration ?? '',
        ),
        exercise: ExerciseAdvice(
          type: exerciseType ?? existing?.exercise?.type ?? '',
          frequency: exerciseFreq ?? existing?.exercise?.frequency ?? '',
          duration: exerciseDur ?? existing?.exercise?.duration ?? '',
          intensity: exerciseIntensity ?? existing?.exercise?.intensity ?? '',
          precautions: exercisePrecautions != null ? exercisePrecautions.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : existing?.exercise?.precautions ?? [],
        ),
        sleep: SleepAdvice(
          recommendedHours: sleepHours ?? existing?.sleep?.recommendedHours ?? '',
          sleepSchedule: sleepSchedule ?? existing?.sleep?.sleepSchedule ?? '',
          sleepHygieneTips: sleepTips != null ? sleepTips.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : existing?.sleep?.sleepHygieneTips ?? [],
        ),
        stress: StressManagement(
          techniques: stressTechniques != null ? stressTechniques.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : existing?.stress?.techniques ?? [],
          recommendations: stressRec ?? existing?.stress?.recommendations ?? '',
        ),
        smoking: existing?.smoking,
        alcohol: existing?.alcohol,
        weight: existing?.weight,
        otherAdvice: otherAdvice != null ? otherAdvice.split('\n').where((s) => s.isNotEmpty).toList() : existing?.otherAdvice ?? [],
        createdAt: existing?.createdAt ?? DateTime.now(),
      );
    });
  }

  // Tab 8: Referral & Follow-up
  // ── Section 8: Referral & Follow-up ──────────────────────────────────────
  Widget _buildReferralContent() {
    final ref = _referralFollowUp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Referral Type
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Referral', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569))),
              const SizedBox(height: 12),
              DropdownButtonFormField<ReferralType>(
                value: ref?.referralType ?? ReferralType.none,
                decoration: InputDecoration(
                  labelText: 'Referral Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  items: const [
                    DropdownMenuItem(value: ReferralType.none, child: Text('No Referral')),
                    DropdownMenuItem(value: ReferralType.emergency, child: Text('Refer to Emergency')),
                    DropdownMenuItem(value: ReferralType.hospital, child: Text('Refer to Hospital')),
                    DropdownMenuItem(value: ReferralType.specialist, child: Text('Refer to Specialist')),
                  ],
                  onChanged: (v) => setState(() {
                    _referralFollowUp = ReferralFollowUp(
                      referralType: v,
                      referralSpecialty: ref?.referralSpecialty,
                      referralNotes: ref?.referralNotes,
                      followUpDuration: ref?.followUpDuration,
                      followUpDate: ref?.followUpDate,
                      followUpNotes: ref?.followUpNotes,
                    );
                  }),
                ),
                if (ref?.referralType == ReferralType.specialist) ...[
                  const SizedBox(height: 12),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: ref?.referralSpecialty ?? ''),
                    optionsBuilder: (v) {
                      const specs = [
                        'Cardiologist', 'Endocrinologist', 'Neurologist', 'Pulmonologist',
                        'Gastroenterologist', 'Nephrologist', 'Rheumatologist', 'Oncologist',
                        'Hematologist', 'Dermatologist', 'Ophthalmologist', 'ENT Specialist',
                        'Orthopedic Surgeon', 'Urologist', 'Psychiatrist', 'Pediatrician',
                        'Gynecologist', 'Obstetrician', 'General Surgeon', 'Vascular Surgeon',
                        'Diabetologist', 'Hepatologist', 'Immunologist', 'Pathologist',
                      ];
                      if (v.text.isEmpty) return specs;
                      return specs.where((s) => s.toLowerCase().contains(v.text.toLowerCase()));
                    },
                    onSelected: (v) => setState(() {
                      _referralFollowUp = ReferralFollowUp(
                        referralType: ref?.referralType,
                        referralSpecialty: v,
                        referralNotes: ref?.referralNotes,
                        followUpDuration: ref?.followUpDuration,
                        followUpDate: ref?.followUpDate,
                        followUpNotes: ref?.followUpNotes,
                      );
                    }),
                    fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextField(
                      controller: ctrl,
                      focusNode: focus,
                      decoration: InputDecoration(
                        labelText: 'Search Specialty',
                        hintText: 'e.g. Cardiologist, Neurologist',
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: const Color(0xFFF8FAFC),
                      ),
                      onChanged: (v) => setState(() {
                        _referralFollowUp = ReferralFollowUp(
                          referralType: ref?.referralType,
                          referralSpecialty: v.isEmpty ? null : v,
                          referralNotes: ref?.referralNotes,
                          followUpDuration: ref?.followUpDuration,
                          followUpDate: ref?.followUpDate,
                          followUpNotes: ref?.followUpNotes,
                        );
                      }),
                    ),
                  ),
                ],
                if ((ref?.referralType ?? ReferralType.none) != ReferralType.none) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: ref?.referralNotes),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Referral Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    onChanged: (v) => setState(() {
                      _referralFollowUp = ReferralFollowUp(
                        referralType: ref?.referralType,
                        referralSpecialty: ref?.referralSpecialty,
                        referralNotes: v.isEmpty ? null : v,
                        followUpDuration: ref?.followUpDuration,
                        followUpDate: ref?.followUpDate,
                        followUpNotes: ref?.followUpNotes,
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Follow-up
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Follow-up', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569))),
                const SizedBox(height: 12),
                DropdownButtonFormField<FollowUpDuration>(
                  value: ref?.followUpDuration ?? FollowUpDuration.none,
                  decoration: InputDecoration(
                    labelText: 'Follow-up Duration',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  items: FollowUpDuration.values.map((d) => DropdownMenuItem(value: d, child: Text(d.display))).toList(),
                  onChanged: (v) => setState(() {
                    _referralFollowUp = ReferralFollowUp(
                      referralType: ref?.referralType,
                      referralSpecialty: ref?.referralSpecialty,
                      referralNotes: ref?.referralNotes,
                      followUpDuration: v,
                      followUpDate: ref?.followUpDate,
                      followUpNotes: ref?.followUpNotes,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: ref?.followUpNotes),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Follow-up Notes',
                    hintText: 'Any specific instructions for follow-up...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  onChanged: (v) => setState(() {
                    _referralFollowUp = ReferralFollowUp(
                      referralType: ref?.referralType,
                      referralSpecialty: ref?.referralSpecialty,
                      referralNotes: ref?.referralNotes,
                      followUpDuration: ref?.followUpDuration,
                      followUpDate: ref?.followUpDate,
                      followUpNotes: v.isEmpty ? null : v,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      );
  }

  // ── Section 9: Course Assignment ─────────────────────────────────────────
  Widget _buildCoursesContent() {
    const availableCourses = [
      'Diabetes Management Basics',
      'Hypertension & Heart Health',
      'Healthy Diet & Nutrition',
      'Exercise for Chronic Conditions',
      'Mental Wellness & Stress Relief',
      'Quit Smoking Program',
      'Weight Loss Journey',
      'Kidney Health Awareness',
      'Asthma Self-Management',
      'Thyroid Health Guide',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign Health Courses to Patient',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569))),
        const SizedBox(height: 12),
        ...availableCourses.map((course) {
          final isAssigned = _assignedCourses.contains(course);
          return CheckboxListTile(
            dense: true,
            title: Row(children: [
              const Icon(Icons.play_circle_outlined, size: 18, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              Expanded(child: Text(course, style: const TextStyle(fontSize: 13))),
            ]),
            value: isAssigned,
            activeColor: const Color(0xFF06B6D4),
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() {
              if (v == true) _assignedCourses.add(course);
              else _assignedCourses.remove(course);
            }),
          );
        }),
        if (_assignedCourses.isNotEmpty) ...[
          const Divider(height: 24),
          Text('${_assignedCourses.length} course${_assignedCourses.length > 1 ? 's' : ''} assigned',
              style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Section 3: Additional Notes ───────────────────────────────────────────
  Widget _buildDoctorNotesContent() {
    return _buildTextField(
      controller: _doctorNotesController,
      label: 'Clinical Notes',
      hint: 'Enter your clinical observations and notes...',
      maxLines: 6,
    );
  }
}
