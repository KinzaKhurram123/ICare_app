import 'package:icare/services/api_service.dart';

class LmsService {
  final ApiService _api = ApiService();

  // ═══════════════════════════════════════════════════════════════════════
  // VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getMyVerificationStatus() async {
    final response = await _api.get('/verification/my-status');
    return response.data;
  }

  Future<Map<String, dynamic>> uploadVerificationDocuments({
    required List<String> filePaths,
    required List<String> documentTypes,
  }) async {
    // TODO: Implement file upload
    // For now, return mock response
    return {
      'success': true,
      'verification': {
        'status': 'pending',
        'verificationLevel': 'limited'
      }
    };
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LIVE SESSIONS
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseSessions(String courseId) async {
    final response = await _api.get('/live-sessions/course/$courseId');
    return response.data['sessions'] ?? [];
  }

  Future<List<dynamic>> getUpcomingSessions() async {
    final response = await _api.get('/live-sessions/upcoming');
    return response.data['sessions'] ?? [];
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    final response = await _api.post('/live-sessions/$sessionId/join', {});
    return response.data;
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> sessionData) async {
    final response = await _api.post('/live-sessions', sessionData);
    return response.data;
  }

  Future<Map<String, dynamic>> updateSession(String sessionId, Map<String, dynamic> data) async {
    final response = await _api.put('/live-sessions/$sessionId', data);
    return response.data;
  }

  Future<void> cancelSession(String sessionId) async {
    await _api.post('/live-sessions/$sessionId/cancel', {});
  }

  // ═══════════════════════════════════════════════════════════════════════
  // QUIZZES
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseQuizzes(String courseId) async {
    final response = await _api.get('/quizzes/course/$courseId');
    return response.data['quizzes'] ?? [];
  }

  Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final response = await _api.get('/quizzes/$quizId');
    return response.data;
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
    required int timeSpent,
  }) async {
    final response = await _api.post('/quizzes/$quizId/submit', {
      'answers': answers,
      'timeSpent': timeSpent,
    });
    return response.data;
  }

  Future<List<dynamic>> getMyQuizAttempts(String quizId) async {
    final response = await _api.get('/quizzes/$quizId/my-attempts');
    return response.data['attempts'] ?? [];
  }

  Future<Map<String, dynamic>> createQuiz(Map<String, dynamic> quizData) async {
    final response = await _api.post('/quizzes', quizData);
    return response.data;
  }

  Future<Map<String, dynamic>> updateQuiz(String quizId, Map<String, dynamic> data) async {
    final response = await _api.put('/quizzes/$quizId', data);
    return response.data;
  }

  Future<void> deleteQuiz(String quizId) async {
    await _api.delete('/quizzes/$quizId');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ANNOUNCEMENTS (Stream)
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseAnnouncements(String courseId) async {
    try {
      final response = await _api.get('/lms/announcements/course/$courseId');
      return response.data['announcements'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAnnouncements(String courseId) async {
    return getCourseAnnouncements(courseId);
  }

  Future<Map<String, dynamic>> createAnnouncement(Map<String, dynamic> data) async {
    final response = await _api.post('/lms/announcements', data);
    return response.data;
  }

  Future<Map<String, dynamic>> postAnnouncement(String courseId, String content) async {
    return createAnnouncement({
      'courseId': courseId,
      'content': content,
    });
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await _api.delete('/lms/announcements/$announcementId');
  }

  Future<void> addComment(String announcementId, String comment) async {
    await _api.post('/lms/announcements/$announcementId/comment', {
      'comment': comment,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ASSIGNMENTS (from existing routes)
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseAssignments(String courseId) async {
    final response = await _api.get('/lms/assignments/course/$courseId');
    return response.data['assignments'] ?? [];
  }

  Future<Map<String, dynamic>> getMySubmission(String assignmentId) async {
    final response = await _api.get('/lms/assignments/$assignmentId/my-submission');
    return response.data;
  }

  Future<Map<String, dynamic>> submitAssignment({
    required String assignmentId,
    String? content,
    String? fileUrl,
  }) async {
    final response = await _api.post('/lms/assignments/$assignmentId/submit', {
      'content': content,
      'fileUrl': fileUrl,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> createAssignment(Map<String, dynamic> data) async {
    final response = await _api.post('/lms/assignments', data);
    return response.data;
  }

  Future<List<dynamic>> getSubmissions(String assignmentId) async {
    final response = await _api.get('/lms/assignments/$assignmentId/submissions');
    return response.data['submissions'] ?? [];
  }

  Future<Map<String, dynamic>> gradeSubmission(
    String submissionId,
    num marksObtained, {
    String? feedback,
  }) async {
    final response = await _api.put('/lms/assignments/submissions/$submissionId/grade', {
      'marksObtained': marksObtained,
      'feedback': feedback,
    });
    return response.data;
  }

  Future<List<dynamic>> getMyGrades(String courseId) async {
    final response = await _api.get('/lms/assignments/course/$courseId/my-grades');
    return response.data['grades'] ?? [];
  }

  Future<List<dynamic>> getCourseGrades(String courseId) async {
    return getMyGrades(courseId);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ATTENDANCE
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseAttendance(String courseId) async {
    try {
      final response = await _api.get('/lms/attendance/course/$courseId');
      return response.data['attendance'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> markAttendance({
    required String sessionId,
    required String courseId,
    required String status,
  }) async {
    final response = await _api.post('/lms/attendance', {
      'sessionId': sessionId,
      'courseId': courseId,
      'status': status,
    });
    return response.data;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PEOPLE (Course Members)
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<dynamic>> getCourseStudents(String courseId) async {
    final response = await _api.get('/courses/enrolled-students/$courseId');
    return response.data['students'] ?? [];
  }

  Future<List<dynamic>> getEnrolledStudents(String courseId) async {
    return getCourseStudents(courseId);
  }
}
