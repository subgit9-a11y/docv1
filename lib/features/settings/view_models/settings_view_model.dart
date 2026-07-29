import 'package:flutter/material.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/network_api.dart';

class SettingsViewModel extends ChangeNotifier {
  bool isCallEnable = false;
  bool isDarkMode = false;
  bool isNotificationEnabled = true;
  bool isLoading = false;

  void loadSettings() {
    isDarkMode = SharedPreferenceHelper.getBoolean(Preferences.is_dark_mode);
    isNotificationEnabled =
        SharedPreferenceHelper.getBoolean(Preferences.is_notification_enabled);
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

  Future<void> fetchDoctorProfile(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
          await RestClient(await RetroApi().dioData(context)).doctorProfile();
      if (response.data?.patientVCall != null) {
        isCallEnable = response.data?.patientVCall == 1;
      }
    } catch (error) {
      // Handle error if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVCall(BuildContext context, bool val) async {
    isCallEnable = val;
    notifyListeners();

    int vCallData = val ? 1 : 0;
    Map<String, dynamic> body = {"patient_vcall": vCallData};
    try {
      final response = await RestClient(await RetroApi().dioData(context))
          .updatePatientVcallRequest(body);
      if (response.success == true) {
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    // API logic for deleting account if exists
  }

  Future<void> logoutUser(BuildContext context) async {
    // API/Pref clearing logic for logging out user if exists
  }
}
