import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/features/authentication/SignIn.dart';
import 'package:doctro/features/dashboard/login_home.dart';
import 'package:doctro/features/startup_gate.dart';
import 'package:doctro/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression tests for the removed opening screen.
///
/// The app used to open on a `SplashScreen` that showed the brand logo and then
/// waited on a 3s `Timer` before choosing between sign-in and the dashboard.
/// That choice now happens synchronously in `StartupGate`, so the first frame
/// the user sees is already the real screen.
///
/// `StartupGate` is booted directly rather than through `MyApp`, because `MyApp`
/// initializes Firebase, notifications and the chat providers, which need live
/// platform channels. The gate only reads one stored flag, so it can be
/// exercised on its own.
///
/// `LanguageLocalization.delegate` is deliberately omitted: it resolves
/// asynchronously, and with it the widget tree builds no child in every
/// `testWidgets` after the first. The gate does not depend on translations.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> boot(WidgetTester tester, {required bool loggedIn}) async {
    // Keyed off the constant, not a literal: the stored name is "isLoggedIn",
    // and a hand-written literal here silently reads back as false.
    SharedPreferences.setMockInitialValues({
      Preferences.is_logged_in: loggedIn,
      'current_language_code': 'en',
      Preferences.name: 'Test Doctor',
    });
    await SharedPreferenceHelper.initWithPreferences(
        await SharedPreferences.getInstance());

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const MaterialApp(home: StartupGate()),
    ));
  }

  group('StartupGate', () {
    testWidgets('signed out shows sign-in on the very first frame',
        (tester) async {
      await boot(tester, loggedIn: false);

      // Checked before pumpAndSettle: no frame may pass on a loading or
      // placeholder screen. A reintroduced Timer would fail this.
      expect(find.byType(SignIn), findsOneWidget);
      expect(find.byType(LoginHomeScreen), findsNothing);

      // Drains the settings request SignInViewModel issues on construction.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a stored session shows the dashboard on the very first frame',
        (tester) async {
      await boot(tester, loggedIn: true);

      expect(find.byType(LoginHomeScreen), findsOneWidget);
      expect(find.byType(SignIn), findsNothing);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the destination does not change once time passes',
        (tester) async {
      await boot(tester, loggedIn: false);
      await tester.pumpAndSettle();

      // The old splash navigated away after 3 seconds. Waiting here must not
      // move the tree anywhere.
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(SignIn), findsOneWidget);
      expect(find.byType(LoginHomeScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
