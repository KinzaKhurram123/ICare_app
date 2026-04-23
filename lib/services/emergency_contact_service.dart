import 'package:icare/services/api_service.dart';

class EmergencyContactService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getContacts() async {
    final response = await _api.get('/paitents/emergency-contacts');
    final data = response.data;
    if (data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['contacts'] as List);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final response = await _api.post('/paitents/emergency-contacts', {
      'name': name,
      'phone': phone,
      'relation': relation,
    });
    final data = response.data;
    if (data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['contacts'] as List);
    }
    throw Exception(data['message'] ?? 'Failed to add contact');
  }

  Future<List<Map<String, dynamic>>> deleteContact(String contactId) async {
    final response = await _api.delete('/paitents/emergency-contacts/$contactId');
    final data = response.data;
    if (data['success'] == true) {
      return List<Map<String, dynamic>>.from(data['contacts'] as List);
    }
    throw Exception(data['message'] ?? 'Failed to delete contact');
  }
}
