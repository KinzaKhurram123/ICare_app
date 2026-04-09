import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icare/models/consultation.dart';
import 'package:icare/services/healthcare_workflow_service.dart';
import 'package:icare/utils/theme.dart';

/// Doctor Consultation Screen
///
/// This implements the STRUCTURED CLINICAL WORKFLOW:
/// Step 1: History (Chief Complaint, HPI, Past Medical History, etc.)
/// Step 2: Examination (Vital Signs, Physical Exam)
/// Step 3: Diagnosis (Primary Diagnosis, Differential Diagnosis)
/// Step 4: Plan (Prescriptions, Lab Tests, Health Programs, Referrals)
///
/// When consultation is completed, the Healthcare Workflow Engine
/// automatically triggers all connected modules.
class DoctorConsultationScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  final String patientId;

  const DoctorConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  @override
  ConsumerState<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState
    extends ConsumerState<DoctorConsultationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSaving = false;

  // Step 1: History
  final _chiefComplaintController = TextEditingController();
  final _hpiController = TextEditingController();
  final _pastMedicalHistoryController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  final _socialHistoryController = TextEditingController();

  // Step 2: Examination
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _generalAppearanceController = TextEditingController();
  final _examinationNotesController = TextEditingController();

  // Step 3: Diagnosis
  final _primaryDiagnosisController = TextEditingController();
  final _differentialDiagnosisController = TextEditingController();
  final _icdCodeController = TextEditingController();
  final _clinicalNotesController = TextEditingController();

  // Step 4: Plan
  final _instructionsController = TextEditingController();
  final _followUpInstructionsController = TextEditingController();
  DateTime? _followUpDate;

  // Plan items (will be managed through dialogs)
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _labTests = [];
  List<Map<String, dynamic>> _healthPrograms = [];
  Map<String, dynamic>? _referral;

  @override
  void dispose() {
    // Dispose all controllers
    _chiefComplaintController.dispose();
    _hpiController.dispose();
    _pastMedicalHistoryController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _familyHistoryController.dispose();
    _socialHistoryController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _respiratoryRateController.dispose();
    _oxygenSaturationController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _generalAppearanceController.dispose();
    _examinationNotesController.dispose();
    _primaryDiagnosisController.dispose();
    _differentialDiagnosisController.dispose();
    _icdCodeController.dispose();
    _clinicalNotesController.dispose();
    _instructionsController.dispose();
    _followUpInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clinical Consultation',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Gilroy-Bold',
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Patient ID: ${widget.patientId.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                fontFamily: 'Gilroy-Medium',
              ),
            ),
          ],
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveAsDraft,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Draft'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStepperContent(),
    );
  }

  Widget _buildStepperContent() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      onStepTapped: (step) => setState(() => _currentStep = step),
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: [
              if (_currentStep < 3)
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _completeConsultation,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: const Text('Complete Consultation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('History'),
          subtitle: const Text('Patient history & complaints'),
          content: _buildHistoryStep(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Examination'),
          subtitle: const Text('Vital signs & physical exam'),
          content: _buildExaminationStep(),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Diagnosis'),
          subtitle: const Text('Clinical diagnosis'),
          content: _buildDiagnosisStep(),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Plan'),
          subtitle: const Text('Treatment plan'),
          content: _buildPlanStep(),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildHistoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chief Complaint',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _chiefComplaintController,
          decoration: InputDecoration(
            hintText: 'What brings the patient in today?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'History of Present Illness (HPI)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hpiController,
          decoration: InputDecoration(
            hintText: 'Detailed description of current illness...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        const Text(
          'Past Medical History',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pastMedicalHistoryController,
          decoration: InputDecoration(
            hintText: 'Previous conditions, surgeries, hospitalizations...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        const Text(
          'Current Medications',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _medicationsController,
          decoration: InputDecoration(
            hintText: 'List current medications...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'Allergies',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _allergiesController,
          decoration: InputDecoration(
            hintText: 'Drug allergies, food allergies...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'Family History',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _familyHistoryController,
          decoration: InputDecoration(
            hintText: 'Relevant family medical history...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'Social History',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _socialHistoryController,
          decoration: InputDecoration(
            hintText: 'Smoking, alcohol, occupation, living situation...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildExaminationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vital Signs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BP Systolic (mmHg)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _bpSystolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '120',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BP Diastolic (mmHg)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _bpDiastolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '80',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Heart Rate (bpm)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _heartRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '72',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Temperature (°F)', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _temperatureController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '98.6',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'General Appearance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _generalAppearanceController,
          decoration: InputDecoration(
            hintText: 'Well-appearing, alert and oriented...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'Physical Examination Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _examinationNotesController,
          decoration: InputDecoration(
            hintText: 'Systemic examination findings...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDiagnosisStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Diagnosis',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _primaryDiagnosisController,
          decoration: InputDecoration(
            hintText: 'Main diagnosis...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'ICD Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _icdCodeController,
          decoration: InputDecoration(
            hintText: 'ICD-10 code...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Differential Diagnosis',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _differentialDiagnosisController,
          decoration: InputDecoration(
            hintText: 'Alternative diagnoses (comma-separated)...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const Text(
          'Clinical Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            fontFamily: 'Gilroy-Bold',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _clinicalNotesController,
          decoration: InputDecoration(
            hintText: 'Additional clinical observations...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildPlanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Treatment Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _addPrescription, child: const Text('Add Prescription')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _addLabTest, child: const Text('Order Lab Test')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _addHealthProgram, child: const Text('Assign Health Program')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _addReferral, child: const Text('Create Referral')),
        const SizedBox(height: 20),
        TextField(controller: _instructionsController, decoration: const InputDecoration(labelText: 'Instructions'), maxLines: 3),
      ],
    );
  }

  void _onStepContinue() { if (_currentStep < 3) setState(() => _currentStep++); }
  void _onStepCancel() { if (_currentStep > 0) setState(() => _currentStep--); }
  void _addPrescription() { setState(() => _prescriptions.add({'name': 'Medicine', 'dosage': '10mg', 'id': 'rx_1'})); }
  void _addLabTest() { setState(() => _labTests.add({'name': 'Blood Test', 'id': 'lab_1'})); }
  void _addHealthProgram() { setState(() => _healthPrograms.add({'name': 'Program', 'id': 'prog_1'})); }
  void _addReferral() { setState(() => _referral = {'specialty': 'Cardiology', 'id': 'ref_1'}); }

  Future<void> _completeConsultation() async {
    setState(() => _isSaving = true);
    try {
      final consultation = Consultation(
        id: 'c1', patientId: widget.patientId, doctorId: 'd1', appointmentId: widget.appointmentId,
        status: ConsultationStatus.completed, consultationDate: DateTime.now(),
        history: PatientHistory(chiefComplaint: _chiefComplaintController.text, historyOfPresentIllness: _hpiController.text,
          pastMedicalHistory: [], medications: [], allergies: [], familyHistory: '', socialHistory: ''),
        examination: PhysicalExamination(vitalSigns: VitalSigns(), generalAppearance: '', systemicExamination: {}, notes: ''),
        diagnosis: Diagnosis(primaryDiagnosis: _primaryDiagnosisController.text, differentialDiagnosis: [], icdCode: '', clinicalNotes: ''),
        plan: TreatmentPlan(prescriptionIds: [], labTestRequestIds: [], healthProgramIds: [], instructions: '', followUpInstructions: ''),
        createdAt: DateTime.now(), completedAt: DateTime.now(),
      );
      final workflowService = HealthcareWorkflowService();
      await workflowService.processConsultationCompletion(consultation);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation completed!')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAsDraft() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
      setState(() => _isSaving = false);
    }
  }
}
