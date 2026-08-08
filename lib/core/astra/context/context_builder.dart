import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:doctro/core/astra/context/doctor_context.dart';
import 'package:doctro/core/astra/context/patient_context.dart';
import 'package:doctro/core/astra/context/consultation_context.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Context Builder
///
/// Centralized context management for Astra AI requests.
/// Automatically assembles complete context from available sources.
class ContextBuilder {
  ContextBuilder._();
  static final ContextBuilder instance = ContextBuilder._();

  /// Current language code (default: English)
  String _currentLanguage = 'en';
  
  /// Current screen context
  String _currentScreenContext = ScreenContextType.unknown;

  // ============================================================
  // CONTEXT ASSEMBLY
  // ============================================================

  /// Build complete context for Astra API call
  /// This is the ONLY method widgets should call to get context
  AstraRequestContext buildContext({
    String? additionalPrompt,
    Map<String, dynamic>? additionalData,
  }) {
    final context = AstraRequestContext(
      doctor: DoctorContextProvider.current,
      patient: PatientContextProvider.current,
      consultation: _currentConsultation,
      language: _currentLanguage,
      screenContext: _currentScreenContext,
      timestamp: DateTime.now().toIso8601String(),
      additionalPrompt: additionalPrompt,
      additionalData: additionalData,
    );

    AstraLogger.d('Context built: ${context.summary}');
    return context;
  }

  /// Quick context for non-patient screens
  AstraRequestContext buildDoctorContext({
    String? additionalPrompt,
  }) {
    return AstraRequestContext(
      doctor: DoctorContextProvider.current,
      patient: null,
      consultation: null,
      language: _currentLanguage,
      screenContext: _currentScreenContext,
      timestamp: DateTime.now().toIso8601String(),
      additionalPrompt: additionalPrompt,
    );
  }

  /// Context with specific focus (e.g., for suggestions)
  AstraRequestContext buildFocusedContext({
    required String focus,
    PatientContext? patient,
  }) {
    return AstraRequestContext(
      doctor: DoctorContextProvider.current,
      patient: patient ?? PatientContextProvider.current,
      consultation: _currentConsultation,
      language: _currentLanguage,
      screenContext: _currentScreenContext,
      timestamp: DateTime.now().toIso8601String(),
      additionalPrompt: 'Focus: $focus',
    );
  }

  // ============================================================
  // SCREEN CONTEXT
  // ============================================================

  /// Update current screen context
  void setScreenContext(String screen) {
    if (_currentScreenContext != screen) {
      _currentScreenContext = screen;
      AstraLogger.d('Screen context changed to: $screen');
    }
  }

  /// Get current screen context
  String get currentScreenContext => _currentScreenContext;

  /// Reset to unknown (called on app lifecycle change)
  void resetScreenContext() {
    _currentScreenContext = ScreenContextType.unknown;
  }

  // ============================================================
  // LANGUAGE
  // ============================================================

  /// Set current language
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    AstraLogger.d('Language set to: $languageCode');
  }

  /// Get current language
  String get currentLanguage => _currentLanguage;

  // ============================================================
  // CONSULTATION CONTEXT
  // ============================================================

  ConsultationContext? _currentConsultation;

  /// Set current consultation context
  void setConsultationContext(ConsultationContext? context) {
    _currentConsultation = context;
    if (context != null) {
      AstraLogger.d('Consultation context set: ${context.id}');
    }
  }

  /// Get current consultation context
  ConsultationContext? get currentConsultation => _currentConsultation;

  /// Update consultation (e.g., after diagnosis)
  void updateConsultation(ConsultationContext context) {
    _currentConsultation = context;
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  /// Convert context to JSON string for caching
  String? contextToJson(AstraRequestContext context) {
    try {
      return jsonEncode(context.toJson());
    } catch (e) {
      AstraLogger.e('Failed to serialize context', error: e);
      return null;
    }
  }

  /// Restore context from JSON
  AstraRequestContext? contextFromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return AstraRequestContext.fromJson(map);
    } catch (e) {
      AstraLogger.e('Failed to deserialize context', error: e);
      return null;
    }
  }

  // ============================================================
  // CONTEXT OBSERVER
  // ============================================================

  final List<VoidCallback> _listeners = [];

  /// Add listener for context changes
  void addListener(VoidCallback callback) {
    _listeners.add(callback);
  }

  /// Remove listener
  void removeListener(VoidCallback callback) {
    _listeners.remove(callback);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Refresh all context and notify listeners
  void refresh() {
    DoctorContextProvider.refresh();
    _notifyListeners();
    AstraLogger.d('Context refreshed');
  }

  /// Clear all context
  void clear() {
    _currentConsultation = null;
    PatientContextProvider.clear();
    _currentScreenContext = ScreenContextType.unknown;
    _notifyListeners();
    AstraLogger.d('Context cleared');
  }
}

