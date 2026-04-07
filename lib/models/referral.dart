import 'user.dart';

class Referral {
  final String id;
  final User patient;
  final User referringDoctor;
  final User? referredToDoctor;
  final String reason;
  final String? clinicalNotes;
  final List<String> attachedRecords;
  final String status; // pending, accepted, completed, declined
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? declineReason;
  final String? consultationSummary;

  Referral({
    required this.id,
    required this.patient,
    required this.referringDoctor,
    this.referredToDoctor,
    required this.reason,
    this.clinicalNotes,
    this.attachedRecords = const [],
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.declineReason,
    this.consultationSummary,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['_id'] ?? '',
      patient: User.fromJson(json['patient']),
      referringDoctor: User.fromJson(json['doctor']),
      referredToDoctor: json['referredTo'] != null
          ? User.fromJson(json['referredTo'])
          : null,
      reason: json['reason'] ?? '',
      clinicalNotes: json['clinicalNotes'],
      attachedRecords: json['attachedRecords'] != null
          ? List<String>.from(json['attachedRecords'])
          : [],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      declineReason: json['declineReason'],
      consultationSummary: json['consultationSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patient.id,
      'referredTo': referredToDoctor?.id,
      'reason': reason,
      'clinicalNotes': clinicalNotes,
      'attachedRecords': attachedRecords,
    };
  }
}
