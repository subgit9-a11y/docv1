import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AyurezeTheme {
  // ── Osler Design System v1.2 — Color Palette ──────────────────────────
  // Osler Gray
  static const Color oslerGray100 = Color(0xFF111A14);
  static const Color oslerGray90 = Color(0xFF1E2721);
  static const Color oslerGray80 = Color(0xFF2F3C33);
  static const Color oslerGray70 = Color(0xFF48524B);
  static const Color oslerGray60 = Color(0xFF647067);
  static const Color oslerGray50 = Color(0xFF849087);
  static const Color oslerGray40 = Color(0xFFA2A9A4);
  static const Color oslerGray30 = Color(0xFFC5C8C6);
  static const Color oslerGray20 = Color(0xFFE3E4E3);
  static const Color oslerGray10 = Color(0xFFF5F5F5);

  // Healing Green (primary brand color)
  static const Color healingGreen100 = Color(0xFF1A2E05);
  static const Color healingGreen90 = Color(0xFF365314);
  static const Color healingGreen80 = Color(0xFF3E6212);
  static const Color healingGreen70 = Color(0xFF4D7C0F);
  static const Color healingGreen60 = Color(0xFF65A30D);
  static const Color healingGreen50 = Color(0xFF84CC16);
  static const Color healingGreen40 = Color(0xFFA3E635);
  static const Color healingGreen30 = Color(0xFFBEF264);
  static const Color healingGreen20 = Color(0xFFD9F99D);
  static const Color healingGreen10 = Color(0xFFECFCCB);

  // Remote Red (destructive / alerts)
  static const Color remoteRed100 = Color(0xFF4C050B);
  static const Color remoteRed90 = Color(0xFF88131F);
  static const Color remoteRed80 = Color(0xFF9F1222);
  static const Color remoteRed70 = Color(0xFFBE1229);
  static const Color remoteRed60 = Color(0xFFE11D3A);
  static const Color remoteRed50 = Color(0xFFF43F5E);
  static const Color remoteRed40 = Color(0xFFFB7185);
  static const Color remoteRed30 = Color(0xFFFDA4B0);
  static const Color remoteRed20 = Color(0xFFFDA4B0);
  static const Color remoteRed10 = Color(0xFFFFE4E7);

  // Sunshine Yellow (warnings / highlights)
  static const Color sunshineYellow100 = Color(0xFF422006);
  static const Color sunshineYellow90 = Color(0xFF713F12);
  static const Color sunshineYellow80 = Color(0xFF854D0E);
  static const Color sunshineYellow70 = Color(0xFFA16207);
  static const Color sunshineYellow60 = Color(0xFFCA8A04);
  static const Color sunshineYellow50 = Color(0xFFEAB308);
  static const Color sunshineYellow40 = Color(0xFFFACC15);
  static const Color sunshineYellow30 = Color(0xFFFDE047);
  static const Color sunshineYellow20 = Color(0xFFFEF08A);
  static const Color sunshineYellow10 = Color(0xFFFEF9C3);

  // Caring Violet (secondary accent — AI / premium features)
  static const Color caringViolet100 = Color(0xFF311065);
  static const Color caringViolet90 = Color(0xFF491D95);
  static const Color caringViolet80 = Color(0xFF5521B6);
  static const Color caringViolet70 = Color(0xFF6328D9);
  static const Color caringViolet60 = Color(0xFF733AED);
  static const Color caringViolet50 = Color(0xFF8B5CF6);
  static const Color caringViolet40 = Color(0xFFAA8BFA);
  static const Color caringViolet30 = Color(0xFFC4B5FD);
  static const Color caringViolet20 = Color(0xFFDDD6FE);
  static const Color caringViolet10 = Color(0xFFEDE9FE);

  // Connectivity Blue (informational accent)
  static const Color connectivityBlue100 = Color(0xFF172554);
  static const Color connectivityBlue90 = Color(0xFF1E3A8A);
  static const Color connectivityBlue80 = Color(0xFF1E40AF);
  static const Color connectivityBlue70 = Color(0xFF1D4ED8);
  static const Color connectivityBlue60 = Color(0xFF3B82F6);
  static const Color connectivityBlue50 = Color(0xFF60A5FA);
  static const Color connectivityBlue40 = Color(0xFF93C5FD);
  static const Color connectivityBlue30 = Color(0xFFBFDBFE);
  static const Color connectivityBlue20 = Color(0xFFDBEAFE);
  static const Color connectivityBlue10 = Color(0xFFEFF6FF);

  // Private state for dynamic theme support
  static bool _isDark = false;
  static void updateThemeMode(bool value) => _isDark = value;

  // Semantic Colors - Light Definitions
  static const Color lightCanvas = oslerGray10;
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceMuted = oslerGray20;
  static const Color lightBorder = oslerGray20;
  static const Color lightTextPrimary = oslerGray100;
  static const Color lightTextSecondary = oslerGray60;

  // Semantic Colors - Dark Definitions
  static const Color darkCanvas = oslerGray100;
  static const Color darkSurface = oslerGray90;
  static const Color darkSurfaceMuted = oslerGray80;
  static const Color darkBorder = oslerGray80;
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = oslerGray40;

  // Dynamic Getters
  static Color get canvas => _isDark ? darkCanvas : lightCanvas;
  static Color get surface => _isDark ? darkSurface : lightSurface;
  static Color get surfaceMuted =>
      _isDark ? darkSurfaceMuted : lightSurfaceMuted;
  static Color get border => _isDark ? darkBorder : lightBorder;
  static Color get textPrimary => _isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary =>
      _isDark ? darkTextSecondary : lightTextSecondary;

  // Aliases for backwards compatibility
  static const Color forestDeep = healingGreen100;
  static const Color forest = healingGreen60;
  static const Color moss = oslerGray50;
  static const Color lightGreen = healingGreen50;
  static const Color lightGreenSoft = healingGreen10;
  static const Color danger = remoteRed50;
  static const Color warning = sunshineYellow50;
  static const Color purple = caringViolet50;

  // Additional semantic getters
  static Color get surfaceDark => darkSurface;
  static Color get textMuted => darkTextSecondary;
  static Color get borderMuted => border;
  static Color get shadow =>
      _isDark ? const Color(0x66000000) : const Color(0x14111A14);

  // Dynamic Icon/SVG Colors - ensures visibility in both modes
  static Color get iconPrimary => _isDark ? Colors.white : healingGreen100;
  static Color get iconSecondary => _isDark ? darkTextSecondary : oslerGray50;
  static Color get iconOnDark => Colors.white;
  static Color get iconOnLight => Colors.white;
  static Color get logoColor => Colors.white;

  // Action button colors for dark/light mode
  static Color get actionButtonPrimary =>
      _isDark ? healingGreen50 : healingGreen60;
  static Color get actionButtonSecondary =>
      _isDark ? oslerGray50 : healingGreen50;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  static ThemeData theme({bool isDarkMode = false}) {
    if (isDarkMode) {
      return darkTheme();
    }
    return lightTheme();
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: healingGreen60,
      brightness: Brightness.light,
      primary: healingGreen60,
      secondary: caringViolet50,
      surface: lightSurface,
    ).copyWith(
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      tertiary: connectivityBlue60,
      error: remoteRed50,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightCanvas,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardColor: lightSurface,
      dividerColor: lightBorder,
      shadowColor: const Color(0x14111A14),
      splashColor: healingGreen10,
      highlightColor: healingGreen10.withOpacity(0.4),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(
          fontSize: 40,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 32,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
        headlineLarge: const TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: lightTextPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.35,
          color: lightTextSecondary,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCanvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: healingGreen60,
          foregroundColor: Colors.white,
          disabledBackgroundColor: oslerGray20,
          disabledForegroundColor: oslerGray50,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: lightSurface,
          foregroundColor: lightTextPrimary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: lightBorder, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: healingGreen70,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: oslerGray10,
        hintStyle: const TextStyle(color: lightTextSecondary),
        labelStyle: const TextStyle(color: lightTextSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: healingGreen60, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: remoteRed50),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: remoteRed50, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: healingGreen10,
        disabledColor: lightSurfaceMuted,
        selectedColor: healingGreen60,
        secondarySelectedColor: healingGreen60,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: healingGreen100,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: healingGreen100,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        brightness: Brightness.light,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: lightTextSecondary,
        indicator: BoxDecoration(
          color: oslerGray100,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: healingGreen60,
        unselectedItemColor: oslerGray50,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: healingGreen10,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? healingGreen80 : oslerGray50,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? healingGreen70 : oslerGray50,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: healingGreen60,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? healingGreen60
              : oslerGray30,
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? healingGreen60
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: oslerGray30, width: 1.6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? healingGreen60
              : oslerGray30,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: healingGreen60,
        linearTrackColor: oslerGray20,
        circularTrackColor: oslerGray20,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: oslerGray100,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: oslerGray100,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static BoxDecoration heroDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [healingGreen50, healingGreen70],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2265A30D),
          blurRadius: 24,
          offset: Offset(0, 16),
        ),
      ],
    );
  }

  static BoxDecoration panelDecoration() {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: shadow,
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration mutedPanelDecoration() {
    return BoxDecoration(
      color: surfaceMuted,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: healingGreen60,
      brightness: Brightness.dark,
      primary: healingGreen50,
      secondary: caringViolet50,
      surface: darkSurface,
    ).copyWith(
      onPrimary: oslerGray100,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      tertiary: connectivityBlue50,
      error: remoteRed50,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkCanvas,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardColor: darkSurface,
      dividerColor: darkBorder,
      shadowColor: const Color(0x40000000),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(
          fontSize: 40,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        displayMedium: const TextStyle(
          fontSize: 32,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        headlineLarge: const TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: darkTextPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.35,
          color: darkTextSecondary,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: healingGreen50,
          foregroundColor: oslerGray100,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: healingGreen50,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: healingGreen50, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: healingGreen40,
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: healingGreen50, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: remoteRed50),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: remoteRed50, width: 1.6),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: darkBorder)),
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: oslerGray100,
        unselectedLabelColor: darkTextSecondary,
        indicator: BoxDecoration(
          color: healingGreen50,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: healingGreen50,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: healingGreen100,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: darkSurface),
      dialogTheme: DialogThemeData(
          backgroundColor: darkSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: healingGreen50,
        foregroundColor: oslerGray100,
        shape: CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? healingGreen50
              : oslerGray70,
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceMuted,
        selectedColor: healingGreen50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
            color: darkTextPrimary, fontWeight: FontWeight.w700),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: healingGreen50,
        linearTrackColor: oslerGray80,
        circularTrackColor: oslerGray80,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: healingGreen10,
        contentTextStyle: const TextStyle(color: oslerGray100),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static BoxDecoration darkPanelDecoration() {
    return BoxDecoration(
      color: darkSurface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: darkBorder),
      boxShadow: const [
        BoxShadow(
          color: Color(0x30000000),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static InputDecoration textFieldDecoration(
      {String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: healingGreen60, width: 1.6),
      ),
      filled: true,
      fillColor: surface,
      labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 14),
    );
  }
}