/// Complete request context for Astra API
class AstraRequestContext {
  final DoctorContext doctor;
  final PatientContext? patient;
  final ConsultationContext? consultation;
  final String language;
  final String screenContext;
  final String timestamp;
  final String? additionalPrompt;
  final Map<String, dynamic>? additionalData;

  AstraRequestContext({
    required this.doctor,
    this.patient,
    this.consultation,
    required this.language,
    required this.screenContext,
    required this.timestamp,
    this.additionalPrompt,
    this.additionalData,
  });

  /// Create from JSON
  factory AstraRequestContext.fromJson(Map<String, dynamic> json) {
    return AstraRequestContext(
      doctor: DoctorContext.fromJson(json['doctor'] ?? {}),
      patient: json['patient'] != null 
          ? PatientContext.fromJson(json['patient']) 
          : null,
      consultation: json['consultation'] != null 
          ? ConsultationContext.fromJson(json['consultation']) 
          : null,
      language: json['language'] ?? 'en',
      screenContext: json['screen_context'] ?? ScreenContextType.unknown,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      additionalPrompt: json['additional_prompt'],
      additionalData: json['additional_data'],
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor.toJson(),
      if (patient != null) 'patient': patient!.toJson(),
      if (consultation != null) 'consultation': consultation!.toJson(),
      'language': language,
      'screen_context': screenContext,
      'timestamp': timestamp,
      if (additionalPrompt != null) 'additional_prompt': additionalPrompt,
      if (additionalData != null) 'additional_data': additionalData,
    };
  }

  /// Get summary for logging
  String get summary {
    final parts = <String>[];
    parts.add('Doctor: ${doctor.name}');
    if (patient != null) {
      parts.add('Patient: ${patient!.name}');
    }
    if (consultation != null) {
      parts.add('Consultation: ${consultation!.id ?? "none"}');
    }
    parts.add('Screen: $screenContext');
    parts.add('Lang: $language');
    return parts.join(' | ');
  }

  /// Check if has complete context
  bool get hasFullContext => patient != null && consultation != null;

  /// Check if has patient context
  bool get hasPatientContext => patient != null;

  /// Get patient summary for prompts
  String get patientSummary {
    if (patient == null) return 'No patient selected';
    
    final parts = <String>[];
    parts.add('Patient: ${patient!.name}');
    if (patient!.age != null) parts.add('Age: ${patient!.age}');
    if (patient!.gender != null) parts.add('Gender: ${patient!.gender}');
    if (patient!.hasAllergies) {
      parts.add(patient!.allergiesSummary);
    }
    if (patient!.hasChronicConditions) {
      parts.add(patient!.chronicConditionsSummary);
    }
    if (patient!.bmi != null) {
      parts.add('BMI: ${patient!.bmi!.toStringAsFixed(1)} (${patient!.bmiCategory})');
    }
    return parts.join('\n');
  }

  /// Get consultation summary for prompts
  String get consultationSummary {
    if (consultation == null) return 'No active consultation';
    
    final parts = <String>[];
    parts.add('Type: ${consultation!.consultationTypeDisplay}');
    if (consultation!.chiefComplaint != null) {
      parts.add('Chief Complaint: ${consultation!.chiefComplaint}');
    }
    parts.add(consultation!.symptomsSummary);
    parts.add(consultation!.vitalSignsSummary);
    if (consultation!.diagnosis != null) {
      parts.add('Diagnosis: ${consultation!.diagnosis}');
    }
    return parts.join('\n');
  }
}

/// Global context builder accessor
final astraContext = ContextBuilder.instance;
