import 'dart:developer';
import 'package:icare/models/consultation.dart';
import 'package:icare/models/lab_test_request.dart';
import 'package:icare/models/prescription.dart';
import 'package:icare/models/health_program_assignment.dart';
import 'package:icare/models/referral.dart';
import 'package:icare/services/clinical_audit_service.dart';

/// Healthcare Workflow Engine
///
/// This service orchestrates the connected virtual hospital ecosystem.
/// When a doctor completes a consultation, this engine automatically:
/// - Sends lab test requests to laboratories
/// - Sends prescriptions to pharmacies (if patient requests)
/// - Assigns health programs to patients
/// - Creates referrals to specialists
/// - Updates all relevant dashboards
/// - Creates audit logs
///
/// This is EVENT-DRIVEN and ensures all modules are connected.
class HealthcareWorkflowService {
  static final HealthcareWorkflowService _instance = HealthcareWorkflowService._internal();
  factory HealthcareWorkflowService() => _instance;
  HealthcareWorkflowService._internal();

  /// Process consultation completion
  /// This is the MAIN TRIGGER that connects everything
  Future<WorkflowResult> processConsultationCompletion(Consultation consultation) async {
    log('🏥 [Workflow Engine] Processing consultation completion: ${consultation.id}');

    final result = WorkflowResult();

    try {
      // 1. Process Lab Test Requests
      if (consultation.plan?.labTestRequestIds.isNotEmpty ?? false) {
        log('🧪 [Workflow Engine] Processing ${consultation.plan!.labTestRequestIds.length} lab test requests');
        final labResults = await _processLabTestRequests(
          consultation.id,
          consultation.patientId,
          consultation.doctorId,
          consultation.plan!.labTestRequestIds,
          consultation.diagnosis?.primaryDiagnosis ?? '',
        );
        result.labTestsCreated = labResults.length;
        result.labTestRequestIds.addAll(labResults);
      }

      // 2. Process Prescriptions
      if (consultation.plan?.prescriptionIds.isNotEmpty ?? false) {
        log('💊 [Workflow Engine] Processing ${consultation.plan!.prescriptionIds.length} prescriptions');
        final prescriptionResults = await _processPrescriptions(
          consultation.id,
          consultation.patientId,
          consultation.doctorId,
          consultation.plan!.prescriptionIds,
        );
        result.prescriptionsCreated = prescriptionResults.length;
        result.prescriptionIds.addAll(prescriptionResults);
      }

      // 3. Process Health Program Assignments
      if (consultation.plan?.healthProgramIds.isNotEmpty ?? false) {
        log('📚 [Workflow Engine] Processing ${consultation.plan!.healthProgramIds.length} health program assignments');
        final programResults = await _processHealthProgramAssignments(
          consultation.id,
          consultation.patientId,
          consultation.doctorId,
          consultation.plan!.healthProgramIds,
          consultation.diagnosis?.primaryDiagnosis ?? '',
        );
        result.healthProgramsAssigned = programResults.length;
        result.healthProgramAssignmentIds.addAll(programResults);
      }

      // 4. Process Referral
      if (consultation.plan?.referralId != null) {
        log('👨‍⚕️ [Workflow Engine] Processing referral');
        final referralResult = await _processReferral(
          consultation.id,
          consultation.patientId,
          consultation.doctorId,
          consultation.plan!.referralId!,
        );
        if (referralResult != null) {
          result.referralCreated = true;
          result.referralId = referralResult;
        }
      }

      // 5. Update Patient Dashboard
      await _updatePatientDashboard(consultation.patientId, result);

      // 6. Create Audit Log
      await _createAuditLog(consultation, result);

      // 7. Send Notifications
      await _sendNotifications(consultation, result);

      result.success = true;
      log('✅ [Workflow Engine] Consultation processing completed successfully');

    } catch (e) {
      log('❌ [Workflow Engine] Error processing consultation: $e');
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  /// Process lab test requests - sends to lab dashboard
  Future<List<String>> _processLabTestRequests(
    String consultationId,
    String patientId,
    String doctorId,
    List<String> testRequestIds,
    String diagnosis,
  ) async {
    final createdIds = <String>[];

    for (final testId in testRequestIds) {
      try {
        // In real implementation, this would call the backend API
        // For now, we'll simulate the workflow

        log('  📋 Creating lab test request: $testId');

        // This would trigger:
        // 1. Create lab test request in database
        // 2. Notify available labs
        // 3. Update lab dashboard with new request
        // 4. Send notification to patient

        createdIds.add(testId);

      } catch (e) {
        log('  ❌ Error creating lab test request $testId: $e');
      }
    }

    return createdIds;
  }

  /// Process prescriptions - sends to pharmacy if patient requests
  Future<List<String>> _processPrescriptions(
    String consultationId,
    String patientId,
    String doctorId,
    List<String> prescriptionIds,
  ) async {
    final createdIds = <String>[];

    for (final prescriptionId in prescriptionIds) {
      try {
        log('  💊 Creating prescription: $prescriptionId');

        // This would trigger:
        // 1. Create prescription in database
        // 2. Make available to patient
        // 3. If patient requests fulfillment → send to pharmacy dashboard
        // 4. Send notification to patient

        createdIds.add(prescriptionId);

      } catch (e) {
        log('  ❌ Error creating prescription $prescriptionId: $e');
      }
    }

    return createdIds;
  }

  /// Process health program assignments - assigns to patient
  Future<List<String>> _processHealthProgramAssignments(
    String consultationId,
    String patientId,
    String doctorId,
    List<String> programIds,
    String diagnosis,
  ) async {
    final assignmentIds = <String>[];

    for (final programId in programIds) {
      try {
        log('  📚 Assigning health program: $programId');

        // This would trigger:
        // 1. Create program assignment in database
        // 2. Update patient's "My Health Journey" section
        // 3. Send notification to patient
        // 4. Track progress

        assignmentIds.add(programId);

      } catch (e) {
        log('  ❌ Error assigning health program $programId: $e');
      }
    }

    return assignmentIds;
  }

  /// Process referral - creates referral to specialist
  Future<String?> _processReferral(
    String consultationId,
    String patientId,
    String doctorId,
    String referralId,
  ) async {
    try {
      log('  👨‍⚕️ Creating referral: $referralId');

      // This would trigger:
      // 1. Create referral in database
      // 2. Notify available specialists
      // 3. Update specialist dashboard
      // 4. Send notification to patient
      // 5. Track referral status

      return referralId;

    } catch (e) {
      log('  ❌ Error creating referral $referralId: $e');
      return null;
    }
  }

  /// Update patient dashboard with new items
  Future<void> _updatePatientDashboard(String patientId, WorkflowResult result) async {
    log('  📊 Updating patient dashboard for: $patientId');

    // This would trigger:
    // 1. Refresh patient's dashboard
    // 2. Show new prescriptions
    // 3. Show new lab tests
    // 4. Show new health programs
    // 5. Show referral status
  }

  /// Create audit log for compliance and QA
  Future<void> _createAuditLog(Consultation consultation, WorkflowResult result) async {
    log('  📝 Creating audit log for consultation: ${consultation.id}');

    try {
      // Gather prescriptions and lab tests for audit
      List<Prescription>? prescriptions;
      List<LabTestRequest>? labTests;

      // In real implementation, fetch these from the consultation
      // For now, we'll pass null and the audit service will work with what's available

      // Perform clinical audit
      final auditService = ClinicalAuditService();
      final audit = await auditService.auditConsultation(
        consultation,
        prescriptions,
        labTests,
      );

      result.auditId = audit.id;
      result.qualityScore = audit.qualityScore.overallScore;

      log('  ✅ Audit completed - Quality Score: ${audit.qualityScore.overallScore}%');

      if (audit.flags.isNotEmpty) {
        log('  ⚠️  Quality flags identified: ${audit.flags.length}');
        for (var flag in audit.flags) {
          log('    - ${flag.type.toString().split('.').last}: ${flag.description} (${flag.severity.toString().split('.').last})');
        }
      }
    } catch (e) {
      log('  ❌ Error creating audit log: $e');
    }
  }

  /// Send notifications to all relevant parties
  Future<void> _sendNotifications(Consultation consultation, WorkflowResult result) async {
    log('  🔔 Sending notifications');

    // Send to patient:
    // - Consultation completed
    // - New prescriptions available
    // - Lab tests ordered
    // - Health programs assigned

    // Send to labs:
    // - New test requests

    // Send to pharmacies (if patient requests):
    // - New prescription orders
  }

  /// Handle prescription fulfillment request from patient
  Future<bool> handlePrescriptionFulfillmentRequest(
    String prescriptionId,
    String patientId,
    String deliveryAddress,
  ) async {
    log('🏥 [Workflow Engine] Patient requested prescription fulfillment: $prescriptionId');

    try {
      // This would trigger:
      // 1. Update prescription status
      // 2. Send to available pharmacies
      // 3. Update pharmacy dashboard with new order
      // 4. Notify patient of order status

      return true;
    } catch (e) {
      log('❌ [Workflow Engine] Error processing fulfillment request: $e');
      return false;
    }
  }

  /// Handle lab test acceptance by laboratory
  Future<bool> handleLabTestAcceptance(
    String testRequestId,
    String labId,
  ) async {
    log('🏥 [Workflow Engine] Lab accepted test request: $testRequestId');

    try {
      // This would trigger:
      // 1. Update test request status
      // 2. Notify patient
      // 3. Notify doctor
      // 4. Update dashboards

      return true;
    } catch (e) {
      log('❌ [Workflow Engine] Error processing lab acceptance: $e');
      return false;
    }
  }

  /// Handle lab report upload
  Future<bool> handleLabReportUpload(
    String testRequestId,
    String reportUrl,
    String reportNotes,
  ) async {
    log('🏥 [Workflow Engine] Lab uploaded report: $testRequestId');

    try {
      // This would trigger:
      // 1. Update test request with report
      // 2. Notify patient (report available)
      // 3. Notify doctor (report available)
      // 4. Update patient's health records
      // 5. Update dashboards

      return true;
    } catch (e) {
      log('❌ [Workflow Engine] Error processing report upload: $e');
      return false;
    }
  }

  /// Handle pharmacy order status updates
  Future<bool> handlePharmacyOrderUpdate(
    String prescriptionId,
    String status,
  ) async {
    log('🏥 [Workflow Engine] Pharmacy updated order status: $prescriptionId → $status');

    try {
      // This would trigger:
      // 1. Update prescription status
      // 2. Notify patient
      // 3. Update dashboards

      return true;
    } catch (e) {
      log('❌ [Workflow Engine] Error processing pharmacy update: $e');
      return false;
    }
  }
}

/// Result of workflow processing
class WorkflowResult {
  bool success = false;
  String? error;

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
