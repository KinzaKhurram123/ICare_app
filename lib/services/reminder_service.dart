import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:icare/utils/api_constants.dart';
import 'package:icare/utils/shared_pref.dart';

class ReminderService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final SharedPref _sharedPref = SharedPref();

  Future<List<dynamic>> getMyReminders() async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.get(
        '/api/reminders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['reminders'] as List;
    } on DioException catch (e) {
      debugPrint('Error fetching reminders: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> data) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await _dio.post(
        '/api/reminders',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.message};
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final token = await _sharedPref.getToken();
      await _dio.delete(
        '/api/reminders/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      debugPrint('Error deleting reminder: ${e.message}');
    }
  }
}
