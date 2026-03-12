import 'package:dio/dio.dart';
import 'package:icare/models/appointment.dart';
import 'package:icare/models/appointment_detail.dart';
import 'package:icare/services/api_service.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? reason,
  }) async {
    try {
      print('📅 Booking appointment...');
      print('Doctor ID: $doctorId');
      print('Date: $date');
      print('Time Slot: $timeSlot');
      print('Reason: $reason');

      final response = await _apiService.post(
        '/appointments/book_appointment',
        {
          'doctorId': doctorId,
          'date': date.toIso8601String(),
          'timeSlot': timeSlot,
          'reason': reason,
        },
      );

      print('✅ Appointment booked successfully');
      print('Response: ${response.data}');

      final data = response.data as Map<String, dynamic>;

      return {
        'success': true,
        'message': data['message'] ?? 'Appointment booked successfully',
        'appointment': data['appointment'] != null 
            ? Appointment.fromJson(data['appointment'])
            : null,
      };
    } on DioException catch (e) {
      print('❌ Appointment booking error: ${e.message}');
      print('Response: ${e.response?.data}');
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to book appointment',
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> getMyAppointmentsDetailed() async {
    try {
      print('📋 Fetching my appointments...');

      final response = await _apiService.get('/appointments/getAppointments');
      final data = response.data as Map<String, dynamic>;

      print('✅ Appointments fetched successfully');
      print('Count: ${data['count']}');
      print('Raw appointments data: ${data['appointments']}');

      final List<AppointmentDetail> appointments = [];
      if (data['appointments'] != null) {
        for (var appointmentJson in data['appointments']) {
          try {
            print('📝 Parsing appointment: $appointmentJson');
            appointments.add(AppointmentDetail.fromJson(appointmentJson));
          } catch (e) {
            print('⚠️ Error parsing appointment: $e');
            print('Appointment data: $appointmentJson');
          }
        }
      }

      print('✅ Successfully parsed ${appointments.length} appointments');

      return {
        'success': true,
        'appointments': appointments,
        'count': data['count'] ?? 0,
      };
    } on DioException catch (e) {
      print('❌ Get appointments error: ${e.message}');
      print('Response data: ${e.response?.data}');
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch appointments',
        'appointments': <AppointmentDetail>[],
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'appointments': <AppointmentDetail>[],
      };
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      print('📝 Updating appointment status...');
      print('Appointment ID: $appointmentId');
      print('New Status: $status');

      final response = await _apiService.put(
        '/appointments/update_status',
        {
          'appointmentId': appointmentId,
          'status': status,
        },
      );

      print('✅ Status updated successfully');

      final data = response.data as Map<String, dynamic>;

      return {
        'success': true,
        'message': data['message'] ?? 'Status updated successfully',
      };
    } on DioException catch (e) {
      print('❌ Update status error: ${e.message}');
      
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }
}

