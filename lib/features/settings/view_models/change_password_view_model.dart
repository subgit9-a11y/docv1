import 'package:flutter/material.dart';
import 'package:doctro/models/ChangePassword.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/network_api.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isHidden = true;
  bool isHidden1 = true;
  bool isHidden2 = true;

  void togglePasswordVisibility() {
    isHidden = !isHidden;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    isHidden1 = !isHidden1;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isHidden2 = !isHidden2;
    notifyListeners();
  }

  Future<ChangePasswordModel?> passwordChange(BuildContext context,
      String oldPassword, String newPassword, String confirmPassword) async {
    isLoading = true;
    notifyListeners();

    Map<String, dynamic> body = {
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    try {
      final response = await RestClient(await RetroApi().dioData(context))
          .changePasswordRequest(body);
      return response;
    } catch (error) {
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
