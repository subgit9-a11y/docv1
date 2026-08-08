import 'package:doctro/models/astra/patient_model.dart';

/// Patient Context
///
/// Contains information about the current patient being viewed/consulted.
/// This is the primary context for AI interactions.
class PatientContext {
  /// Patient's unique identifier
  final String id;
  
  /// Patient's full name
  final String name;
  
  /// Patient's phone number
  final String? phone;
  
  /// Patient's email
  final String? email;
  
  /// Patient's age
  final int? age;
  
  /// Patient's gender
  final String? gender;
  
  /// Patient's date of birth
  final String? dateOfBirth;
  
  /// Patient's address
  final String? address;
  
  /// List of allergies
  final List<String>? allergies;
  
  /// List of chronic conditions
  final List<String>? chronicConditions;
  
  /// Blood group
  final String? bloodGroup;
  
  /// Height in cm
  final double? height;
  
  /// Weight in kg
  final double? weight;
  
  /// Patient code
  final String? patientCode;
  
  /// Profile image URL
  final String? profileImageUrl;
  
  /// Medical history summary
  final String? medicalHistorySummary;

  PatientContext({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.age,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.allergies,
    this.chronicConditions,
    this.bloodGroup,
    this.height,
    this.weight,
    this.patientCode,
    this.profileImageUrl,
    this.medicalHistorySummary,
  });

  /// Create from AstraPatient model
  factory PatientContext.fromPatient(AstraPatient patient) {
    return PatientContext(
      id: patient.id ?? patient.patientId ?? 'unknown',
      name: patient.name ?? 'Unknown Patient',
      phone: patient.phone,
      email: patient.email,
      age: patient.age,
      gender: patient.gender,
      dateOfBirth: patient.dateOfBirth,
      address: _formatAddress(patient),
      allergies: patient.allergies,
      chronicConditions: patient.chronicConditions,
      bloodGroup: patient.bloodGroup,
      height: patient.height,
      weight: patient.weight,
      patientCode: patient.patientCode,
      profileImageUrl: patient.profileImageUrl,
    );
  }

  static String? _formatAddress(AstraPatient patient) {
    final parts = <String>[];
    if (patient.address != null && patient.address!.isNotEmpty) {
      parts.add(patient.address!);
    }
    if (patient.city != null && patient.city!.isNotEmpty) {
      parts.add(patient.city!);
    }
    if (patient.state != null && patient.state!.isNotEmpty) {
      parts.add(patient.state!);
    }
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// Create from JSON
  factory PatientContext.fromJson(Map<String, dynamic> json) {
    return PatientContext(
      id: json['id']?.toString() ?? 'unknown',
      name: json['name'] ?? 'Unknown Patient',
      phone: json['phone'],
      email: json['email'],
      age: json['age'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null,
      chronicConditions: json['chronic_conditions'] != null 
          ? List<String>.from(json['chronic_conditions']) 
          : null,
      bloodGroup: json['blood_group'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      patientCode: json['patient_code'],
      profileImageUrl: json['profile_image_url'],
      medicalHistorySummary: json['medical_history_summary'],
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (allergies != null && allergies!.isNotEmpty) 
          'allergies': allergies,
      if (chronicConditions != null && chronicConditions!.isNotEmpty) 
          'chronic_conditions': chronicConditions,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (patientCode != null) 'patient_code': patientCode,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (medicalHistorySummary != null) 
          'medical_history_summary': medicalHistorySummary,
    };
  }

  /// Get BMI if available
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  /// Get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if patient has allergies
  bool get hasAllergies => allergies != null && allergies!.isNotEmpty;

  /// Check if patient has chronic conditions
  bool get hasChronicConditions => 
      chronicConditions != null && chronicConditions!.isNotEmpty;

  /// Get short display name
  String get displayName => name;

  /// Get age string with gender
  String get ageGender {
    final parts = <String>[];
    if (age != null) parts.add('$age years');
    if (gender != null) parts.add(gender!);
    return parts.join(', ');
  }

  /// Get allergies as formatted string
  String get allergiesSummary {
    if (!hasAllergies) return 'No known allergies';
    return 'Allergies: ${allergies!.join(', ')}';
  }

  /// Get chronic conditions as formatted string
  String get chronicConditionsSummary {
    if (!hasChronicConditions) return 'No chronic conditions';
    return 'Chronic: ${chronicConditions!.join(', ')}';
  }

  @override
  String toString() => 'PatientContext($name, $id)';
}

/// Global patient context accessor
class PatientContextProvider {
  static PatientContext? _current;

  /// Get current patient context
  static PatientContext? get current => _current;

  /// Set current patient context
  static void setContext(PatientContext? context) {
    _current = context;
  }

  /// Set from AstraPatient
  static void setFromPatient(AstraPatient patient) {
    _current = PatientContext.fromPatient(patient);
  }

  /// Clear context
  static void clear() {
    _current = null;
  }

  /// Check if patient context is available
  static bool get hasContext => _current != null;
}
