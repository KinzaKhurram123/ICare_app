class LabResult {
  final String testParameter;
  final String value;
  final String unit;
  final ReferenceRange? referenceRange;
  final bool isAbnormal;
  final String severity; // normal, borderline, abnormal, critical

  LabResult({
    required this.testParameter,
    required this.value,
    required this.unit,
    this.referenceRange,
    this.isAbnormal = false,
    this.severity = 'normal',
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      testParameter: json['testParameter'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'] ?? '',
      referenceRange: json['referenceRange'] != null
          ? ReferenceRange.fromJson(json['referenceRange'])
          : null,
      isAbnormal: json['isAbnormal'] ?? false,
      severity: json['severity'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testParameter': testParameter,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange?.toJson(),
      'isAbnormal': isAbnormal,
      'severity': severity,
    };
  }
}

class ReferenceRange {
  final double? min;
  final double? max;
  final String? text;

  ReferenceRange({this.min, this.max, this.text});

  factory ReferenceRange.fromJson(Map<String, dynamic> json) {
    return ReferenceRange(
      min: json['min']?.toDouble(),
      max: json['max']?.toDouble(),
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max, 'text': text};
  }

  String get displayText {
    if (text != null && text!.isNotEmpty) return text!;
    if (min != null && max != null) return '$min-$max';
    if (min != null) return '≥ $min';
    if (max != null) return '≤ $max';
    return 'N/A';
  }
}
