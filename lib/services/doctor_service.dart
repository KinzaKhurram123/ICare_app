import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getAllDoctors() async {
    try {
      debugPrint('🔍 Fetching doctors from API...');
      final response = await _apiService.get('/doctors/get_all_doctors');

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response data type: ${response.data.runtimeType}');
      debugPrint('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final doctors = response.data['doctors'];
        debugPrint('✅ Doctors data: $doctors');
        return {'success': true, 'doctors': doctors};
      }
      return {'success': false, 'message': 'Failed to fetch doctors'};
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateDoctorProfile({
    required String specialization,
    List<String>? consultationType,
    List<String>? languages,
    required List<String> degrees,
    required String experience,
    required String licenseNumber,
    required String clinicName,
    required String clinicAddress,
    required List<String> availableDays,
    required String startTime,
    required String endTime,
  }) async {
    try {
      debugPrint('📋 Updating doctor profile...');
      debugPrint('Specialization: $specialization');
      debugPrint('Consultation Types: $consultationType');
      debugPrint('Languages: $languages');
      debugPrint('Degrees: $degrees');
      debugPrint('Available Days: $availableDays');
      debugPrint('Time: $startTime - $endTime');

      final requestData = {
        'specialization': specialization,
        'degrees': degrees,
        'experience': experience,
        'licenseNumber': licenseNumber,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'availableDays': availableDays,
        'availableTime': {'start': startTime, 'end': endTime},
      };

      if (consultationType != null && consultationType.isNotEmpty) {
        requestData['consultationType'] = consultationType;
      }

      if (languages != null && languages.isNotEmpty) {
        requestData['languages'] = languages;
      }

      final response = await _apiService.post(
        '/doctors/add_doctor_details',
        requestData,
      );

      debugPrint('✅ Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Profile updated successfully'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } on DioException catch (e) {
      debugPrint('❌ Error updating profile: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> addDoctorReview({
    required String doctorId,
    required double rating,
    String? review,
  }) async {
    try {
      debugPrint('⭐ Adding review for doctor: $doctorId');
      final response = await _apiService.post('/doctors/$doctorId/review', {
        'rating': rating,
        if (review != null) 'review': review,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'doctor': response.data['doctor']};
      }
      return {'success': false, 'message': 'Failed to add review'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> getDoctorById(String doctorId) async {
    try {
      final response = await _apiService.get('/doctors/$doctorId');

      if (response.statusCode == 200) {
        return {'success': true, 'doctor': response.data['doctor']};
      }
      return {'success': false, 'message': 'Failed to fetch doctor'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> filterDoctors({
    String? specialization,
    String? consultationType,
    String? language,
    double? minRating,
  }) async {
    try {
      // Build query string
      final queryParams = <String>[];
      if (specialization != null)
        queryParams.add('specialization=$specialization');
      if (consultationType != null)
        queryParams.add('consultationType=$consultationType');
      if (language != null) queryParams.add('language=$language');
      if (minRating != null) queryParams.add('minRating=$minRating');

      final queryString = queryParams.isNotEmpty
          ? '?${queryParams.join('&')}'
          : '';
      final response = await _apiService.get('/doctors/filter$queryString');

      if (response.statusCode == 200) {
        return {'success': true, 'doctors': response.data['doctors']};
      }
      return {'success': false, 'message': 'Failed to filter doctors'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> updateAvailability({
    required List<String> availableDays,
    required Map<String, String> availableTime,
    required List<String> unavailableDates,
    int? bufferTime,
    bool? emergencySlots,
    int? followUpDuration,
    int? newPatientDuration,
    int? emergencyDuration,
  }) async {
    try {
      final response = await _apiService.post('/doctors/update_availability', {
        'availableDays': availableDays,
        'availableTime': availableTime,
        'unavailableDates': unavailableDates,
        'bufferTime': bufferTime,
        'emergencySlots': emergencySlots,
        'followUpDuration': followUpDuration,
        'newPatientDuration': newPatientDuration,
        'emergencyDuration': emergencyDuration,
      });
      return response.data;
    } catch (e) {
      debugPrint('Error updating availability: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAvailability() async {
    try {
      final response = await _apiService.get('/doctors/availability/me');

      if (response.statusCode == 200) {
        return {'success': true, 'availability': response.data['availability']};
      }
      return {'success': false, 'message': 'Failed to fetch availability'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('/doctors/stats');
      return response.data;
    } catch (e) {
      debugPrint('Error getting doctor stats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPatientHistory(String patientId) async {
    try {
      final response = await _apiService.get(
        '/doctors/patients/$patientId/history',
      );
      return response.data;
    } catch (e) {
      debugPrint('Error getting patient history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> assignHealthProgram(
    String patientId,
    String courseId,
  ) async {
    try {
      final response = await _apiService.post(
        '/doctors/patients/$patientId/assign-program',
        {'courseId': courseId},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error assigning program: $e');
      rethrow;
    }
  }
}
