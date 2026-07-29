import 'package:doctro/models/ForgotPassword.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/base_model.dart';
import 'package:doctro/network/network_api.dart';
import 'package:doctro/network/server_error.dart';
import 'package:doctro/widgets/osler_toast.dart';
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

  Future<BaseModel<ForgotPassword>> forgotPasswordScreenRequest(
      BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    ForgotPassword response;
    try {
      Map<String, dynamic> body = {"email": _emailController.text.trim()};
      response = await RestClient(await RetroApi().dioData(context))
          .forgotPasswordScreen(body);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        if (response.success == true) {
          Navigator.pushReplacementNamed(context, "SignIn");
          if (response.msg != null && response.msg!.isNotEmpty) {
            OslerToast.success(context, response.msg!);
          }
        } else {
          if (response.msg != null && response.msg!.isNotEmpty) {
            OslerToast.error(context, response.msg!);
          }
        }
      }
      return BaseModel()..data = response;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return BaseModel()..setException(ServerError.withError(error: error));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
