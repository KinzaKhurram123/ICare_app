import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/shared_pref.dart';

final _sharedPref = SharedPref();

class ICDService {
  static Future<List<dynamic>> searchICDCodes(String query) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/icd-codes/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      } else {
        throw Exception('Failed to search ICD codes');
      }
    } catch (e) {
      throw Exception('Error searching ICD codes: $e');
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final token = await _sharedPref.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/icd-codes/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['categories'] ?? []);
      } else {
        throw Exception('Failed to get categories');
      }
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  static Future<List<dynamic>> getCodesByCategory(String category) async {
    try {
      final token = await _sharedPref.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/icd-codes/category/$category'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['codes'] ?? [];
      } else {
        throw Exception('Failed to get codes by category');
      }
    } catch (e) {
      throw Exception('Error getting codes by category: $e');
    }
  }
}
