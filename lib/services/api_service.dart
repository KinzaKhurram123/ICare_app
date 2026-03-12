import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<void> _setAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    await _setAuthToken();
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint) async {
    await _setAuthToken();
    return await _dio.get(endpoint);
  }

  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    await _setAuthToken();
    return await _dio.put(endpoint, data: data);
  }

  Future<Response> delete(String endpoint) async {
    await _setAuthToken();
    return await _dio.delete(endpoint);
  }
}
