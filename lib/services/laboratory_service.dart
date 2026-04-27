import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../utils/error_handler.dart';

class LaboratoryService {
  final ApiService _apiService = ApiService();

  // Get laboratory by ID
  Future<Map<String, dynamic>> getLabById(String labId) async {
    try {
      final response = await _apiService.get('/laboratories/$labId');
      return response.data['laboratory'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getLabById');
      rethrow;
    }
  }

  // Get all laboratories
  Future<List<dynamic>> getAllLaboratories() async {
    try {
      final response = await _apiService.get('/laboratories/get_all_laboratories');
      final list = (response.data['laboratories'] ?? []) as List;
      // Backend returns: { _id: profileId, user: { _id, name }, labName, city }
      return list.map((l) {
        final map = Map<String, dynamic>.from(l);
        final user = map['user'] as Map<String, dynamic>? ?? {};
        // Preserve original profile _id for routing (referredLaboratory, getLabById)
        map['profileId'] = map['_id']?.toString();
        // Also keep user._id available if needed
        map['userId'] = user['_id']?.toString();
        map['_id'] = map['profileId'];
        map['id'] = map['_id'];
        final displayName = map['labName']?.toString()
            ?? map['lab_name']?.toString()
            ?? user['name']?.toString()
            ?? 'Laboratory';
        map['labName'] = displayName;
        map['lab_name'] = displayName;
        map['name'] = displayName;
        return map;
      }).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getAllLaboratories');
      rethrow;
    }
  }

  // Get laboratory profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get('/laboratories/profile');
      return response.data['laboratory'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getProfile');
      rethrow;
    }
  }

  // Create laboratory booking
  Future<Map<String, dynamic>> createBooking(
    String labId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.post(
        '/laboratories/$labId/bookings',
        data,
      );
      return response.data['booking'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'createBooking');
      rethrow;
    }
  }

  // Get laboratory bookings (for lab admin)
  Future<List<dynamic>> getBookings(String labId, {String? status}) async {
    try {
      String url = '/laboratories/$labId/bookings';
      if (status != null) {
        url += '?status=$status';
      }
      final response = await _apiService.get(url);
      return response.data['bookings'] ?? [];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getBookings');
      rethrow;
    }
  }

  // Get my bookings (for patient)
  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await _apiService.get('/laboratories/bookings/my');
      return response.data['bookings'] ?? [];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getMyBookings');
      rethrow;
    }
  }

  // Update booking
  Future<Map<String, dynamic>> updateBooking(
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        '/laboratories/bookings/$bookingId',
        data,
      );
      return response.data['booking'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'updateBooking');
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    return updateBooking(bookingId, {'status': status});
  }

  // Get booking by ID
  Future<Map<String, dynamic>> getBookingById(String bookingId) async {
    try {
      final response = await _apiService.get(
        '/laboratories/bookings/$bookingId',
      );
      return response.data['booking'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getBookingById');
      rethrow;
    }
  }

  // Update laboratory profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        '/laboratories/add_laboratory_details',
        data,
      );
      return response.data['laboratory'] ?? response.data['existingProfile'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'updateProfile');
      rethrow;
    }
  }

  // Get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats(String labId) async {
    try {
      // Get all bookings
      final bookings = await getBookings(labId);

      final totalBookings = bookings.length;
      final pendingBookings = bookings
          .where((b) => b['status'] == 'pending')
          .length;
      final completedBookings = bookings
          .where((b) => b['status'] == 'completed')
          .length;
      final todayBookings = bookings.where((b) {
        final bookingDate =
            DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
        final today = DateTime.now();
        return bookingDate.year == today.year &&
            bookingDate.month == today.month &&
            bookingDate.day == today.day;
      }).length;

      // Sort by date to get recent activity
      final sortedBookings = List<dynamic>.from(bookings);
      sortedBookings.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['createdAt'] ?? a['date'] ?? '') ??
            DateTime.now();
        final dateB =
            DateTime.tryParse(b['createdAt'] ?? b['date'] ?? '') ??
            DateTime.now();
        return dateB.compareTo(dateA); // descending
      });

      final recentActivity = sortedBookings.take(5).toList();

      return {
        'totalBookings': totalBookings,
        'pendingBookings': pendingBookings,
        'completedBookings': completedBookings,
        'todayBookings': todayBookings,
        'recentActivity': recentActivity,
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'getDashboardStats');
      rethrow;
    }
  }

  // Rate a booking (patient side)
  Future<void> rateBooking({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _apiService.post('/laboratories/bookings/$bookingId/rate', {
        'rating': rating,
        'comment': comment,
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'rateBooking');
      rethrow;
    }
  }

  // Create walk-in order
  Future<Map<String, dynamic>> createWalkInOrder({
    required String patientName,
    required String contact,
    required String address,
    required String tests,
    required String collectionType,
  }) async {
    try {
      final profile = await getProfile();
      final labId = profile['_id'];
      final response = await _apiService.post(
        '/laboratories/$labId/bookings',
        {
          'patientName': patientName,
          'contact': contact,
          'address': address,
          'testName': tests,
          'collectionType': collectionType,
          'source': 'walk-in',
          'status': 'confirmed',
        },
      );
      return response.data['booking'] ?? {};
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'createWalkInOrder');
      rethrow;
    }
  }

  // Upload test result report
  Future<String> uploadReport(
    String bookingId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'report': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _apiService.postMultipart(
        '/laboratories/bookings/$bookingId/upload-report',
        formData,
      );

      // Assuming the backend returns the report URL
      return response.data['reportUrl'];
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace, context: 'uploadReport');
      rethrow;
    }
  }
}
