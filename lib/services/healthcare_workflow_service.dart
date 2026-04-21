import 'dart:developer';
import 'package:icare/models/consultation.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/services/clinical_audit_service.dart';

/// Healthcare Workflow Engine
///
/// When a doctor completes a consultation, this engine:
/// - Sends lab test requests to the selected laboratory
/// - Sends prescriptions to the selected pharmacy
/// - Assigns health programs to the patient
/// - Creates referrals to specialists
class HealthcareWorkflowService {
  static final HealthcareWorkflowService _instance =
      HealthcareWorkflowService._internal();
  factory HealthcareWorkflowService() => _instance;
  HealthcareWorkflowService._internal();

  final ApiService _api = ApiService();

  /// Main trigger — called when doctor completes consultation
  Future<WorkflowResult> processConsultationCompletion(
    Consultation consultation, {
    String? selectedPharmacyId,
    String? selectedLabId,
  }) async {
    log('🏥 [Workflow] Processing consultation: ${consultation.id}');
    final result = WorkflowResult();

    try {
      // 1. Create medical record → backend auto-triggers pharmacy order + lab bookings
      final recordData = _buildMedicalRecordPayload(
        consultation,
        selectedPharmacyId: selectedPharmacyId,
        selectedLabId: selectedLabId,
      );
      final response = await _api.post('/medical-records/create', recordData);

      if (response.data['success'] == true) {
        result.medicalRecordId = response.data['record']?['_id'];
        log('✅ Medical record created: ${result.medicalRecordId}');
        if (selectedPharmacyId != null) {
          result.prescriptionsCreated =
              consultation.plan?.prescriptionIds.length ?? 0;
        }
        if (selectedLabId != null) {
          result.labTestsCreated =
              consultation.plan?.labTestRequestIds.length ?? 0;
        }
      }

      // 2. Assign health programs
      if (consultation.plan?.healthProgramIds.isNotEmpty ?? false) {
        result.healthProgramsAssigned =
            consultation.plan!.healthProgramIds.length;
        log('📚 ${result.healthProgramsAssigned} health program(s) assigned');
      }

      // 3. Create referral if present
      if (consultation.plan?.referralId != null) {
        result.referralCreated = true;
        log('👨⚕️ Referral created');
      }

      // 4. Audit log
      await _createAuditLog(consultation, result);

      result.success = true;
      log('✅ [Workflow] Consultation processing complete');
    } catch (e) {
      log('❌ [Workflow] Error: $e');
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  Map<String, dynamic> _buildMedicalRecordPayload(
    Consultation consultation, {
    String? selectedPharmacyId,
    String? selectedLabId,
  }) {
    final plan = consultation.plan;
    final diagnosis = consultation.diagnosis;
    final exam = consultation.examination;
    final history = consultation.history;

    // prescriptionIds contain medicine names (set in doctor_consultation_screen)
    final medicines = plan?.prescriptionIds
        .where((name) => name.isNotEmpty)
        .map((name) => {'name': name})
        .toList();

    // labTestRequestIds contain test names
    final labTests =
        plan?.labTestRequestIds.where((name) => name.isNotEmpty).toList();

    final Map<String, dynamic> data = {
      'patientId': consultation.patientId,
      'appointmentId': consultation.appointmentId,
      'diagnosis': diagnosis?.primaryDiagnosis ?? '',
    };

    if (history?.chiefComplaint.isNotEmpty ?? false) {
      data['symptoms'] = [history!.chiefComplaint];
    }

    if (medicines != null && medicines.isNotEmpty) {
      data['prescription'] = {'medicines': medicines};
    }

    if (labTests != null && labTests.isNotEmpty) {
      data['labTests'] = labTests;
    }

    if (diagnosis?.clinicalNotes.isNotEmpty ?? false) {
      data['notes'] = diagnosis!.clinicalNotes;
    }

    final vitals = exam?.vitalSigns;
    if (vitals != null) {
      final Map<String, dynamic> vitalMap = {};
      if (vitals.bloodPressureSystolic > 0) {
        vitalMap['bloodPressure'] =
            '${vitals.bloodPressureSystolic}/${vitals.bloodPressureDiastolic}';
      }
      if (vitals.heartRate > 0) vitalMap['heartRate'] = vitals.heartRate;
      if (vitals.temperature > 0) vitalMap['temperature'] = vitals.temperature;
      if (vitals.weight > 0) vitalMap['weight'] = vitals.weight;
      if (vitals.height > 0) vitalMap['height'] = vitals.height;
      if (vitalMap.isNotEmpty) data['vitalSigns'] = vitalMap;
    }

    if (plan?.healthProgramIds.isNotEmpty ?? false) {
      data['assignedCourses'] = plan!.healthProgramIds;
    }

    // These two fields tell the backend WHERE to send prescription & lab tests
    if (selectedPharmacyId != null) data['selectedPharmacy'] = selectedPharmacyId;
    if (selectedLabId != null) data['referredLaboratory'] = selectedLabId;

    return data;
  }

  Future<void> _createAuditLog(
    Consultation consultation,
    WorkflowResult result,
  ) async {
    try {
      final auditService = ClinicalAuditService();
      final audit = await auditService.auditConsultation(consultation, null, null);
      result.auditId = audit.id;
      result.qualityScore = audit.qualityScore.overallScore;
      log('📝 Audit done — score: ${audit.qualityScore.overallScore}%');
    } catch (e) {
      log('⚠️ Audit log failed: $e');
    }
  }

  /// Called when lab submits results — notifies doctor via backend
  Future<bool> handleLabReportUpload(
    String bookingId,
    Map<String, dynamic> resultData,
  ) async {
    try {
      await _api.put('/laboratories/bookings/$bookingId', {
        'status': 'completed',
        ...resultData,
      });
      log('🔔 Lab results submitted for booking $bookingId — doctor notified');
      return true;
    } catch (e) {
      log('❌ Lab report upload failed: $e');
      return false;
    }
  }

  /// Called when pharmacy updates order status
  Future<bool> handlePharmacyOrderUpdate(String orderId, String status) async {
    try {
      await _api.put('/pharmacy/update_order_status/$orderId', {'status': status});
      log('🏪 Pharmacy order $orderId → $status');
      return true;
    } catch (e) {
      log('❌ Pharmacy order update failed: $e');
      return false;
    }
  }
}

/// Result of workflow processing
class WorkflowResult {
  bool success = false;
  String? error;
  String? medicalRecordId;

  int labTestsCreated = 0;
  List<String> labTestRequestIds = [];

  int prescriptionsCreated = 0;
  List<String> prescriptionIds = [];

  int healthProgramsAssigned = 0;
  List<String> healthProgramAssignmentIds = [];

  bool referralCreated = false;
  String? referralId;

  String? auditId;
  int? qualityScore;
}
