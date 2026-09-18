import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/language_localization.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression tests for the blank screen shown right after login.
///
/// Root cause: `getTranslated` used a null-check operator on the
/// `Localizations` lookup. The delegate resolves asynchronously, so the
/// lookup can legitimately return null; the throw aborted the build of the
/// whole subtree and left an empty screen with only the system bars painted.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'current_language_code': 'en',
      'name': 'Test Doctor',
    });
    // SharedPreferenceHelper caches _preferences; the async getters that
    // LoginHomeViewModel.initializeData uses dereference it directly.
    await SharedPreferenceHelper.initWithPreferences(
        await SharedPreferences.getInstance());
  });

  group('getTranslated', () {
    testWidgets('returns the key instead of throwing when unlocalized',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(Builder(builder: (context) {
        captured = context;
        return const SizedBox.shrink();
      }));

      // No Localizations ancestor exists here, so LanguageLocalization.of
      // returns null. Before the fix this threw a _TypeError.
      expect(() => getTranslated(captured, 'welcome'), returnsNormally);
      expect(getTranslated(captured, 'welcome'), 'welcome');
    });
  });

  group('LanguageLocalization', () {
    test('reading before load() returns the key, not a LateInitializationError',
        () {
      final l = LanguageLocalization(const Locale('en', 'US'));
      expect(() => l.getTranslateValue('welcome'), returnsNormally);
      expect(l.getTranslateValue('welcome'), 'welcome');
    });

    test('loads English translations from the bundled asset', () async {
      final l = LanguageLocalization(const Locale('en', 'US'));
      await l.load();
      expect(l.getTranslateValue('dashboard_welcome'), 'Welcome back,');
    });

    test('every bundled locale parses and is non-empty', () async {
      for (final code in ['en', 'ta', 'hi', 'ml', 'te', 'kn']) {
        final l = LanguageLocalization(Locale(code));
        await l.load();
        expect(l.getTranslateValue('dashboard_welcome'),
            isNot('dashboard_welcome'),
            reason: '$code.json failed to load');
      }
    });

    test('an absent locale asset degrades to keys without throwing', () async {
      final l = LanguageLocalization(const Locale('zz'));
      await expectLater(l.load(), completes);
      expect(l.getTranslateValue('welcome'), 'welcome');
    });
  });
}
