import 'package:flutter/material.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/features/authentication/SignIn.dart';
import 'package:doctro/features/dashboard/login_home.dart';

/// Picks the first screen the app shows: the dashboard when a session is
/// already stored, sign-in otherwise.
///
/// `SharedPreferences` is initialized in `main()` before `runApp`, so the
/// session flag can be read synchronously here. That is what lets the app open
/// straight onto the right screen with no intermediate screen and no wait.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  /// Resolved once, in `initState`. A later rebuild of the gate (a locale
  /// change, for instance) must not move a signed-in user to sign-in, or the
  /// reverse.
  late final bool _isLoggedIn = _readSession();

  bool _readSession() {
    try {
      return SharedPreferenceHelper.getBoolean(Preferences.is_logged_in);
    } catch (e) {
      // Storage initialization is the only thing that can fail here. Fall back
      // to sign-in: the dashboard needs a token before it can load anything,
      // so an unrecognized session is not usable anyway.
      debugPrint('StartupGate: could not read the session flag: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const LoginHomeScreen(chat: '');
    }
    return const SignIn();
  }
}
