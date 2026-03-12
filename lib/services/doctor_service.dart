import 'package:dio/dio.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getAllDoctors() async {
    try {
      final response = await _apiService.get('/doctors/get_all_doctors');

      if (response.statusCode == 200) {
        return {'success': true, 'doctors': response.data['doctors']};
      }
      return {'success': false, 'message': 'Failed to fetch doctors'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
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
      print('📋 Updating doctor profile...');
      print('Specialization: $specialization');
      print('Consultation Types: $consultationType');
      print('Languages: $languages');
      print('Degrees: $degrees');
      print('Available Days: $availableDays');
      print('Time: $startTime - $endTime');
      
      final requestData = {
        'specialization': specialization,
        'degrees': degrees,
        'experience': experience,
        'licenseNumber': licenseNumber,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'availableDays': availableDays,
        'availableTime': {
          'start': startTime,
          'end': endTime,
        },
      };
      
      if (consultationType != null && consultationType.isNotEmpty) {
        requestData['consultationType'] = consultationType;
      }
      
      if (languages != null && languages.isNotEmpty) {
        requestData['languages'] = languages;
      }
      
      final response = await _apiService.post('/doctors/add_doctor_details', requestData);

      print('✅ Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Profile updated successfully'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } on DioException catch (e) {
      print('❌ Error updating profile: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> addDoctorReview({
    required String doctorId,
    required double rating,
    String? review,
  }) async {
    try {
      print('⭐ Adding review for doctor: $doctorId');
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
        'message': e.response?.data['message'] ?? 'Network error'
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
        'message': e.response?.data['message'] ?? 'Network error'
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
      if (specialization != null) queryParams.add('specialization=$specialization');
      if (consultationType != null) queryParams.add('consultationType=$consultationType');
      if (language != null) queryParams.add('language=$language');
      if (minRating != null) queryParams.add('minRating=$minRating');
      
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiService.get('/doctors/filter$queryString');

      if (response.statusCode == 200) {
        return {'success': true, 'doctors': response.data['doctors']};
      }
      return {'success': false, 'message': 'Failed to filter doctors'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> updateAvailability({
    required List<String> availableDays,
    required Map<String, String> availableTime,
    List<String>? unavailableDates,
  }) async {
    try {
      print('📋 Updating availability...');
      final response = await _apiService.put('/doctors/availability', {
        'availableDays': availableDays,
        'availableTime': availableTime,
        if (unavailableDates != null) 'unavailableDates': unavailableDates,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Availability updated'};
      }
      return {'success': false, 'message': 'Failed to update availability'};
    } on DioException catch (e) {
      print('❌ Error updating availability: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
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
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }
}