// Temporary screenshot gallery for a dark-mode visual verification pass.
// Not part of the app - boots straight into each screen in dark mode,
// skipping sign-in/Firebase.
import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/features/dashboard/login_home.dart';
import 'package:doctro/features/appointments/cancel_appointment.dart';
import 'package:doctro/features/errors/error_utility_screen.dart';
import 'package:doctro/features/search/search_screen.dart';
import 'package:doctro/features/medications/medication_controller.dart';
import 'package:doctro/features/medications/medication_management_screen.dart';
import 'package:doctro/features/health_records/health_records_screen.dart';
import 'package:doctro/features/health_records/repository/health_records_repository.dart';
import 'package:doctro/features/community/community_controller.dart';
import 'package:doctro/features/community/community_screen.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_controller.dart';
import 'package:doctro/features/onboarding/health_assessment/health_assessment_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AyurezeTheme's dark-aware getters (canvas, surface, textPrimary, ...)
  // are driven by this separate static flag, not by MaterialApp's
  // themeMode/Theme.of(context).brightness - ThemeProvider keeps the two in
  // sync in the real app, so this harness must do the same explicitly.
  AyurezeTheme.updateThemeMode(true);
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      debugShowCheckedModeBanner: false,
      theme: AyurezeTheme.darkTheme(),
      darkTheme: AyurezeTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routes: {
        '/': (context) => const _GalleryHome(),
        'loginHome': (context) => const LoginHomeScreen(chat: ""),
        'cancelAppointment': (context) => const CancelAppointmentScreen(),
        'notFound': (context) =>
            const ErrorUtilityScreen(kind: ErrorUtilityKind.notFound),
        'search': (context) => const SearchScreen(),
        'medications': (context) =>
            MedicationManagementScreen(controller: MedicationController()),
        'healthRecords': (context) =>
            HealthRecordsScreen(repository: InMemoryHealthRecordsRepository()),
        'community': (context) =>
            CommunityScreen(controller: CommunityController()),
        'healthAssessment': (context) => HealthAssessmentScreen(
              controller: HealthAssessmentController(),
              onFinish: () {},
            ),
      },
    );
  }
}

class _GalleryHome extends StatelessWidget {
  const _GalleryHome();

  @override
  Widget build(BuildContext context) {
    const routes = [
      'loginHome',
      'cancelAppointment',
      'notFound',
      'search',
      'medications',
      'healthRecords',
      'community',
      'healthAssessment',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery (dark)')),
      body: ListView(
        children: [
          for (final route in routes)
            ListTile(
              title: Text(route),
              onTap: () => Navigator.of(context).pushNamed(route),
            ),
        ],
      ),
    );
  }
}
