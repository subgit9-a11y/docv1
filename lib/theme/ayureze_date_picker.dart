import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';

/// Shows the app's date picker with one modern, on-brand look, instead of
/// Flutter's stock Material dialog. Every screen that needs a date picker
/// should call this rather than `showDatePicker` directly - previously three
/// screens each hand-rolled a slightly different `Theme` wrapper (and one
/// built it from a bare `ThemeData.light()`, which meant the dialog fell back
/// to the system font instead of the app's).
Future<DateTime?> showAyurezeDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? accentColor,
}) {
  final accent = accentColor ?? AyurezeTheme.healingGreen100;
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      final base = Theme.of(context);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: accent,
            onPrimary: Colors.white,
            surface: AyurezeTheme.surface,
            onSurface: AyurezeTheme.textPrimary,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AyurezeTheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: AyurezeTheme.borderRadius2xl,
              side: BorderSide(color: AyurezeTheme.border),
            ),
            headerBackgroundColor: accent,
            headerForegroundColor: Colors.white,
            dividerColor: AyurezeTheme.border,
            todayBorder: BorderSide(color: accent, width: 1.2),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              if (states.contains(WidgetState.disabled)) {
                return AyurezeTheme.textSecondary.withValues(alpha: 0.4);
              }
              return AyurezeTheme.textPrimary;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? accent : null;
            }),
            dayOverlayColor: WidgetStatePropertyAll(
              accent.withValues(alpha: 0.08),
            ),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? Colors.white
                  : AyurezeTheme.textPrimary;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? accent : null;
            }),
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: AyurezeTheme.textSecondary,
            ),
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: accent,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ),
        child: child!,
      );
    },
  );
}
