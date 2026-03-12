import 'user.dart';

class Doctor {
  final String id;
  final User user;
  final String? specialization;
  final List<String> consultationType;
  final List<String> languages;
  final List<String> degrees;
  final String? experience;
  final String? licenseNumber;
  final String? clinicName;
  final String? clinicAddress;
  final List<String> availableDays;
  final AvailableTime? availableTime;
  final bool isApproved;
  final List<double> ratings;
  final List<String> reviews;

  Doctor({
    required this.id,
    required this.user,
    this.specialization,
    this.consultationType = const [],
    this.languages = const [],
    this.degrees = const [],
    this.experience,
    this.licenseNumber,
    this.clinicName,
    this.clinicAddress,
    this.availableDays = const [],
    this.availableTime,
    this.isApproved = false,
    this.ratings = const [],
    this.reviews = const [],
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      specialization: json['specialization'],
      consultationType: json['consultationType'] != null 
          ? List<String>.from(json['consultationType']) 
          : [],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : [],
      degrees: json['degrees'] != null 
          ? List<String>.from(json['degrees']) 
          : [],
      experience: json['experience'],
      licenseNumber: json['licenseNumber'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      availableDays: json['availableDays'] != null 
          ? List<String>.from(json['availableDays']) 
          : [],
      availableTime: json['availableTime'] != null 
          ? AvailableTime.fromJson(json['availableTime']) 
          : null,
      isApproved: json['isApproved'] ?? false,
      ratings: json['ratings'] != null 
          ? List<double>.from(json['ratings'].map((r) => r.toDouble())) 
          : [],
      reviews: json['reviews'] != null 
          ? List<String>.from(json['reviews']) 
          : [],
    );
  }

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  int get reviewCount => reviews.length;
}

class AvailableTime {
  final String start;
  final String end;

  AvailableTime({
    required this.start,
    required this.end,
  });

  factory AvailableTime.fromJson(Map<String, dynamic> json) {
    return AvailableTime(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}
