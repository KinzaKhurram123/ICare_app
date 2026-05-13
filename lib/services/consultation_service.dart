import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:icare/utils/api_constants.dart';
import 'package:icare/utils/shared_pref.dart';

class ConsultationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final SharedPref _sharedPref = SharedPref();

  // ==================== V2 CONSULTATION ENDPOINTS ====================
  
  // Start consultation with appointment (V2)
  Future<Map<String, dynamic>> startConsultationV2({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    String? reason,
    String? channelName,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      // Only send appointmentId if it's a valid 24-char MongoDB ObjectId
      final bool validApptId = appointmentId.length == 24 &&
          RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(appointmentId);
      final response = await _dio.post(
        '/consultations-v2/start-v2',
        data: {
          if (validApptId) 'appointmentId': appointmentId,
          'patientId': patientId,
          'doctorId': doctorId,
          if (reason != null) 'reason': reason,
          if (channelName != null) 'channelName': channelName,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Unexpected response format'};
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = e.message ?? 'Network error';
      if (data is Map<String, dynamic>) {
        msg = data['message']?.toString() ?? msg;
      } else if (data is String && data.isNotEmpty) {
        msg = data.length > 100 ? msg : data;
      }
      print('Error starting consultation: $msg');
      return {'success': false, 'message': msg};
    } catch (e) {
      print('Unexpected error starting consultation: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Send message (V2)
  Future<Map<String, dynamic>> sendMessageV2({
    required String consultationId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    String? attachmentUrl,
    bool isSystemMessage = false,
  }) async {
    try {
      print('📤 SENDING MESSAGE:');
      print('  consultationId: $consultationId');
      print('  senderId: $senderId');
      print('  senderName: $senderName');
      print('  senderRole: $senderRole');
      print('  message: $message');

      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations-v2/$consultationId/messages',
        data: {
          'senderId': senderId,
          'senderName': senderName,
          'senderRole': senderRole,
          'message': message,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
          'isSystemMessage': isSystemMessage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('✅ MESSAGE SENT SUCCESSFULLY: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ ERROR SENDING MESSAGE: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get messages (V2)
  Future<List<dynamic>> getMessagesV2({
    required String consultationId,
    int limit = 100,
    int skip = 0,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations-v2/$consultationId/messages?limit=$limit&skip=$skip',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('📥 GET MESSAGES RESPONSE:');
      print('  consultationId: $consultationId');
      print('  success: ${response.data['success']}');
      print('  message count: ${response.data['messages']?.length ?? 0}');
      if (response.data['success'] == true) {
        return response.data['messages'] ?? [];
      }
      return [];
    } on DioException catch (e) {
      print('❌ ERROR GETTING MESSAGES: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return [];
    }
  }

  // End consultation (V2)
  Future<Map<String, dynamic>> endConsultationV2({
    required String consultationId,
    required int duration,
    String? prescriptionId,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations-v2/$consultationId/end',
        data: {
          'duration': duration,
          if (prescriptionId != null) 'prescriptionId': prescriptionId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error ending consultation: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get consultation details (V2)
  Future<Map<String, dynamic>> getConsultationV2(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations-v2/$consultationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error getting consultation: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get consultation by appointment ID (direct lookup)
  Future<Map<String, dynamic>> getConsultationByAppointmentId(String appointmentId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations-v2/by-appointment/$appointmentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error getting consultation by appointment: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get consultation by appointment ID
  // Directly calls startConsultationV2 — backend returns existing session if already started
  Future<Map<String, dynamic>> getConsultationByAppointment(
    String appointmentId, {
    String patientId = '',
    String doctorId = '',
  }) async {
    if (patientId.isEmpty || doctorId.isEmpty) {
      return {'success': false, 'message': 'Missing patient or doctor ID'};
    }
    return startConsultationV2(
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
    );
  }

  // Get timer status (V2)
  Future<Map<String, dynamic>> getTimerStatus(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations-v2/$consultationId/timer',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error getting timer status: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // ==================== PRESCRIPTION V2 ENDPOINTS ====================

  // Save prescription draft
  Future<Map<String, dynamic>> savePrescriptionDraft({
    required String consultationId,
    required Map<String, dynamic> prescriptionData,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/prescriptions-v2/consultations/$consultationId/prescription/draft',
        data: prescriptionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error saving prescription draft: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get prescription draft
  Future<Map<String, dynamic>?> getPrescriptionDraft(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/prescriptions-v2/consultations/$consultationId/prescription/draft',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['prescription'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting prescription draft: ${e.message}');
      return null;
    }
  }

  // Complete prescription
  Future<Map<String, dynamic>> completePrescription({
    required String consultationId,
    required Map<String, dynamic> prescriptionData,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/prescriptions-v2/consultations/$consultationId/prescription/complete',
        data: prescriptionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error completing prescription: ${e.response?.statusCode} ${e.message}');
      String message = e.message ?? 'Network error';
      try {
        final data = e.response?.data;
        if (data is Map) {
          message = data['message']?.toString() ?? data['error']?.toString() ?? message;
        } else if (data is String && data.length < 500) {
          message = data;
        }
      } catch (_) {}
      return {'success': false, 'message': message};
    }
  }

  // Get prescription by ID
  Future<Map<String, dynamic>?> getPrescription(String prescriptionId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/prescriptions-v2/prescriptions/$prescriptionId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['prescription'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting prescription: ${e.message}');
      return null;
    }
  }

  // Get patient prescriptions
  Future<List<dynamic>> getPatientPrescriptions({
    required String patientId,
    String? status,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/prescriptions-v2/patients/$patientId/prescriptions?limit=$limit&skip=$skip${status != null ? '&status=$status' : ''}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['prescriptions'] ?? [];
      }
      return [];
    } on DioException catch (e) {
      print('Error getting patient prescriptions: ${e.message}');
      return [];
    }
  }

  // ==================== PATIENT HISTORY ENDPOINTS ====================

  // Save patient history
  Future<Map<String, dynamic>> savePatientHistory({
    required Map<String, dynamic> historyData,
  }) async {
    try {
      print('📋 SAVING PATIENT HISTORY:');
      print('  patientId: ${historyData['patientId']}');
      print('  consultationId: ${historyData['consultationId']}');
      print('  doctorId: ${historyData['doctorId']}');
      print('  Data keys: ${historyData.keys.toList()}');

      final token = await _sharedPref.getToken();
      print('  Token: ${token?.substring(0, 20)}...');

      final response = await _dio.post(
        '/patient-history/create',
        data: historyData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ PATIENT HISTORY SAVE RESPONSE:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      return {'success': true}; // non-map success response
    } on DioException catch (e) {
      print('❌ ERROR SAVING PATIENT HISTORY:');
      print('  Message: ${e.message}');
      print('  Status: ${e.response?.statusCode}');
      print('  Response data: ${e.response?.data}');

      // Safely extract message — response.data could be String/null/Map
      String message = e.message ?? 'Network error';
      try {
        final data = e.response?.data;
        if (data is Map) {
          message = data['message']?.toString() ?? data['error']?.toString() ?? message;
        } else if (data is String && data.isNotEmpty && data.length < 300) {
          message = data;
        }
      } catch (_) {}
      return {'success': false, 'message': message};
    } catch (e) {
      print('❌ UNEXPECTED ERROR SAVING PATIENT HISTORY: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // Get patient history
  Future<List<dynamic>> getPatientHistory({
    required String patientId,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/patient-history/patient/$patientId?limit=$limit&skip=$skip',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['histories'] ?? [];
      }
      return [];
    } on DioException catch (e) {
      print('Error getting patient history: ${e.message}');
      return [];
    }
  }

  // Get history by consultation
  Future<Map<String, dynamic>?> getHistoryByConsultation(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/patient-history/consultation/$consultationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['history'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting history by consultation: ${e.message}');
      return null;
    }
  }

  // Get latest history
  Future<Map<String, dynamic>?> getLatestHistory(String patientId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/patient-history/patient/$patientId/latest',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['history'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting latest history: ${e.message}');
      return null;
    }
  }

  // ==================== LIFESTYLE ADVICE ENDPOINTS ====================

  // Get lifestyle advice templates
  Future<Map<String, dynamic>> getLifestyleAdviceTemplates() async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/lifestyle-advice/templates',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error getting lifestyle advice templates: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Save lifestyle advice
  Future<Map<String, dynamic>> saveLifestyleAdvice({
    required String consultationId,
    required String prescriptionId,
    required Map<String, dynamic> lifestyleData,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/lifestyle-advice/create',
        data: {
          'consultationId': consultationId,
          'prescriptionId': prescriptionId,
          ...lifestyleData,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      print('Error saving lifestyle advice: ${e.message}');
      return {'success': false, 'message': e.response?.data['message'] ?? e.message};
    }
  }

  // Get lifestyle advice by consultation
  Future<Map<String, dynamic>?> getLifestyleAdviceByConsultation(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/lifestyle-advice/consultation/$consultationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        return response.data['advice'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting lifestyle advice: ${e.message}');
      return null;
    }
  }

  // ==================== FILE UPLOAD ====================

  // Upload attachment — mobile/desktop (file path)
  Future<Map<String, dynamic>> uploadAttachment(String filePath) async {
    try {
      final token = await _sharedPref.getToken();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'success': false, 'message': 'Unexpected response'};
    } on DioException catch (e) {
      print('Error uploading attachment: ${e.message}');
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  // Upload attachment — web (bytes, no file path)
  Future<Map<String, dynamic>> uploadAttachmentBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'success': false, 'message': 'Unexpected response'};
    } on DioException catch (e) {
      print('Error uploading attachment bytes: ${e.message}');
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }
}
