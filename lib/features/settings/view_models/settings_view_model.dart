import 'package:flutter/material.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/services/astra_api_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool isCallEnable = true;
  bool isDarkMode = false;
  bool isNotificationEnabled = true;
  bool isLoading = false;

  void loadSettings() {
    isDarkMode = SharedPreferenceHelper.getBoolean(Preferences.is_dark_mode);
    isNotificationEnabled =
        SharedPreferenceHelper.getBoolean(Preferences.is_notification_enabled);
    // The real doctor profile (GET /api/v1/api/doctors/{id}) has no
    // patient-vcall field - the last value this app itself wrote via
    // updatePatientVcall() is the only source of truth available client-side.
    isCallEnable = SharedPreferenceHelper.getBooleanOrNull(
            Preferences.is_patient_vcall_enabled) ??
        true;
    notifyListeners();
  }

  void setDarkMode(bool val) {
    isDarkMode = val;
    notifyListeners();
  }

  void setNotificationEnabled(bool val) {
    isNotificationEnabled = val;
    SharedPreferenceHelper.setBoolean(Preferences.is_notification_enabled, val);
    notifyListeners();
  }

  // The legacy `doctorProfile()`/`updatePatientVcallRequest()` REST calls
  // (Apis.doctor_profile / Apis.updatePatientVcall) are permanently dead
  // (404). The real, confirmed-live route is AstraApiService.
  // updatePatientVcall() -> POST /api/v1/video/update-patient-vcall.
  Future<bool> updateVCall(BuildContext context, bool val) async {
    isCallEnable = val;
    notifyListeners();

    try {
      await AstraApiService().updatePatientVcall(val);
      SharedPreferenceHelper.setBoolean(
          Preferences.is_patient_vcall_enabled, val);
      return true;
    } catch (error) {
      return false;
    }
  }
}
