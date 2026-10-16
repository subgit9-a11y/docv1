import 'package:doctro/models/ForgotPassword.dart';
import 'package:doctro/network/base_model.dart';
import 'package:doctro/widgets/osler_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final String _msg = "";
  String get msg => _msg;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // The legacy `forgot_password` REST endpoint is permanently dead (404).
  // Auth now runs through Firebase, which has its own password-reset email
  // flow - no custom backend route is needed for this at all.
  Future<BaseModel<ForgotPassword>> forgotPasswordScreenRequest(
      BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "SignIn");
        OslerToast.success(
            context, "Password reset link sent. Please check your email.");
      }
      return BaseModel()
        ..data = ForgotPassword(success: true, msg: "Reset email sent");
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      final message = switch (e.code) {
        'user-not-found' => "No account found with this email.",
        'invalid-email' => "Please enter a valid email address.",
        _ => e.message ?? "Failed to send reset email.",
      };
      if (context.mounted) OslerToast.error(context, message);
      // ServerError.withError() only handles DioException; a
      // FirebaseAuthException would crash it via an unguarded downcast, and
      // nothing reads this model's error on the caller side anyway.
      return BaseModel()..data = ForgotPassword(success: false, msg: message);
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        OslerToast.error(context, "Failed to send reset email: $error");
      }
      return BaseModel()..data = ForgotPassword(success: false, msg: "$error");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
