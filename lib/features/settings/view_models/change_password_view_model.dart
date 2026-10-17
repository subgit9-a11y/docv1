import 'package:flutter/material.dart';
import 'package:doctro/models/ChangePassword.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // The legacy `doctor_change_password` REST endpoint is permanently dead
  // (404). Auth now runs through Firebase, which can re-authenticate and
  // change the password client-side with no custom backend route needed.
  Future<ChangePasswordModel?> passwordChange(BuildContext context,
      String oldPassword, String newPassword, String confirmPassword) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) {
        return ChangePasswordModel(
            success: false,
            data: "No signed-in email account to change the password for.");
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: oldPassword),
      );
      await user.updatePassword(newPassword);

      return ChangePasswordModel(
          success: true, data: "Password changed successfully");
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' =>
          "Current password is incorrect.",
        'weak-password' => "New password is too weak.",
        _ => e.message ?? "Failed to change password.",
      };
      return ChangePasswordModel(success: false, data: message);
    } catch (error) {
      return ChangePasswordModel(success: false, data: "$error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
