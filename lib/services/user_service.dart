import 'package:dio/dio.dart';
import 'api_service.dart';
import 'api_config.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getUserProfile({String? token}) async {
    try {
      print("🌐 Calling /users/profile endpoint...");

      // If token is provided, use it directly instead of reading from storage
      if (token != null) {
        print("🔑 Using provided token for this request");
      }

      final response = await _apiService.get('/users/profile', token: token);

      print("📡 Response status: ${response.statusCode}");
      print("📡 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data};
      }
      return {'success': false, 'message': 'Failed to fetch profile'};
    } on DioException catch (e) {
      print("❌ DioException in getUserProfile: ${e.message}");
      print("❌ Response: ${e.response?.data}");
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    } catch (e) {
      print("❌ Unexpected error in getUserProfile: $e");
      return {'success': false, 'message': 'Unexpected error: $e'};
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
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> searchUsers({
    String? query,
    String? role,
  }) async {
    try {
      final response = await _apiService.get(
        '/users/search',
        queryParameters: {
          if (query != null) 'q': query,
          if (role != null) 'role': role,
        },
      );
      return response.data;
    } catch (e) {
      print('Error searching users: $e');
      rethrow;
    }
  }
}
