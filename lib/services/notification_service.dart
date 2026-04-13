import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../utils/error_handler.dart';

class NotificationService {
  static final ApiService _apiService = ApiService();

  /// Send critical alert notification to doctor and patient
  Future<void> sendCriticalAlert({
    required String bookingId,
    required String doctorId,
    required String patientId,
    required String testName,
    required List<String> criticalParameters,
  }) async {
    try {
      await _apiService.post('/notifications/critical-alert', {
        'bookingId': bookingId,
        'doctorId': doctorId,
        'patientId': patientId,
        'testName': testName,
        'criticalParameters': criticalParameters,
        'channels': ['push', 'email', 'sms'], // Multi-channel
        'priority': 'high',
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'sendCriticalAlert');
      rethrow;
    }
  }

  /// Send test status update notification
  Future<void> sendStatusUpdate({
    required String bookingId,
    required String userId,
    required String status,
    required String userType, // 'patient' or 'doctor'
  }) async {
    try {
      await _apiService.post('/notifications/status-update', {
        'bookingId': bookingId,
        'userId': userId,
        'status': status,
        'userType': userType,
        'channels': ['push'],
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'sendStatusUpdate');
      rethrow;
    }
  }

  /// Send report ready notification
  Future<void> sendReportReady({
    required String bookingId,
    required String doctorId,
    required String patientId,
    required bool hasAbnormalResults,
  }) async {
    try {
      await _apiService.post('/notifications/report-ready', {
        'bookingId': bookingId,
        'doctorId': doctorId,
        'patientId': patientId,
        'hasAbnormalResults': hasAbnormalResults,
        'channels': ['push', 'email'],
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'sendReportReady');
      rethrow;
    }
  }

  /// Get user notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences(String userId) async {
    try {
      final response = await _apiService.get(
        '/notifications/preferences/$userId',
      );
      return response.data['preferences'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace,
        context: 'getNotificationPreferences',
      );
      rethrow;
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _apiService.put('/notifications/preferences/$userId', preferences);
    } catch (e, stackTrace) {
      ErrorHandler.logError(
        e,
        stackTrace,
        context: 'updateNotificationPreferences',
      );
      rethrow;
    }
  }

  /// Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory(
    String userId,
  ) async {
    try {
      final response = await _apiService.get('/notifications/history/$userId');
      return List<Map<String, dynamic>>.from(
        response.data['notifications'] ?? [],
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getNotificationHistory');
      rethrow;
    }
  }

  /// Get notifications for current user
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      return response.data;
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getNotifications');
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _apiService.put('/notifications/$id/read', {});
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'markAsRead');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/notifications/read-all', {});
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'markAllAsRead');
      rethrow;
    }
  }
}
