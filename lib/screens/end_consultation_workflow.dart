import 'package:flutter/material.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/screens/prescription_templates_screen.dart';
import 'package:icare/screens/soap_notes_redesign.dart';
import 'package:icare/services/appointment_service.dart';
import 'package:icare/services/clinical_service.dart';
import 'package:icare/services/medical_record_service.dart';
import 'package:icare/utils/theme.dart';
import 'package:icare/widgets/back_button.dart';
import 'package:icare/widgets/icd_code_selector.dart';

class EndConsultationWorkflow extends StatefulWidget {
  final AppointmentDetail appointment;

  const EndConsultationWorkflow({super.key, required this.appointment});

  @override
  State<EndConsultationWorkflow> createState() =>
      _EndConsultationWorkflowState();
}

class _EndConsultationWorkflowState extends State<EndConsultationWorkflow> {
  final ClinicalService _clinicalService = ClinicalService();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  // Diagnosis state
  bool _diagnosisCompleted = false;
  List<Map<String, dynamic>> _selectedICDCodes = [];
  final TextEditingController _diagnosisNotesController = TextEditingController();

  // Prescription state
  bool _prescriptionCompleted = false;
  bool _noPrescription = false;
  String _noPrescriptionReason = '';

  // Lab Tests state
  bool _labTestsCompleted = false;
  bool _noLabTests = false;
  String _noLabTestsReason = '';

