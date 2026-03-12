import 'package:dio/dio.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiService.get('/notifications');

      if (response.statusCode == 200) {
        return {'success': true, 'notifications': response.data['notifications']};
      }
      return {'success': false, 'message': 'Failed to fetch notifications'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put('/notifications/$notificationId/read', {});

      if (response.statusCode == 200) {
        return {'success': true, 'notification': response.data['notification']};
      }
      return {'success': false, 'message': 'Failed to mark as read'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiService.put('/notifications/mark-all-read', {});

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'All marked as read'};
      }
      return {'success': false, 'message': 'Failed to mark all as read'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }

  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Notification deleted'};
      }
      return {'success': false, 'message': 'Failed to delete notification'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error'
      };
    }
  }
}
