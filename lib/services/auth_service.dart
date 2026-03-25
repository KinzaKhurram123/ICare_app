import 'package:dio/dio.dart';
import '../utils/shared_pref.dart';
import 'api_service.dart';
import 'api_config.dart';
import 'fcm_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SharedPref _sharedPref = SharedPref();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'phoneNumber': phoneNumber ?? '0000000000',
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        await _saveToken(data['token']);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Registration failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveToken(data['token']);
        await _saveUserData(data);
        // Send FCM token to backend after successful login
        FcmService().getAndSaveToken();
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Login failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<void> _saveToken(String token) async {
    await _sharedPref.setToken(token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    // User data is saved through auth provider, keeping this for compatibility
  }

  Future<String?> getToken() async {
    return await _sharedPref.getToken();
  }

  Future<void> logout() async {
    await _sharedPref.remove('token');
    await _sharedPref.remove('userData');
    await _sharedPref.remove('userRole');
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgetPassword,
        {'email': email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent to your email',
          'otp': response.data['otp'], // For testing
        };
      }
      return {'success': false, 'message': 'Failed to send OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.checkOTP,
        {'email': email, 'code': code},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP verified successfully'};
      }
      return {'success': false, 'message': 'Invalid OTP'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.resetPassword,
        {
          'email': email,
          'password': password,
          'confirmpassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset successfully'};
      }
      return {'success': false, 'message': 'Failed to reset password'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
}