  // SOAP Notes state
  bool _soapNotesCompleted = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkExistingData();
  }

  Future<void> _checkExistingData() async {
    try {
      // Check if SOAP notes exist
      final soapResult = await _clinicalService.getSoapNotes(
        widget.appointment.id,
      );
      if (soapResult['success'] && soapResult['notes'] != null) {
        final notes = soapResult['notes'];
        final hasContent = (notes['subjective']?.toString().isNotEmpty ?? false) ||
            (notes['objective']?.toString().isNotEmpty ?? false) ||
            (notes['assessment']?.toString().isNotEmpty ?? false) ||
            (notes['plan']?.toString().isNotEmpty ?? false);
        setState(() => _soapNotesCompleted = hasContent);
      }

      // Check if prescriptions exist
      final recordsResult = await _medicalRecordService.getPatientRecords(
        widget.appointment.patient?.id ?? '',
      );
      if (recordsResult['success'] == true) {
        final records = recordsResult['records'] as List? ?? [];
        final hasRecordForThisAppt = records.any((r) =>
            r['appointmentId'] == widget.appointment.id &&
            (r['prescriptions'] as List?)?.isNotEmpty == true);
        setState(() => _prescriptionCompleted = hasRecordForThisAppt);
      }
    } catch (e) {
      debugPrint('Error checking existing data: $e');
    }
  }

  bool get _canEndConsultation {
    final diagnosisOk = _diagnosisCompleted;
    final prescriptionOk = _prescriptionCompleted || (_noPrescription && _noPrescriptionReason.trim().isNotEmpty);
    final labTestsOk = _labTestsCompleted || (_noLabTests && _noLabTestsReason.trim().isNotEmpty);
    final soapOk = _soapNotesCompleted;
    return diagnosisOk && prescriptionOk && labTestsOk && soapOk;
  }

  Future<void> _endConsultation() async {
    if (!_canEndConsultation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all mandatory sections before ending consultation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Save diagnosis with ICD codes
      if (_diagnosisCompleted && _selectedICDCodes.isNotEmpty) {
        await _clinicalService.saveSoapNotes(widget.appointment.id, {
          'diagnosis': _diagnosisNotesController.text,
          'icdCodes': _selectedICDCodes,
        });
      }

      // Save "No Prescription" reason if applicable
      if (_noPrescription && _noPrescriptionReason.isNotEmpty) {
        await _clinicalService.saveSoapNotes(widget.appointment.id, {
          'noPrescriptionReason': _noPrescriptionReason,
        });
      }

      // Save "No Lab Tests" reason if applicable
      if (_noLabTests && _noLabTestsReason.isNotEmpty) {
        await _clinicalService.saveSoapNotes(widget.appointment.id, {
          'noLabTestsReason': _noLabTestsReason,
        });
      }

      // Mark appointment as completed
      await AppointmentService().updateAppointmentStatus(
        appointmentId: widget.appointment.id,
        status: 'completed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation ended successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop twice - close this screen and the video call screen
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ending consultation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          'End Consultation',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Required Documentation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All sections must be completed before ending consultation',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 1. Diagnosis Section (with ICD-10 codes)
            _buildSection(
              title: '1. Diagnosis',
              icon: Icons.medical_services_rounded,
              color: const Color(0xFFEF4444),
              isCompleted: _diagnosisCompleted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add diagnosis and ICD-10 codes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ICD-10 Codes Section
                  Row(
                    children: [
                      const Text(
                        'ICD-10 Diagnosis Codes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ICDCodeSelector(
                              onCodeSelected: (code) {
                                setState(() {
                                  if (!_selectedICDCodes.any((c) => c['code'] == code['code'])) {
                                    _selectedICDCodes.add(code);
                                  }
                                });
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Add Code'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_selectedICDCodes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'At least one ICD-10 code is required',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedICDCodes.map((code) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  code['code'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: Text(
                                  code['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedICDCodes.removeWhere((c) => c['code'] == code['code']);
                                  });
                                },
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 16),

                  // Diagnosis Notes
                  const Text(
                    'Diagnosis Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diagnosisNotesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter clinical impression and diagnosis details...',
                      filled: true,
                      fillColor: Colors.white,
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
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedICDCodes.isEmpty || _diagnosisNotesController.text.trim().isEmpty
                          ? null
                          : () {
                              setState(() => _diagnosisCompleted = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Diagnosis saved'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text('Save Diagnosis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  if (_diagnosisCompleted) ...[
                    const SizedBox(height: 12),
                    _buildCompletedIndicator('Diagnosis completed with ${_selectedICDCodes.length} ICD code(s)'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Prescription Section
            _buildSection(
              title: '2. Prescription',
              icon: Icons.medication_rounded,
              color: Colors.green,
              isCompleted: _prescriptionCompleted || (_noPrescription && _noPrescriptionReason.isNotEmpty),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_prescriptionCompleted && !_noPrescription) ...[
                    const Text(
                      'Choose one option:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrescriptionTemplatesScreen(),
                            ),
                          ).then((_) => _checkExistingData());
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Create Prescription'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _noPrescription = true),
                        icon: const Icon(Icons.block_rounded, size: 20),
                        label: const Text('No Prescription'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_noPrescription && _noPrescriptionReason.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Please provide a reason:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., Patient needs specialist referral, no medication required, etc.',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      onChanged: (value) => setState(() => _noPrescriptionReason = value),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _noPrescription = false;
                        _noPrescriptionReason = '';
                      }),
                      child: const Text('Cancel'),
                    ),
                  ],
                  if (_prescriptionCompleted) ...[
                    _buildCompletedIndicator('Prescription created'),
                  ],
                  if (_noPrescription && _noPrescriptionReason.isNotEmpty) ...[
                    _buildCompletedIndicator('No prescription - Reason provided'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Lab Tests Section
            _buildSection(
              title: '3. Suggest Lab Test',
              icon: Icons.biotech_rounded,
              color: const Color(0xFF8B5CF6),
              isCompleted: _labTestsCompleted || (_noLabTests && _noLabTestsReason.isNotEmpty),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_labTestsCompleted && !_noLabTests) ...[
                    const Text(
                      'Choose one option:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to lab test ordering screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lab test ordering will be implemented'),
                            ),
                          );
                          setState(() => _labTestsCompleted = true);
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Suggest Lab Tests'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _noLabTests = true),
                        icon: const Icon(Icons.block_rounded, size: 20),
                        label: const Text('No Lab Tests'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_noLabTests && _noLabTestsReason.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Please provide a reason:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., No tests required for this condition, recent tests available, etc.',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      onChanged: (value) => setState(() => _noLabTestsReason = value),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _noLabTests = false;
                        _noLabTestsReason = '';
                      }),
                      child: const Text('Cancel'),
                    ),
                  ],
                  if (_labTestsCompleted) ...[
                    _buildCompletedIndicator('Lab tests suggested'),
                  ],
                  if (_noLabTests && _noLabTestsReason.isNotEmpty) ...[
                    _buildCompletedIndicator('No lab tests - Reason provided'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. SOAP Notes Section
            _buildSection(
              title: '4. SOAP Notes',
              icon: Icons.description_rounded,
              color: Colors.blue,
              isCompleted: _soapNotesCompleted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_soapNotesCompleted) ...[
                    const Text(
                      'SOAP notes are mandatory and must be completed:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SoapNotesRedesign(
                                appointment: widget.appointment,
                              ),
                            ),
                          ).then((_) => _checkExistingData());
                        },
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: const Text('Complete SOAP Notes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_soapNotesCompleted) ...[
                    _buildCompletedIndicator('SOAP notes completed'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // End Consultation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _endConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canEndConsultation
                      ? AppColors.primaryColor
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _canEndConsultation ? 2 : 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _canEndConsultation
                                ? 'End Consultation'
                                : 'Complete All Sections First',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? color.withOpacity(0.5)
              : const Color(0xFFE2E8F0),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
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

  Widget _buildCompletedIndicator(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
