import 'package:flutter/foundation.dart';
import 'api_service.dart';

class ConnectNowService {
  final ApiService _apiService = ApiService();

  // Patient: initiate instant consultation
  Future<Map<String, dynamic>> initiateConnect() async {
    try {
      final response = await _apiService.post('/connect-now/initiate', {});
      return response.data;
    } catch (e) {
      debugPrint('Initiate connect error: $e');
      rethrow;
    }
  }

  // Patient: poll request status
  Future<Map<String, dynamic>> getStatus(String requestId) async {
    try {
      final response = await _apiService.get('/connect-now/status/$requestId');
      return response.data;
    } catch (e) {
      debugPrint('Get status error: $e');
      rethrow;
    }
  }

  // Doctor: get pending requests
  Future<List<dynamic>> getDoctorPendingRequests() async {
    try {
      final response = await _apiService.get('/connect-now/doctor/pending');
      return response.data['requests'] ?? [];
    } catch (e) {
      debugPrint('Get doctor requests error: $e');
      return [];
    }
  }

  // Doctor: accept request
  Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    try {
      final response = await _apiService.post('/connect-now/$requestId/accept', {});
      return response.data;
    } catch (e) {
      debugPrint('Accept request error: $e');
      rethrow;
    }
  }

  // Doctor: reject request
  Future<void> rejectRequest(String requestId) async {
    try {
      await _apiService.post('/connect-now/$requestId/reject', {});
    } catch (e) {
      debugPrint('Reject request error: $e');
    }
  }
}
