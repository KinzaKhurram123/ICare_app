import 'user.dart';

class MedicalRecord {
  final String id;
  final User patient;
  final User doctor;
  final String? appointmentId;
  final String? diagnosis;
  final List<String> symptoms;
  final Prescription? prescription;
  final List<String> labTests;
  final VitalSigns? vitalSigns;
  final String? notes;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    required this.id,
    required this.patient,
    required this.doctor,
    this.appointmentId,
    this.diagnosis,
    this.symptoms = const [],
    this.prescription,
    this.labTests = const [],
    this.vitalSigns,
    this.notes,
    this.followUpDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    // Handle doctor field - can be either a populated object or just an ID string
    User? doctor;
    if (json['doctor'] != null) {
      if (json['doctor'] is Map<String, dynamic>) {
        doctor = User.fromJson(json['doctor']);
      } else if (json['doctor'] is String) {
        // If doctor is just an ID, create a minimal User object
        doctor = User(
          id: json['doctor'],
          name: 'Doctor',
          email: '',
          phoneNumber: '',
          role: 'doctor',
        );
      }
    }
    
    return MedicalRecord(
      id: json['_id'] ?? '',
      patient: User.fromJson(json['patient'] ?? {}),
      doctor: doctor ?? User(id: '', name: 'Unknown', email: '', phoneNumber: '', role: 'doctor'),
      appointmentId: json['appointment']?['_id'],
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'] != null 
          ? List<String>.from(json['symptoms']) 
          : [],
      prescription: json['prescription'] != null 
          ? Prescription.fromJson(json['prescription']) 
          : null,
      labTests: json['labTests'] != null 
          ? List<String>.from(json['labTests']) 
          : [],
      vitalSigns: json['vitalSigns'] != null 
          ? VitalSigns.fromJson(json['vitalSigns']) 
          : null,
      notes: json['notes'],
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patient.id,
      'appointmentId': appointmentId,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'prescription': prescription?.toJson(),
      'labTests': labTests,
      'vitalSigns': vitalSigns?.toJson(),
      'notes': notes,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }
}

class Prescription {
  final List<Medicine> medicines;
  final String? notes;

  Prescription({
    this.medicines = const [],
    this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicines: json['medicines'] != null
          ? (json['medicines'] as List).map((m) => Medicine.fromJson(m)).toList()
          : [],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'notes': notes,
    };
  }
}

class Medicine {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  Medicine({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class VitalSigns {
  final String? bloodPressure;
  final String? temperature;
  final String? heartRate;
  final String? weight;
  final String? height;

  VitalSigns({
    this.bloodPressure,
    this.temperature,
    this.heartRate,
    this.weight,
    this.height,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      bloodPressure: json['bloodPressure'],
      temperature: json['temperature'],
      heartRate: json['heartRate'],
      weight: json['weight'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodPressure': bloodPressure,
      'temperature': temperature,
      'heartRate': heartRate,
      'weight': weight,
      'height': height,
    };
  }
}
