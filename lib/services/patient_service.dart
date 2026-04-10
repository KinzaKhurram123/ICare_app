// lib/services/patient_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/shared_pref.dart';
import 'package:flutter/foundation.dart';

class PatientService {
  final SharedPref _sharedPref = SharedPref();

  Future<String?> _getToken() async {
    return await _sharedPref.getToken();
  }

  Future<Map<String, dynamic>> getMyPatients() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/patients/my-patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'patients': data['patients'] ?? []};
      } else {
        return {'success': false, 'message': 'Failed to load patients'};
      }
    } catch (e) {
      debugPrint('Error loading patients: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
