import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class LmsService {
  final ApiService _api = ApiService();

  // ── COURSES (public) ─────────────────────────────────────────────────────
  Future<List<dynamic>> getPublicCourses({String? query, String? category}) async {
    try {
      final params = <String, dynamic>{};
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (category != null && category != 'All') params['category'] = category;
      final res = await _api.get('/courses/public', queryParameters: params.isEmpty ? null : params);
      return (res.data['courses'] as List?) ?? [];
    } catch (e) {
      debugPrint('getPublicCourses error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMyEnrollments() async {
    try {
      final res = await _api.get('/courses/enrollments/my');
      return (res.data['enrollments'] ?? res.data['items'] as List?) ?? [];
    } catch (e) {
      debugPrint('getMyEnrollments error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> enrollCourse(String courseId) async {
    try {
      final res = await _api.post('/courses/enrollments', {'courseId': courseId});
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  Future<List<dynamic>> getEnrolledStudents(String courseId) async {
    try {
      final res = await _api.get('/courses/enrolled-students/$courseId');
      return (res.data['students'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  // ── ANNOUNCEMENTS (Stream) ───────────────────────────────────────────────
  Future<List<dynamic>> getAnnouncements(String courseId) async {
    try {
      final res = await _api.get('/lms/announcements/course/$courseId');
      return (res.data['posts'] as List?) ?? [];
    } catch (e) {
      debugPrint('getAnnouncements error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> postAnnouncement(String courseId, String content, {String? attachmentUrl, String? attachmentName}) async {
    try {
      final res = await _api.post('/lms/announcements', {
        'courseId': courseId,
        'content': content,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        if (attachmentName != null) 'attachmentName': attachmentName,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  Future<void> addComment(String postId, String text) async {
    try {
      await _api.post('/lms/announcements/$postId/comment', {'text': text});
    } catch (e) {
      debugPrint('addComment error: $e');
    }
  }

  // ── ASSIGNMENTS ──────────────────────────────────────────────────────────
  Future<List<dynamic>> getCourseAssignments(String courseId) async {
    try {
      final res = await _api.get('/lms/assignments/course/$courseId');
      return (res.data['assignments'] as List?) ?? [];
    } catch (e) {
      debugPrint('getCourseAssignments error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createAssignment({
    required String courseId, required String title, String? description,
    String? dueDate, int totalMarks = 100,
  }) async {
    try {
      final res = await _api.post('/lms/assignments', {
        'courseId': courseId, 'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate,
        'totalMarks': totalMarks,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  Future<Map<String, dynamic>> submitAssignment(String assignmentId, {String? content, String? fileUrl, String? fileName}) async {
    try {
      final res = await _api.post('/lms/assignments/$assignmentId/submit', {
        if (content != null) 'content': content,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName != null) 'fileName': fileName,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  Future<Map<String, dynamic>?> getMySubmission(String assignmentId) async {
    try {
      final res = await _api.get('/lms/assignments/$assignmentId/my-submission');
      return res.data['submission'];
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getSubmissions(String assignmentId) async {
    try {
      final res = await _api.get('/lms/assignments/$assignmentId/submissions');
      return (res.data['submissions'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> gradeSubmission(String submissionId, int marks, {String? feedback}) async {
    try {
      final res = await _api.put('/lms/assignments/submissions/$submissionId/grade', {
        'marksObtained': marks,
        if (feedback != null) 'feedback': feedback,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }

  // ── GRADES ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> getCourseGrades(String courseId) async {
    try {
      final res = await _api.get('/lms/assignments/course/$courseId/my-grades');
      return (res.data['grades'] as List?) ?? [];
    } catch (e) {
      debugPrint('getCourseGrades error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllMyGrades() async {
    try {
      final res = await _api.get('/lms/assignments/my-grades');
      return (res.data['grades'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  // ── ATTENDANCE ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMyAttendance(String courseId) async {
    try {
      final res = await _api.get('/lms/attendance/course/$courseId/my');
      return res.data;
    } catch (e) {
      return {'attendance': [], 'total': 0, 'present': 0, 'percentage': 0};
    }
  }

  Future<List<dynamic>> getCourseAttendanceSessions(String courseId) async {
    try {
      final res = await _api.get('/lms/attendance/course/$courseId');
      return (res.data['sessions'] as List?) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createAttendanceSession({
    required String courseId, required String sessionDate,
    String sessionTitle = 'Class Session', required List<Map<String, dynamic>> records,
  }) async {
    try {
      final res = await _api.post('/lms/attendance', {
        'courseId': courseId, 'sessionTitle': sessionTitle,
        'sessionDate': sessionDate, 'records': records,
      });
      return res.data;
    } on DioException catch (e) {
      return {'success': false, 'message': e.response?.data?['message'] ?? e.message};
    }
  }
}
