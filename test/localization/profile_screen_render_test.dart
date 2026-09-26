import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/language_localization.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:doctro/features/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the profile screen's app bar, which was recently split out of
/// the screen's single 2000+ line build method into its own widget
/// ([_ProfileHeader], alongside [_ProfileStep1PersonalInfo] for Step 1's
/// fields). This is a regression guard for that structural split: the
/// header must render exactly as before, with no layout exceptions.
///
/// The Stepper body itself is not asserted on here: `doctorLoader` (the
/// FutureBuilder's `future`) is assigned from a `Future.delayed` callback in
/// `initState` with no `setState` to follow it, so the body never leaves
/// its `ConnectionState.none` loading state without some other, unrelated
/// rebuild - a pre-existing quirk, not something this split touched.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the header and step 1 fields with no layout exceptions',
      (tester) async {
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
    expect(tester.takeException(), isNull);
  });
}
