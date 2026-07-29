import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';

enum OslerButtonStyle { primary, secondary, outline, ghost }

class OslerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OslerButtonStyle style;
  final bool isLoading;
  final IconData? icon;
  final Color? customColor;

  const OslerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = OslerButtonStyle.primary,
    this.isLoading = false,
    this.icon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = customColor ?? _getBackgroundColor();
    return Semantics(
      button: true,
      label: text,
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: _getForegroundColor(bgColor),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: style == OslerButtonStyle.outline
                  ? BorderSide(color: bgColor)
                  : BorderSide.none,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _getForegroundColor(bgColor)))
                : Row(
                    key: const ValueKey('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon),
                        const SizedBox(width: 8)
                      ],
                      Text(text,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (style) {
      case OslerButtonStyle.primary:
        return AyurezeTheme.healingGreen50;
      case OslerButtonStyle.secondary:
        return AyurezeTheme.healingGreen10;
      case OslerButtonStyle.outline:
      case OslerButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(Color bgColor) {
    if (bgColor == AyurezeTheme.healingGreen50 ||
        bgColor == AyurezeTheme.healingGreen100 ||
        bgColor == AyurezeTheme.oslerGray50) {
      return Colors.white;
    }
    return AyurezeTheme.healingGreen100;
  }
}
