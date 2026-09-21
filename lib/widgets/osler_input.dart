import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctro/theme/ayureze_theme.dart';

class OslerInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  /// Overrides for a screen that opts out of the default light card look
  /// (e.g. the night + gold SignIn). Leaving these null keeps every other
  /// existing caller's appearance unchanged.
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;

  const OslerInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: labelColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintColor != null ? TextStyle(color: hintColor) : null,
            filled: true,
            fillColor: fillColor ?? AyurezeTheme.oslerGray10,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusLg),
              borderSide: BorderSide(color: borderColor ?? Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusLg),
              borderSide: BorderSide(
                  color: focusedBorderColor ?? AyurezeTheme.healingGreen50,
                  width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
