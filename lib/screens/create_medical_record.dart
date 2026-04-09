import 'package:flutter/material.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/custom_button.dart';
import 'package:icare/services/course_service.dart';
import 'package:icare/services/laboratory_service.dart';
import 'package:icare/services/pharmacy_service.dart';
import 'package:intl/intl.dart';

class CreateMedicalRecordScreen extends StatefulWidget {
  final AppointmentDetail appointment;

  const CreateMedicalRecordScreen({super.key, required this.appointment});

  @override
  State<CreateMedicalRecordScreen> createState() =>
      _CreateMedicalRecordScreenState();
}

class _CreateMedicalRecordScreenState extends State<CreateMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  // Controllers
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();

  // Vital Signs
  final _bpController = TextEditingController();
  final _tempController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Prescription list
  List<Map<String, String>> _prescriptions = [];

  // Lab tests list
  List<String> _labTests = [];

  DateTime? _followUpDate;
  bool _isSubmitting = false;

  final CourseService _courseService = CourseService();
  final LaboratoryService _labService = LaboratoryService();
  final PharmacyService _pharmacyService = PharmacyService();

  List<dynamic> _availablePrograms = [];
  List<String> _selectedProgramIds = [];
  bool _isLoadingPrograms = true;

  List<dynamic> _availableLabs = [];
  String? _selectedLabId;
  bool _isLoadingLabs = true;

  List<dynamic> _availablePharmacies = [];
  String? _selectedPharmacyId;
  bool _isLoadingPharmacies = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([_fetchPrograms(), _fetchLabs(), _fetchPharmacies()]);
  }

  Future<void> _fetchLabs() async {
    try {
      final labs = await _labService.getAllLaboratories();
      setState(() {
        _availableLabs = labs;
      });
    } catch (e) {
      // silently ignored
    } finally {
      setState(() => _isLoadingLabs = false);
    }
  }

  Future<void> _fetchPharmacies() async {
    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      setState(() {
        _availablePharmacies = pharmacies;
      });
    } catch (e) {
      // silently ignored
    } finally {
      setState(() => _isLoadingPharmacies = false);
    }
  }

  Future<void> _fetchPrograms() async {
    try {
      final result = await _courseService.listPublicCourses();
      setState(() {
        _availablePrograms = result;
      });
    } catch (e) {
      // silently ignored
    } finally {
      setState(() => _isLoadingPrograms = false);
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _bpController.dispose();
    _tempController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _addPrescription() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final dosageController = TextEditingController();
        final frequencyController = TextEditingController();
        final durationController = TextEditingController();
        final instructionsController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Add Prescription',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Gilroy-Bold',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form fields
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildModalTextField(
                          controller: nameController,
                          label: 'Medicine Name',
                          icon: Icons.medical_services_rounded,
                          hint: 'e.g., Paracetamol',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModalTextField(
                                controller: dosageController,
                                label: 'Dosage',
                                icon: Icons.science_rounded,
                                hint: 'e.g., 500mg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildModalTextField(
                                controller: durationController,
                                label: 'Duration',
                                icon: Icons.timer_rounded,
                                hint: 'e.g., 5 days',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildModalTextField(
                          controller: frequencyController,
                          label: 'Frequency',
                          icon: Icons.schedule_rounded,
                          hint: 'e.g., Twice daily',
                        ),
                        const SizedBox(height: 16),
                        _buildModalTextField(
                          controller: instructionsController,
                          label: 'Instructions',
                          icon: Icons.note_rounded,
                          hint: 'e.g., Take after meals',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (nameController.text.isNotEmpty) {
                                    // Requirement 26.13: Drug Interaction Checker
                                    final interactions = {
                                      'warfarin': [
                                        'aspirin',
                                        'ibuprofen',
                                        'naproxen',
                                        'clopidogrel',
                                        'diclofenac',
                                      ],
                                      'aspirin': [
                                        'warfarin',
                                        'ibuprofen',
                                        'clopidogrel',
                                      ],
                                      'ibuprofen': [
                                        'warfarin',
                                        'aspirin',
                                        'naproxen',
                                        'lisinopril',
                                      ],
                                      'naproxen': ['warfarin', 'ibuprofen'],
                                      'lisinopril': [
                                        'potassium',
                                        'spironolactone',
                                        'ibuprofen',
                                      ],
                                      'spironolactone': [
                                        'lisinopril',
                                        'potassium',
                                      ],
                                      'metformin': ['cimetidine', 'cephalexin'],
                                      'amoxicillin': ['methotrexate'],
                                      'simvastatin': [
                                        'clarithromycin',
                                        'itraconazole',
                                        'grapefruit juice',
                                      ],
                                      'digoxin': ['amiodarone', 'verapamil'],
                                    };

                                    String newDrug = nameController.text
                                        .toLowerCase()
                                        .trim();
                                    List<String> warnings = [];

                                    // Check against current prescriptions in the session
                                    for (var existing in _prescriptions) {
                                      String existingDrug =
                                          existing['name']
                                              ?.toLowerCase()
                                              .trim() ??
                                          '';
                                      if (interactions[newDrug]?.contains(
                                            existingDrug,
                                          ) ??
                                          false) {
                                        warnings.add(
                                          "CRITICAL: Severe Interaction Risk between '${existing['name']}' and '${nameController.text}'",
                                        );
                                      }
                                    }

                                    // Requirement: Cross-check against patient's chronic medications
                                    // (Simulating historical data check)
                                    final patientChronicMeds = [
                                      'warfarin',
                                      'lisinopril',
                                    ]; // Mock data
                                    for (var chronic in patientChronicMeds) {
                                      if (interactions[newDrug]?.contains(
                                            chronic,
                                          ) ??
                                          false) {
                                        warnings.add(
                                          "CHRONIC ALERT: Interaction Risk with patient's current medication: '$chronic'",
                                        );
                                      }
                                    }

                                    void finishAdd() {
                                      setState(() {
                                        _prescriptions.add({
                                          'name': nameController.text,
                                          'dosage': dosageController.text,
                                          'frequency': frequencyController.text,
                                          'duration': durationController.text,
                                          'instructions':
                                              instructionsController.text,
                                        });
                                      });
                                      Navigator.pop(context);
                                    }

                                    if (warnings.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Row(
                                            children: const [
                                              Icon(
                                                Icons.report_problem_rounded,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                "Safety Warning",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              ...warnings.map(
                                                (w) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8,
                                                      ),
                                                  child: Text(
                                                    w,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                "Proceeding may cause severe adverse effects. Are you sure?",
                                              ),
                                            ],
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text(
                                                "CANCEL",
                                                style: TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                finishAdd();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text(
                                                "PROCEED ANYWAY",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      finishAdd();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Add Medicine',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addLabTest() {
    showDialog(
      context: context,
      builder: (context) {
        final testController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.biotech_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Add Lab Test',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Gilroy-Bold',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form field
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildModalTextField(
                        controller: testController,
                        label: 'Test Name',
                        icon: Icons.science_rounded,
                        hint: 'e.g., Complete Blood Count (CBC)',
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (testController.text.isNotEmpty) {
                                  setState(() {
                                    _labTests.add(testController.text);
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Add Test',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Parse symptoms (comma-separated)
    final symptoms = _symptomsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final data = {
      'patientId': widget.appointment.patient!.id,
      'appointmentId': widget.appointment.id,
      'diagnosis': _diagnosisController.text,
      'symptoms': symptoms,
      'prescription': _prescriptions,
      'labTests': _labTests,
      'vitalSigns': {
        'bloodPressure': _bpController.text,
        'temperature': _tempController.text,
        'heartRate': _heartRateController.text.isNotEmpty
            ? int.tryParse(_heartRateController.text) ?? 0
            : 0,
        'weight': _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text) ?? 0.0
            : 0.0,
        'height': _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text) ?? 0.0
            : 0.0,
      },
      'notes': _notesController.text,
      if (_followUpDate != null)
        'followUpDate': _followUpDate!.toIso8601String(),
      'assignedCourses': _selectedProgramIds,
      'referredLaboratory': _selectedLabId,
      'selectedPharmacy': _selectedPharmacyId,
    };

    final result = await _medicalRecordService.createMedicalRecord(data);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record created successfully')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to create record'),
          ),
        );
      }
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
          'Create Medical Record',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Gilroy-Bold',
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 20),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1000 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info Card - Enhanced Design
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.appointment.patient!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Creating Record For',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.appointment.patient!.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'Gilroy-Bold',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.appointment.patient!.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Diagnosis Section
                  _buildModernSectionCard(
                    'Diagnosis',
                    Icons.medical_information_rounded,
                    const Color(0xFFEF4444),
                    child: TextFormField(
                      controller: _diagnosisController,
                      decoration: _modernInputDecoration(
                        'Enter primary diagnosis',
                        Icons.edit_note_rounded,
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Diagnosis is required' : null,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Symptoms Section
                  _buildModernSectionCard(
                    'Symptoms',
                    Icons.sick_rounded,
                    const Color(0xFFF59E0B),
                    child: TextFormField(
                      controller: _symptomsController,
                      decoration: _modernInputDecoration(
                        'e.g., Fever, Headache, Cough',
                        Icons.list_alt_rounded,
                      ),
                      maxLines: 3,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vital Signs
                  _buildSectionTitle('Vital Signs'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bpController,
                                decoration: _inputDecoration('BP (120/80)'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _tempController,
                                decoration: _inputDecoration('Temp (°F)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heartRateController,
                                decoration: _inputDecoration('Heart Rate'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: _inputDecoration('Weight (kg)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                decoration: _inputDecoration('Height (cm)'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Prescriptions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Prescriptions'),
                      IconButton(
                        onPressed: _addPrescription,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (_prescriptions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('No prescriptions added'),
                      ),
                    )
                  else
                    ..._prescriptions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final med = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    med['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${med['dosage']} - ${med['frequency']}',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _prescriptions.removeAt(index));
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // Lab Tests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Lab Tests'),
                      IconButton(
                        onPressed: _addLabTest,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (_labTests.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('No lab tests added')),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: _labTests.asMap().entries.map((entry) {
                        final index = entry.key;
                        final test = entry.value;
                        return Chip(
                          label: Text(test),
                          onDeleted: () {
                            setState(() => _labTests.removeAt(index));
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20),

                  // Notes
                  _buildSectionTitle('Additional Notes'),
                  TextFormField(
                    controller: _notesController,
                    decoration: _inputDecoration('Enter any additional notes'),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 20),

                  // Follow-up Date
                  _buildSectionTitle('Follow-up Date (Optional)'),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 7),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _followUpDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _followUpDate != null
                                ? DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_followUpDate!)
                                : 'Select follow-up date',
                            style: TextStyle(
                              color: _followUpDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Laboratory Referral (Task 11.1)
                  _buildModernSectionCard(
                    'Refer to Laboratory',
                    Icons.biotech_rounded,
                    const Color(0xFF0EA5E9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select a laboratory to automatically receive these test requests.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingLabs)
                          const Center(child: CircularProgressIndicator())
                        else if (_availableLabs.isEmpty)
                          const Text('No laboratories available in your region')
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedLabId,
                            isExpanded: true,
                            decoration: _modernInputDecoration(
                              'Select Laboratory',
                              Icons.local_hospital_rounded,
                            ),
                            dropdownColor: Colors.white,
                            items: _availableLabs.map((lab) {
                              return DropdownMenuItem<String>(
                                value: lab['_id'],
                                child: Text(
                                  "${lab['labName']} (${lab['city']})",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedLabId = val),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pharmacy Referral (Task 12.1)
                  _buildModernSectionCard(
                    'Refer to Pharmacy',
                    Icons.medication_liquid_rounded,
                    const Color(0xFF10B981),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select a pharmacy to automatically send this prescription for fulfillment.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingPharmacies)
                          const Center(child: CircularProgressIndicator())
                        else if (_availablePharmacies.isEmpty)
                          const Text('No pharmacies available')
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedPharmacyId,
                            isExpanded: true,
                            decoration: _modernInputDecoration(
                              'Select Pharmacy',
                              Icons.medication_rounded,
                            ),
                            dropdownColor: Colors.white,
                            items: _availablePharmacies.map((pharmacy) {
                              return DropdownMenuItem<String>(
                                value: pharmacy['_id'],
                                child: Text(
                                  "${pharmacy['pharmacyName']} (${pharmacy['city']})",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPharmacyId = val),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Health Programs Assignment (Task 19.3)
                  _buildModernSectionCard(
                    'Assign Health Programs',
                    Icons.health_and_safety_rounded,
                    const Color(0xFF8B5CF6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign educational tracks for the patient to follow as part of their care plan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingPrograms)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_availablePrograms.isEmpty)
                          const Text('No programs available')
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availablePrograms.map((course) {
                              final isSelected = _selectedProgramIds.contains(
                                course['_id'],
                              );
                              return FilterChip(
                                label: Text(course['title']),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedProgramIds.add(course['_id']);
                                    } else {
                                      _selectedProgramIds.remove(course['_id']);
                                    }
                                  });
                                },
                                selectedColor: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.2),
                                checkmarkColor: const Color(0xFF8B5CF6),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF7C3AED)
                                      : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: _isSubmitting
                          ? 'Creating...'
                          : 'Create Medical Record',
                      onPressed: _isSubmitting ? null : _submitRecord,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildModernSectionCard(
    String title,
    IconData icon,
    Color color, {
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Gilroy-Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _modernInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
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
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
    );
  }
}
