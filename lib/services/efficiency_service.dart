import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:icare/services/api_service.dart';

class EfficiencyService {
  final ApiService _apiService = ApiService();

  // Prescription Templates
  Future<List<dynamic>> getPrescriptionTemplates() async {
    try {
      final response = await _apiService.get(
        '/efficiency/prescription-templates',
      );
      return response.data['templates'] ?? [];
    } catch (e) {
      debugPrint('❌ getPrescriptionTemplates error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createPrescriptionTemplate(Map<String, dynamic> data) async {
    try {
      debugPrint('📋 Creating prescription template: ${data['name']}');
      final response = await _apiService.post('/efficiency/prescription-templates', data);
      debugPrint('✅ Template created: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Unexpected response: ${response.statusCode}'};
    } on DioException catch (e) {
      debugPrint('❌ createPrescriptionTemplate DioException: ${e.response?.data}');
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      return {'success': false, 'message': msg};
    } catch (e) {
      debugPrint('❌ createPrescriptionTemplate error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updatePrescriptionTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        '/efficiency/prescription-templates/$templateId',
        data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to update template'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Network error'};
    }
  }

  Future<Map<String, dynamic>> deletePrescriptionTemplate(String templateId) async {
    try {
      final response = await _apiService.delete('/efficiency/prescription-templates/$templateId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to delete template'};
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? 'Network error'};
    }
  }

  // Advanced Availability
  Future<void> updateAvailability(Map<String, dynamic> data) async {
    await _apiService.post('/efficiency/availability', data);
  }

  Future<Map<String, dynamic>> getAvailability() async {
    final response = await _apiService.get('/efficiency/availability');
    return response.data['availability'] ?? {};
  }

  // Drug Interaction Check
  Future<Map<String, dynamic>> checkDrugInteractions(
    List<String> drugIds,
  ) async {
    final response = await _apiService.post(
      '/efficiency/drug-interaction-check',
      {'drugIds': drugIds},
    );
    return response.data['results'] ?? {};
  }
}
