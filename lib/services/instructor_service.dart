import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:icare/services/api_config.dart';
import 'package:icare/services/api_service.dart';
import 'package:icare/services/auth_service.dart';

class InstructorService {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();
  String? _cachedInstructorId;

  // Q&A Management
  Future<List<dynamic>> getAllPendingQuestions() async {
    try {
      final response = await _apiService.get('/instructor/qa/pending');
      return response.data['questions'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> replyToQuestion(String questionId, String reply) async {
    await _apiService.post('/instructor/qa/reply', {
      'questionId': questionId,
      'reply': reply,
    });
  }

  // Earnings & Wallet
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final response = await _apiService.get('/instructor/earnings/summary');
      return response.data['summary'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getPayoutHistory() async {
    try {
      final response = await _apiService.get('/instructor/earnings/payouts');
      return response.data['payouts'] ?? [];
    } catch (e) {
      return [];
    }
  }

  // Detailed Analytics
  Future<Map<String, dynamic>> getAssessmentAnalytics(String courseId) async {
    try {
      final response = await _apiService.get(
        '/instructor/analytics/assessments/$courseId',
      );
      return response.data['analytics'] ?? {};
    } catch (e) {
      return {};
    }
  }

  // Get instructor profile for logged-in instructor
  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _apiService.get('/instructors/me');
    final instructor = response.data['instructor'];
    // Cache the user_id (not profile _id) — courses/precautions are keyed by user_id
    _cachedInstructorId = instructor['user_id'] as String? ?? instructor['_id'];
    return instructor;
  }

  // Update/Create instructor profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiService.post(
      '/instructors/add_instructor_details',
      data,
    );
    return response.data['instructor'] ?? response.data['existingProfile'];
  }

  // Get all instructors (public)
  Future<List<dynamic>> getAllInstructors() async {
    final response = await _apiService.get('/instructors/get_all_instructors');
    return response.data['instructors'] as List;
  }

  // Get instructor by ID
  Future<Map<String, dynamic>> getInstructorById(String id) async {
    final response = await _apiService.get('/instructors/$id');
    return response.data['instructor'];
  }

  Future<String> _getInstructorId() async {
    if (_cachedInstructorId != null) {
      return _cachedInstructorId!;
    }
    final profile = await getMyProfile();
    return profile['_id'];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // COURSES MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════

  // Get my courses
  Future<List<dynamic>> getMyCourses() async {
    try {
      final instructorId = await _getInstructorId();
      final response = await _apiService.get(
        '/instructors/courses?instructorId=$instructorId',
      );
      return response.data['courses'] as List;
    } catch (e) {
      debugPrint('Error getting my courses: $e');
      rethrow;
    }
  }

  // Get all public courses
  Future<List<dynamic>> getAllCourses({
    String? visibility,
    String? search,
  }) async {
    String url = '/instructors/courses';
    List<String> params = [];

    if (visibility != null) params.add('visibility=$visibility');
    if (search != null && search.isNotEmpty)
      params.add('q=${Uri.encodeComponent(search)}');

    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await _apiService.get(url);
    return response.data['courses'] as List;
  }

  // Get course by ID
  Future<Map<String, dynamic>> getCourseById(String id) async {
    final response = await _apiService.get('/instructors/courses/$id');
    return response.data['course'];
  }

  // Create course
  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> data) async {
    final response = await _apiService.post('/instructors/courses', data);
    return response.data['course'];
  }

  // Update course
  Future<Map<String, dynamic>> updateCourse(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put('/instructors/courses/$id', data);
    return response.data['course'];
  }

  // Delete course
  Future<void> deleteCourse(String id) async {
    await _apiService.delete('/instructors/courses/$id');
  }

  // Assign course to doctor/student
  Future<Map<String, dynamic>> assignCourse(
    String courseId,
    String targetUserId,
  ) async {
    try {
      final response = await _apiService.post('/instructors/courses/assign', {
        'courseId': courseId,
        'targetUserId': targetUserId,
      });
      return response.data;
    } catch (e) {
      debugPrint('Error assigning course: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PRECAUTIONS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════

  // Get my precautions
  Future<List<dynamic>> getMyPrecautions() async {
    try {
      final instructorId = await _getInstructorId();
      final response = await _apiService.get(
        '/instructors/precautions?instructorId=$instructorId',
      );
      return response.data['precautions'] as List;
    } catch (e) {
      debugPrint('Error getting my precautions: $e');
      rethrow;
    }
  }

  // Get all precautions
  Future<List<dynamic>> getAllPrecautions({String? instructorId}) async {
    String url = '/instructors/precautions';
    if (instructorId != null) url += '?instructorId=$instructorId';

    final response = await _apiService.get(url);
    return response.data['precautions'] as List;
  }

  // Get precaution by ID
  Future<Map<String, dynamic>> getPrecautionById(String id) async {
    final response = await _apiService.get('/instructors/precautions/$id');
    return response.data['precaution'];
  }

  // Create precaution
  Future<Map<String, dynamic>> createPrecaution(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post('/instructors/precautions', data);
    return response.data['precaution'];
  }

  // Update precaution
  Future<Map<String, dynamic>> updatePrecaution(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(
      '/instructors/precautions/$id',
      data,
    );
    return response.data['precaution'];
  }

  // Delete precaution
  Future<void> deletePrecaution(String id) async {
    await _apiService.delete('/instructors/precautions/$id');
  }

  // STATISTICS
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('/instructors/stats');
      return response.data['stats'] ?? {};
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return {};
    }
  }

  // Get assigned learners (enrolled students)
  Future<List<dynamic>> getAssignedLearners() async {
    try {
      final response = await _apiService.get('/instructors/assigned-learners');
      return response.data['learners'] ?? [];
    } catch (e) {
      debugPrint('Error getting assigned learners: $e');
      rethrow;
    }
  }

  // Upload video file for course lessons
  Future<Map<String, dynamic>> uploadVideo({
    String? filePath,
    List<int>? bytes,
    required String fileName,
  }) async {
    try {
      final token = await AuthService().getToken();

      MultipartFile file;
      if (kIsWeb) {
        if (bytes == null) throw Exception('Bytes required for web upload');
        file = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        if (filePath == null) {
          throw Exception('File path required for mobile upload');
        }
        file = await MultipartFile.fromFile(filePath, filename: fileName);
      }

      final formData = FormData.fromMap({'video': file});

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/instructors/videos/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      debugPrint('❌ Failed to upload video: $e');
      throw Exception('Failed to upload video: $e');
    }
  }

  // Upload thumbnail image for course
  Future<Map<String, dynamic>> uploadThumbnail({
    String? filePath,
    List<int>? bytes,
    required String fileName,
  }) async {
    try {
      final token = await AuthService().getToken();

      MultipartFile file;
      if (kIsWeb) {
        if (bytes == null) throw Exception('Bytes required for web upload');
        file = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        if (filePath == null) {
          throw Exception('File path required for mobile upload');
        }
        file = await MultipartFile.fromFile(filePath, filename: fileName);
      }

      final formData = FormData.fromMap({'thumbnail': file});

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/instructors/thumbnails/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response.data;
    } catch (e) {
      debugPrint('❌ Failed to upload thumbnail: $e');
      throw Exception('Failed to upload thumbnail: $e');
    }
  }
}
