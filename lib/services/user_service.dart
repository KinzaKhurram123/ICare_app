import 'package:dio/dio.dart';
import 'api_service.dart';
import 'api_config.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get('/users/profile');

      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data};
      }
      return {'success': false, 'message': 'Failed to fetch profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
    String? profilePicture,
  }) async {
    try {
      final response = await _apiService.put('/users/profile', {
        'name': name,
        'phoneNumber': phoneNumber,
        if (profilePicture != null) 'profilePicture': profilePicture,
      });

      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }
}
