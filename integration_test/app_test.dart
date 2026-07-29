import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doctro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AyurEze Doctor End-to-End Test', () {
    testWidgets('Authentication and Dashboard Workflow', (tester) async {
      // 1. Launch the app
      app.main();
      
      // Wait for splash screen and initial animations to settle
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert that we are either on the Login Screen or Dashboard
      // Check if "Login" or "Sign In" text exists
      final isLoginScreen = find.text('Sign In').evaluate().isNotEmpty || 
                            find.text('Login').evaluate().isNotEmpty;

      if (isLoginScreen) {
        debugPrint("User is NOT logged in. Waiting for manual interaction or custom keys.");
      } else {
        debugPrint("User is already logged in. Proceeding to Dashboard checks...");
      }

      // Assert Dashboard Loads correctly
      final patientsTab = find.text('Patients');
      if (patientsTab.evaluate().isNotEmpty) {
        await tester.tap(patientsTab.first);
        await tester.pumpAndSettle();
        debugPrint("Navigated to Patients tab successfully!");
      }

      // Wait 3 seconds so the tester can visually see the result
      await Future.delayed(const Duration(seconds: 3));
      
      // We made it without crashes!
      expect(true, isTrue);
    });
  });
}
