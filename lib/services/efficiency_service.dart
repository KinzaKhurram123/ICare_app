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
      return [];
    }
  }

  Future<void> createPrescriptionTemplate(Map<String, dynamic> data) async {
    await _apiService.post('/efficiency/prescription-templates', data);
  }

  Future<void> updatePrescriptionTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    await _apiService.put(
      '/efficiency/prescription-templates/$templateId',
      data,
    );
  }

  Future<void> deletePrescriptionTemplate(String templateId) async {
    await _apiService.delete('/efficiency/prescription-templates/$templateId');
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
