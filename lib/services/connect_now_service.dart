import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../utils/shared_pref.dart';

class ConnectNowService {
  final ApiService _apiService = ApiService();
  final SharedPref _sharedPref = SharedPref();

  // Patient: initiate instant consultation
  Future<Map<String, dynamic>> initiateConnect() async {
    try {
      final userData = await _sharedPref.getUserData();
      final response = await _apiService.post('/connect-now/initiate', {
        'patientName': userData?.name ?? 'Patient',
      });
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

  // Doctor: check for pending requests
  Future<Map<String, dynamic>> checkPending() async {
    try {
      final response = await _apiService.get('/connect-now/pending');
      return response.data;
    } catch (e) {
      debugPrint('Check pending error: $e');
      return {'hasPending': false};
    }
  }

  // Doctor: accept request
  Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    try {
      final userData = await _sharedPref.getUserData();
      final response = await _apiService.post('/connect-now/accept', {
        'requestId': requestId,
        'doctorName': userData?.name ?? 'Doctor',
      });
      return response.data;
    } catch (e) {
      debugPrint('Accept request error: $e');
      rethrow;
    }
  }

  // Doctor: reject request (just cancel polling, no backend call needed)
  Future<void> rejectRequest(String requestId) async {
    // No backend call - just let it expire
    debugPrint('Request $requestId rejected by doctor');
  }

  // Doctor: set availability for instant consultation (notifies backend)
  Future<void> setInstantAvailability(bool isAvailable) async {
    try {
      await _apiService.post('/connect-now/available', {'isAvailable': isAvailable});
      debugPrint('✅ Instant availability set to: $isAvailable');
    } catch (e) {
      // Non-critical — frontend SharedPref toggle still controls behavior
      debugPrint('⚠️ Could not sync instant availability to backend: $e');
    }
  }
}
