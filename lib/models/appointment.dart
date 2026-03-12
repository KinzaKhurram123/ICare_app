class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime date;
  final String timeSlot;
  final String? reason;
  final String status;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.timeSlot,
    this.reason,
    required this.status,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      doctorId: json['doctor'] is String ? json['doctor'] : json['doctor']?['_id'] ?? '',
      patientId: json['patient'] is String ? json['patient'] : json['patient']?['_id'] ?? '',
      date: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'] ?? '',
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      cancellationReason: json['cancellationReason'],
      cancelledBy: json['cancelledBy'],
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'reason': reason,
    };
  }
}
