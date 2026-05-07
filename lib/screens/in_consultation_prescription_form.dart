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
      final result = await _consultationService.completePrescription(
        consultationId: widget.consultationId,
        prescriptionData: prescription.toJson(),
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
        onCodeSelected: (codeMap) {
          setState(() {
            _diagnoses.add(DiagnosisItem(
              diagnosis: codeMap['description']?.toString() ?? '',
              icd10Code: codeMap['code']?.toString() ?? '',
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
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    MedicationFrequency selectedFreq = MedicationFrequency.bd;
    String durationUnit = 'Days';

    final commonMeds = [
      'Paracetamol', 'Amoxicillin', 'Metformin', 'Amlodipine', 'Atorvastatin',
      'Omeprazole', 'Aspirin', 'Metoprolol', 'Lisinopril', 'Losartan',
      'Ciprofloxacin', 'Azithromycin', 'Prednisolone', 'Salbutamol', 'Cetirizine',
      'Pantoprazole', 'Clopidogrel', 'Glibenclamide', 'Insulin', 'Levothyroxine',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.medication_outlined, color: AppColors.primaryColor),
              SizedBox(width: 8),
              Text('Add Medication'),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (v) => v.text.isEmpty
                        ? const []
                        : commonMeds.where((m) => m.toLowerCase().contains(v.text.toLowerCase())),
                    fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
                      nameCtrl.text = ctrl.text;
                      return TextField(
                        controller: ctrl,
                        focusNode: focus,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        onChanged: (v) => nameCtrl.text = v,
                      );
                    },
                    onSelected: (v) => nameCtrl.text = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: doseCtrl,
                    decoration: InputDecoration(
                      labelText: 'Dose',
                      hintText: 'e.g. 500mg, 1 tablet',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MedicationFrequency>(
                    value: selectedFreq,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: MedicationFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(_freqLabel(f)))).toList(),
                    onChanged: (v) => setS(() => selectedFreq = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: durationCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Duration',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: durationUnit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: ['Days', 'Weeks', 'Months'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (v) => setS(() => durationUnit = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g. Take after meals',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final dur = durationCtrl.text.trim();
                  setState(() => _medicines.add(PrescriptionMedicine(
                    medicineName: name,
                    dose: doseCtrl.text.trim(),
                    frequency: selectedFreq,
                    duration: dur.isEmpty ? '' : '$dur $durationUnit',
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  )));
                }
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            ),
          ],
        ),
      ),
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
    final advice = _lifestyleAdvice;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lifestyle Advice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Provide lifestyle recommendations for the patient', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 20),

          // Quick templates row
          const Text('Quick Templates', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF475569))),
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
      ),
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
  Widget _buildReferralTab() {
    final ref = _referralFollowUp;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Referral & Follow-up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),

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
                  TextField(
                    controller: TextEditingController(text: ref?.referralSpecialty),
                    decoration: InputDecoration(
                      labelText: 'Specialty',
                      hintText: 'e.g. Cardiologist, Endocrinologist',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
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
          const Text('Course Assignment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Assign health awareness videos/courses to patient',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          if (_assignedCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.school_outlined, size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No courses assigned', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                    const SizedBox(height: 8),
                    const Text('Course catalogue will be provided by client',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_assignedCourses.length, (i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.play_circle_outlined, color: AppColors.primaryColor),
                title: Text(_assignedCourses[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => setState(() => _assignedCourses.removeAt(i)),
                ),
              ),
            )),
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
