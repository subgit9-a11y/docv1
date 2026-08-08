import 'package:flutter/material.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Doctor Context
///
/// Contains information about the current doctor using the app.
/// Automatically fetched from preferences/storage.
class DoctorContext {
  /// Doctor's unique identifier
  final String id;
  
  /// Doctor's full name
  final String name;
  
  /// Doctor's email
  final String? email;
  
  /// Doctor's phone number
  final String? phone;
  
  /// Doctor's specialization
  final String? specialization;
  
  /// Doctor's registration/license number
  final String? licenseNumber;
  
  /// Profile image URL
  final String? profileImageUrl;
  
  /// Clinic/hospital name
  final String? clinicName;
  
  /// Clinic address
  final String? clinicAddress;

  DoctorContext({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.specialization,
    this.licenseNumber,
    this.profileImageUrl,
    this.clinicName,
    this.clinicAddress,
  });

  /// Create from shared preferences
  factory DoctorContext.fromPreferences() {
    final id = SharedPreferenceHelper.getString(Preferences.userId);
    final name = SharedPreferenceHelper.getString(Preferences.userName);
    final email = SharedPreferenceHelper.getString(Preferences.email);
    final phone = SharedPreferenceHelper.getString(Preferences.phone);
    final specialization = SharedPreferenceHelper.getString(Preferences.specialization);
    
    return DoctorContext(
      id: id.isNotEmpty ? id : 'unknown',
      name: name.isNotEmpty ? name : 'Unknown Doctor',
      email: email.isNotEmpty ? email : null,
      phone: phone.isNotEmpty ? phone : null,
      specialization: specialization.isNotEmpty ? specialization : null,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (specialization != null) 'specialization': specialization,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (clinicName != null) 'clinic_name': clinicName,
      if (clinicAddress != null) 'clinic_address': clinicAddress,
    };
  }

  /// Get short display name
  String get displayName => name;

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  @override
  String toString() => 'DoctorContext($name, $id)';
}

/// Global doctor context accessor
class DoctorContextProvider {
  static DoctorContext? _current;

  /// Get current doctor context
  static DoctorContext get current {
    _current ??= DoctorContext.fromPreferences();
    return _current!;
  }

  /// Refresh from preferences
  static void refresh() {
    _current = DoctorContext.fromPreferences();
    AstraLogger.d('Doctor context refreshed: ${_current?.name}');
  }

  /// Set custom context (for testing)
  static void setContext(DoctorContext context) {
    _current = context;
  }

  /// Clear context
  static void clear() {
    _current = null;
  }
}
