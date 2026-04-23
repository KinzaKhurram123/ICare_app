import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/shared_pref.dart';
import 'package:flutter/foundation.dart';

class LifestyleService {
  static final SharedPref _sharedPref = SharedPref();
  
  static Future<String?> _getToken() async {
    try {
      final token = await _sharedPref.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No token found in SharedPreferences');
        return null;
      }
      debugPrint('✅ Token retrieved successfully');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getTodayData() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      debugPrint('📡 Fetching today\'s lifestyle data...');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/lifestyle/today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Lifestyle data fetched successfully');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception(
          'Failed to load lifestyle data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error in getTodayData: $e');
      throw Exception('Error loading lifestyle data: $e');
    }
  }

  static Future<Map<String, dynamic>> updateData({
    double? waterIntake,
    double? sleepHours,
    int? steps,
    int? exercise,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }
      
      final body = <String, dynamic>{};

      if (waterIntake != null) body['waterIntake'] = waterIntake;
      if (sleepHours != null) body['sleepHours'] = sleepHours;
      if (steps != null) body['steps'] = steps;
      if (exercise != null) body['exercise'] = exercise;
      if (notes != null) body['notes'] = notes;

      debugPrint('📤 Updating lifestyle data: $body');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/lifestyle/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Lifestyle data updated successfully');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to update lifestyle data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating lifestyle data: $e');
      throw Exception('Error updating lifestyle data: $e');
    }
  }

  static Future<Map<String, dynamic>> getHistory({int days = 7}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }
      
      debugPrint('📡 Fetching lifestyle history for last $days days...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/lifestyle/history?days=$days'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ History fetched successfully');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      throw Exception('Error loading history: $e');
    }
  }

  static Future<Map<String, dynamic>> getWeeklySummary() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }
      
      debugPrint('📡 Fetching weekly summary...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/lifestyle/weekly-summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Weekly summary fetched successfully');
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load weekly summary: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error loading weekly summary: $e');
      throw Exception('Error loading weekly summary: $e');
    }
  }
}