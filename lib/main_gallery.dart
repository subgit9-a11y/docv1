// Temporary screenshot gallery for reviewing UX-audit changes on the real
// screens. Not part of the app - boots straight into each screen, skipping
// sign-in/Firebase init, purely to visually review the token migration.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/features/dashboard/login_home.dart';
import 'package:doctro/features/appointments/cancel_appointment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      debugShowCheckedModeBanner: false,
      theme: AyurezeTheme.lightTheme(),
      darkTheme: AyurezeTheme.darkTheme(),
      routes: {
        '/': (context) => const _GalleryHome(),
        'loginHome': (context) => const LoginHomeScreen(chat: ""),
        'cancelAppointment': (context) => const CancelAppointmentScreen(),
      },
    );
  }
}

class _GalleryHome extends StatelessWidget {
  const _GalleryHome();

  @override
  Widget build(BuildContext context) {
    const routes = ['loginHome', 'cancelAppointment'];
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
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
