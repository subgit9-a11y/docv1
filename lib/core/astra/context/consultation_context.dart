/// Consultation Context
///
/// Contains information about the current consultation/appointment.
/// Provides context for AI interactions during doctor-patient sessions.
class ConsultationContext {
  /// Consultation/appointment ID
  final String? id;
  
  /// Appointment date and time
  final DateTime? appointmentTime;
  
  /// Type of consultation (video, audio, in-person)
  final String? consultationType;
  
  /// Chief complaint/reason for visit
  final String? chiefComplaint;
  
  /// Patient's symptoms
  final List<String>? symptoms;
  
  /// Vital signs recorded
  final Map<String, dynamic>? vitalSigns;
  
  /// Diagnosis if made
  final String? diagnosis;
  
  /// Doctor's notes
  final String? notes;
  
  /// Follow-up date if scheduled
  final DateTime? followUpDate;
  
  /// Prescription ID if created
  final String? prescriptionId;
  
  /// Consultation status
  final ConsultationStatus? status;
  
  /// Screen from which Astra was opened
  final String? screenContext;

  ConsultationContext({
    this.id,
    this.appointmentTime,
    this.consultationType,
    this.chiefComplaint,
    this.symptoms,
    this.vitalSigns,
    this.diagnosis,
    this.notes,
    this.followUpDate,
    this.prescriptionId,
    this.status,
    this.screenContext,
  });

  /// Create from JSON
  factory ConsultationContext.fromJson(Map<String, dynamic> json) {
    return ConsultationContext(
      id: json['id']?.toString(),
      appointmentTime: json['appointment_time'] != null 
          ? DateTime.tryParse(json['appointment_time']) 
          : null,
      consultationType: json['consultation_type'],
      chiefComplaint: json['chief_complaint'],
      symptoms: json['symptoms'] != null 
          ? List<String>.from(json['symptoms']) 
          : null,
      vitalSigns: json['vital_signs'],
      diagnosis: json['diagnosis'],
      notes: json['notes'],
      followUpDate: json['follow_up_date'] != null 
          ? DateTime.tryParse(json['follow_up_date']) 
          : null,
      prescriptionId: json['prescription_id']?.toString(),
      status: _parseStatus(json['status']),
      screenContext: json['screen_context'],
    );
  }

  static ConsultationStatus? _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return ConsultationStatus.scheduled;
      case 'in_progress':
        return ConsultationStatus.inProgress;
      case 'completed':
        return ConsultationStatus.completed;
      case 'cancelled':
        return ConsultationStatus.cancelled;
      case 'no_show':
        return ConsultationStatus.noShow;
      default:
        return null;
    }
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (appointmentTime != null) 
          'appointment_time': appointmentTime!.toIso8601String(),
      if (consultationType != null) 'consultation_type': consultationType,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (symptoms != null) 'symptoms': symptoms,
      if (vitalSigns != null) 'vital_signs': vitalSigns,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (notes != null) 'notes': notes,
      if (followUpDate != null) 
          'follow_up_date': followUpDate!.toIso8601String(),
      if (prescriptionId != null) 'prescription_id': prescriptionId,
      if (status != null) 'status': status!.name,
      if (screenContext != null) 'screen_context': screenContext,
    };
  }

  /// Check if consultation is active
  bool get isActive => 
      status == ConsultationStatus.inProgress ||
      status == ConsultationStatus.scheduled;

  /// Check if follow-up is recommended
  bool get needsFollowUp => followUpDate == null && status == ConsultationStatus.completed;

  /// Get consultation type display name
  String get consultationTypeDisplay {
    switch (consultationType?.toLowerCase()) {
      case 'video':
        return 'Video Consultation';
      case 'audio':
        return 'Audio Consultation';
      case 'chat':
        return 'Chat Consultation';
      case 'in_person':
        return 'In-Person Visit';
      default:
        return 'Consultation';
    }
  }

  /// Get symptoms as formatted string
  String get symptomsSummary {
    if (symptoms == null || symptoms!.isEmpty) return 'No symptoms recorded';
    return 'Symptoms: ${symptoms!.join(', ')}';
  }

  /// Get vital signs summary
  String get vitalSignsSummary {
    if (vitalSigns == null || vitalSigns!.isEmpty) {
      return 'No vital signs recorded';
    }
    final parts = <String>[];
    if (vitalSigns!['bp'] != null) parts.add('BP: ${vitalSigns!['bp']}');
    if (vitalSigns!['heart_rate'] != null) {
      parts.add('HR: ${vitalSigns!['heart_rate']} bpm');
    }
    if (vitalSigns!['temperature'] != null) {
      parts.add('Temp: ${vitalSigns!['temperature']}°F');
    }
    if (vitalSigns!['spo2'] != null) {
      parts.add('SpO2: ${vitalSigns!['spo2']}%');
    }
    return parts.isNotEmpty ? parts.join(', ') : 'No vital signs recorded';
  }

  /// Create a copy with updated fields
  ConsultationContext copyWith({
    String? id,
    DateTime? appointmentTime,
    String? consultationType,
    String? chiefComplaint,
    List<String>? symptoms,
    Map<String, dynamic>? vitalSigns,
    String? diagnosis,
    String? notes,
    DateTime? followUpDate,
    String? prescriptionId,
    ConsultationStatus? status,
    String? screenContext,
  }) {
    return ConsultationContext(
      id: id ?? this.id,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      consultationType: consultationType ?? this.consultationType,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      vitalSigns: vitalSigns ?? this.vitalSigns,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      status: status ?? this.status,
      screenContext: screenContext ?? this.screenContext,
    );
  }

  @override
  String toString() => 'ConsultationContext($id, $status)';
}

/// Consultation status enum
enum ConsultationStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

/// Screen context types for Astra
class ScreenContextType {
  static const String home = 'home';
  static const String patientDetails = 'patient_details';
  static const String prescription = 'prescription';
  static const String appointment = 'appointment';
  static const String chat = 'chat';
  static const String notifications = 'notifications';
  static const String reports = 'reports';
  static const String videoCall = 'video_call';
  static const String dashboard = 'dashboard';
  static const String cart = 'cart';
  static const String storage = 'storage';
  static const String reminders = 'reminders';
  static const String profile = 'profile';
  static const String payment = 'payment';
  static const String unknown = 'unknown';

  /// Get display name for screen
  static String getDisplayName(String context) {
    switch (context) {
      case home:
        return 'Home';
      case patientDetails:
        return 'Patient Details';
      case prescription:
        return 'Prescription';
      case appointment:
        return 'Appointments';
      case chat:
        return 'Chat';
      case notifications:
        return 'Notifications';
      case reports:
        return 'Reports';
      case videoCall:
        return 'Video Call';
      case dashboard:
        return 'Dashboard';
      case cart:
        return 'Cart';
      case storage:
        return 'Storage';
      case reminders:
        return 'Reminders';
      case profile:
        return 'Profile';
      case payment:
        return 'Payment';
      default:
        return 'App';
    }
  }
}
