import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/language_localization.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:doctro/features/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the profile screen's app bar and Step 1, which were split out of
/// the screen's single 2000+ line build method into their own widgets
/// ([_ProfileHeader] and [_ProfileStep1PersonalInfo]). This is a regression
/// guard for that structural split, and for the `doctorLoader` fix
/// alongside it: `initState` used to assign `doctorLoader` (the
/// FutureBuilder's `future`) and the header's `name` from a `Future.delayed`
/// callback with no `setState` to follow it, so the Stepper body never left
/// its `ConnectionState.none` loading state and the header never picked up
/// the loaded name - both now wrapped in `setState`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'shows the loaded name, then the header and step 1 fields with no '
      'layout exceptions', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'current_language_code': 'en',
      'name': 'Test Doctor',
      'is_filled': 1,
      'image': '',
    });
    await SharedPreferenceHelper.initWithPreferences(
        await SharedPreferences.getInstance());

    await tester.pumpWidget(MaterialApp(
      home: const ProfileScreen(),
      locale: const Locale('en', 'US'),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        LanguageLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ));
    // Not pumpAndSettle: the avatar's CachedNetworkImage placeholder and the
    // Material CircularProgressIndicator it uses animate indefinitely while
    // the (mocked, empty) image URL never resolves in a test environment, so
    // settling never finishes. A few bounded pumps are enough to drain the
    // doctorLoader FutureBuilder's network call instead.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Doctor profile'), findsOneWidget);
    expect(find.text('Profile workspace'), findsOneWidget);
    expect(find.textContaining('Test Doctor'), findsWidgets);
    // The Stepper body: Step 1's own fields, now reachable because
    // doctorLoader's FutureBuilder actually settles.
    expect(find.byType(TextFormField), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
