// In-Consultation Prescription Form
// Complete prescription form to be filled DURING consultation
// As per client requirements - May 4, 2026

import 'package:flutter/material.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/models/enhanced_prescription.dart';
import 'package:icare/models/lifestyle_advice.dart';
import 'package:icare/screens/patient_history_form_screen.dart';
import 'package:icare/services/consultation_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/icd_code_selector.dart';

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
    extends State<InConsultationPrescriptionForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConsultationService _consultationService = ConsultationService();

  // Form Controllers
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _doctorNotesController = TextEditingController();

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
    _tabController = TabController(length: 9, vsync: this);
    _loadDraftIfExists();
  }

  Future<void> _loadDraftIfExists() async {
    // Load any existing draft prescription
    try {
      final result = await _consultationService.getPrescriptionDraft(
        widget.consultationId,
      );
      if (result['success'] && result['prescription'] != null) {
        final prescription = EnhancedPrescription.fromJson(result['prescription']);
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
        widget.consultationId,
        prescription.toJson(),
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
      final result = await _consultationService.completePrescription(
        widget.consultationId,
        prescription.toJson(),
      );

      if (result['success'] && mounted) {
        setState(() => _isComplete = true);
        widget.onPrescriptionComplete?.call(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete prescription: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
    _tabController.dispose();
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _doctorNotesController.dispose();
    super.dispose();
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
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
          else ...[
            TextButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Draft'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _completePrescription,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: '1. History'),
            Tab(text: '2. SOAP'),
            Tab(text: '3. Notes'),
            Tab(text: '4. Diagnosis'),
            Tab(text: '5. Medications'),
            Tab(text: '6. Lab Tests'),
            Tab(text: '7. Lifestyle'),
            Tab(text: '8. Referral'),
            Tab(text: '9. Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildSOAPTab(),
          _buildDoctorNotesTab(),
          _buildDiagnosisTab(),
          _buildMedicationsTab(),
          _buildLabTestsTab(),
          _buildLifestyleTab(),
          _buildReferralTab(),
          _buildCoursesTab(),
        ],
      ),
    );
  }

  // Tab 1: Patient History
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete comprehensive patient history form',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          if (_patientHistoryId != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Patient history completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openHistoryForm(),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _openHistoryForm(),
              icon: const Icon(Icons.add),
              label: const Text('Complete History Form'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ),
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

  // Tab 2: SOAP Notes
  Widget _buildSOAPTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOAP Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _subjectiveController,
            label: 'Subjective',
            hint: 'Patient\'s symptoms and complaints...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _objectiveController,
            label: 'Objective',
            hint: 'Clinical findings and observations...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _assessmentController,
            label: 'Assessment',
            hint: 'Clinical assessment and diagnosis...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _planController,
            label: 'Plan',
            hint: 'Treatment plan and recommendations...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // Tab 3: Doctor Notes
  Widget _buildDoctorNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Free text field for doctor\'s observations',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _doctorNotesController,
            label: 'Clinical Notes',
            hint: 'Enter your clinical observations and notes...',
            maxLines: 10,
          ),
        ],
      ),
    );
  }

  // Tab 4: Diagnosis
  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagnosis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addDiagnosis,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Diagnosis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_diagnoses.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No diagnoses added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_diagnoses.length, (index) {
              final diagnosis = _diagnoses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    diagnosis.diagnosis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('ICD-10: ${diagnosis.icd10Code}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() => _diagnoses.removeAt(index));
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _addDiagnosis() {
    showDialog(
      context: context,
      builder: (ctx) => ICDCodeSelector(
        onSelected: (code, description) {
          setState(() {
            _diagnoses.add(DiagnosisItem(
              diagnosis: description,
              icd10Code: code,
            ));
          });
        },
      ),
    );
  }

  // Tab 5: Medications
  Widget _buildMedicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addMedicine,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Medicine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_medicines.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medications added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_medicines.length, (index) {
              final medicine = _medicines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(Icons.medication, color: Colors.green),
                  ),
                  title: Text(
                    medicine.medicineName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${medicine.dose} - ${medicine.frequencyDisplay} - ${medicine.duration}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() => _medicines.removeAt(index));
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _addMedicine() {
    // TODO: Implement medicine selection dialog with British Pharmacopoeia
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine selection dialog - To be implemented with British Pharmacopoeia'),
      ),
    );
  }

  // Tab 6: Lab Tests
  Widget _buildLabTestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lab Tests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Common Tests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          ...CommonLabTests.tests.map((test) {
            final isSelected = _labTests.any((t) => t.testName == test);
            return CheckboxListTile(
              title: Text(test),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _labTests.add(LabTestItem(
                      testName: test,
                      isUrgent: false,
                    ));
                  } else {
                    _labTests.removeWhere((t) => t.testName == test);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // Tab 7: Lifestyle Advice
  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lifestyle Advice',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Provide lifestyle recommendations for the patient',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement lifestyle advice form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lifestyle advice form - To be implemented'),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Lifestyle Advice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 8: Referral & Follow-up
  Widget _buildReferralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Referral & Follow-up',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          // TODO: Implement referral and follow-up form
          const Text('Referral and follow-up form - To be implemented'),
        ],
      ),
    );
  }

  // Tab 9: Course Assignment
  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Assignment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Assign health awareness videos/courses to patient',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          // TODO: Implement course assignment
          const Text('Course assignment - To be implemented'),
        ],
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
}
