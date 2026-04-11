import 'package:flutter/foundation.dart';
import 'package:icare/services/api_service.dart';

class CommunityService {
  final ApiService _apiService = ApiService();

  // Forums & Discussions
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiService.get('/community/categories');
      return response.data['categories'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getDiscussions(String categoryId) async {
    try {
      final response = await _apiService.get(
        '/community/discussions/$categoryId',
      );
      return response.data['discussions'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> createDiscussion(Map<String, dynamic> data) async {
    await _apiService.post('/community/discussions', data);
  }

  Future<void> replyToDiscussion(
    String discussionId,
    Map<String, dynamic> data,
  ) async {
    await _apiService.post(
      '/community/discussions/$discussionId/replies',
      data,
    );
  }

  // Moderation (Admin/Expert only)
  Future<void> reportContent(String type, String id, String reason) async {
    await _apiService.post('/community/reports', {
      'type': type,
      'id': id,
      'reason': reason,
    });
  }

  Future<void> deleteContent(String type, String id) async {
    await _apiService.delete('/community/$type/$id');
  }
}
