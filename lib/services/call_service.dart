import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import '../utils/shared_pref.dart';

class CallService {
  final Dio _dio = Dio();
  final SharedPref _sharedPref = SharedPref();

  Future<String?> _getToken() async {
    final token = await _sharedPref.getToken();
    return token?.trim();
  }

  Future<Map<String, dynamic>> initiateCall({
    required String receiverId,
    required String channelName,
    required String callerName,
    String callType = 'video',
  }) async {
    try {
      debugPrint('📞 Initiating call to $receiverId ($callerName)');
      debugPrint('📞 Channel: $channelName, Type: $callType');

      final token = await _getToken();
      if (token == null) {
        debugPrint('❌ No token found, cannot initiate call');
        return {};
      }

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/call/initiate',
        data: {
          'receiverId': receiverId,
          'channelName': channelName,
          'callerName': callerName,
          'callType': callType,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('✅ Call initiated successfully: ${response.data}');
      return response.data ?? {};
    } catch (e) {
      debugPrint('❌ Failed to initiate call: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>?> checkIncomingCall() async {
    try {
      final token = await _getToken();
      if (token == null) return null;
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/call/incoming',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (s) => s! < 500,
        ),
      );
      if (response.statusCode == 200 &&
          response.data['success'] == true &&
          response.data['hasIncomingCall'] == true) {
        debugPrint('📞 Incoming call found: ${response.data['signal']}');
        return response.data['signal'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error checking incoming call: $e');
      return null;
    }
  }

  Future<void> respondToCall(String signalId, String action) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '${ApiConfig.baseUrl}/call/respond',
        data: {'signalId': signalId, 'action': action},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }

  Future<void> endCall(String channelName) async {
    try {
      final token = await _getToken();
      await _dio.post(
        '${ApiConfig.baseUrl}/call/end',
        data: {'channelName': channelName},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }
}
