import 'package:flutter/foundation.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getMyTasks({String? status}) async {
    try {
      final response = await _apiService.get(
        '/tasks/my',
        queryParameters: status != null ? {'status': status} : null,
      );
      return response.data['tasks'];
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(
    String taskId,
    String status,
  ) async {
    try {
      final response = await _apiService.put('/tasks/$taskId/status', {
        'status': status,
      });
      return response.data['task'];
    } catch (e) {
      debugPrint('Error updating task status: $e');
      rethrow;
    }
  }
}
