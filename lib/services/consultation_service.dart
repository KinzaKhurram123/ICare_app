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
}
