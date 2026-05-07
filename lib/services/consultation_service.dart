import 'package:dio/dio.dart';
import 'package:icare/utils/api_constants.dart';
import 'package:icare/utils/shared_pref.dart';

class ConsultationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final SharedPref _sharedPref = SharedPref();

  // Start a new consultation
  Future<Map<String, dynamic>> startConsultation({
    required String patientId,
    String? reason,
    bool isForSelf = true,
    String? patientName,
    String? patientAge,
    String? patientGender,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/start',
        data: {
          'patientId': patientId,
          if (reason != null) 'reason': reason,
          'isForSelf': isForSelf,
          if (patientName != null) 'patientName': patientName,
          if (patientAge != null) 'patientAge': patientAge,
          if (patientGender != null) 'patientGender': patientGender,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Send chat message
  Future<Map<String, dynamic>> sendMessage({
    required String consultationId,
    required String message,
    String? attachmentUrl,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/$consultationId/messages',
        data: {
          'message': message,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Get chat messages
  Future<Map<String, dynamic>> getMessages(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations/$consultationId/messages',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // End consultation
  Future<Map<String, dynamic>> endConsultation(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/$consultationId/end',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Get consultation details
  Future<Map<String, dynamic>> getConsultation(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations/$consultationId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Upload attachment
  Future<Map<String, dynamic>> uploadAttachment(String filePath) async {
    try {
      final token = await _sharedPref.getToken();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/consultations/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // NEW METHODS FOR ENHANCED CONSULTATION FLOW

  // Start consultation with appointment
  Future<Map<String, dynamic>> startConsultation({
    required String appointmentId,
    required String patientId,
    required String doctorId,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/start-v2',
        data: {
          'appointmentId': appointmentId,
          'patientId': patientId,
          'doctorId': doctorId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Send message with system message flag
  Future<Map<String, dynamic>> sendMessage({
    required String consultationId,
    required String message,
    String? attachmentUrl,
    bool isSystemMessage = false,
  }) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/$consultationId/messages',
        data: {
          'message': message,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
          'isSystemMessage': isSystemMessage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Save prescription draft
  Future<Map<String, dynamic>> savePrescriptionDraft(
    String consultationId,
    Map<String, dynamic> prescriptionData,
  ) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/$consultationId/prescription/draft',
        data: prescriptionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Get prescription draft
  Future<Map<String, dynamic>> getPrescriptionDraft(String consultationId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/consultations/$consultationId/prescription/draft',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Complete prescription
  Future<Map<String, dynamic>> completePrescription(
    String consultationId,
    Map<String, dynamic> prescriptionData,
  ) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/consultations/$consultationId/prescription/complete',
        data: prescriptionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Save patient history
  Future<Map<String, dynamic>> savePatientHistory(
    Map<String, dynamic> historyData,
  ) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/patient-history/create',
        data: historyData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Get patient history
  Future<Map<String, dynamic>> getPatientHistory(String patientId) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/patient-history/patient/$patientId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  // Save lifestyle advice
  Future<Map<String, dynamic>> saveLifestyleAdvice(
    String consultationId,
    Map<String, dynamic> lifestyleData,
  ) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/lifestyle-advice/create',
        data: {
          'consultationId': consultationId,
          ...lifestyleData,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

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
      return {'success': false, 'message': e.message};
    }
  }
}
