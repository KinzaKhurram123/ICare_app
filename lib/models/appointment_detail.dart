import 'package:icare/models/user.dart';

class AppointmentDetail {
  final String id;
  final User? doctor;
  final User? patient;
  final DateTime date;
  final String timeSlot;
  final String? reason;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentDetail({
    required this.id,
    this.doctor,
    this.patient,
    required this.date,
    required this.timeSlot,
    this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) {
    User? doctor;
    User? patient;

    try {
      if (json['doctor'] != null && json['doctor'] is Map) {
        doctor = User.fromJson(json['doctor'] as Map<String, dynamic>);
      }
    } catch (e) {
      print('⚠️ Error parsing doctor: $e');
    }

    try {
      if (json['patient'] != null && json['patient'] is Map) {
        patient = User.fromJson(json['patient'] as Map<String, dynamic>);
      }
    } catch (e) {
      print('⚠️ Error parsing patient: $e');
    }

    return AppointmentDetail(
      id: json['_id'] ?? '',
      doctor: doctor,
      patient: patient,
      date: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'] ?? '',
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get doctorName => doctor?.name ?? 'Doctor';
  String get doctorEmail => doctor?.email ?? 'N/A';
}

