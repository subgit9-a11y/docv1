import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/core/constants/app_string.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'view_models/change_password_view_model.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late double height;
  late double width;

  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Scaffold(
        backgroundColor: AyurezeTheme.canvas,
        appBar: AppBar(
          backgroundColor: AyurezeTheme.canvas,
          leading: IconButton(
            icon: Icon(
              AppIcons.back,
              color: AyurezeTheme.forestDeep,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            getTranslated(context, AppString.change_password_heading)
                .toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AyurezeTheme.textPrimary,
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            padding: AyurezeTheme.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  const SizedBox(height: 18),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AyurezeTheme.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              "Security update",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Keep your doctor workspace protected.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Update your password with a calmer Ayureze-style form that keeps the task focused and clear.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Consumer<ChangePasswordViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AyurezeTheme.panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(getTranslated(context, AppString.change_old_password)
                  .toString()),
              TextFormField(
                controller: _oldPassword,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9!@#\$.*&~_]'))
                ],
                decoration: InputDecoration(
                  hintText:
                      getTranslated(context, AppString.change_old_password_hint)
                          .toString(),
                  suffixIcon: _toggleIcon(viewModel.isHidden, () {
                    viewModel.togglePasswordVisibility();
                  }),
                ),
                obscureText: viewModel.isHidden,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return getTranslated(
                            context, AppString.please_enter_old_password)
                        .toString();
                  } else if (value.length < 6) {
                    return getTranslated(
                            context, AppString.please_enter_valid_password)
                        .toString();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _fieldLabel(
                  getTranslated(context, AppString.change_enter_new_password)
                      .toString()),
              TextFormField(
                controller: _newPassword,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9!@#\$.*&~_]'))
                ],
                decoration: InputDecoration(
                  hintText: getTranslated(
                          context, AppString.change_enter_new_password_hint)
                      .toString(),
                  suffixIcon: _toggleIcon(viewModel.isHidden1, () {
                    viewModel.toggleNewPasswordVisibility();
                  }),
                ),
                obscureText: viewModel.isHidden1,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return getTranslated(
                            context, AppString.please_enter_new_password)
                        .toString();
                  } else if (value.length < 6) {
                    return getTranslated(
                            context, AppString.please_enter_valid_password)
                        .toString();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _fieldLabel(getTranslated(
                      context, AppString.change_enter_confirm_password)
                  .toString()),
              TextFormField(
                controller: _confirmPassword,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9!@#\$.*&~_]'))
                ],
                decoration: InputDecoration(
                  hintText: getTranslated(
                          context, AppString.change_enter_confirm_password_hint)
                      .toString(),
                  suffixIcon: _toggleIcon(viewModel.isHidden2, () {
                    viewModel.toggleConfirmPasswordVisibility();
                  }),
                ),
                obscureText: viewModel.isHidden2,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return getTranslated(
                            context, AppString.please_enter_confirm_password)
                        .toString();
                  } else if (_newPassword.text != _confirmPassword.text) {
                    return getTranslated(context, AppString.confirm_not_match)
                        .toString();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: viewModel.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AyurezeTheme.forestDeep,
                        ),
                      )
                    : OslerButton(
                        text: getTranslated(
                                context, AppString.change_password_button)
                            .toString(),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final response = await viewModel.passwordChange(
                              context,
                              _oldPassword.text,
                              _newPassword.text,
                              _confirmPassword.text,
                            );

                            if (response != null) {
                              if (response.success == true) {
                                OslerToast.success(context, response.data!);
                                Navigator.pop(context);
                              } else {
                                OslerToast.error(context, response.data!);
                              }
                            }
                          }
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AyurezeTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _toggleIcon(bool hidden, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        hidden ? AppIcons.visibility : AppIcons.visibilityOff,
        color: AyurezeTheme.textSecondary,
      ),
      onPressed: onTap,
    );
  }
}
