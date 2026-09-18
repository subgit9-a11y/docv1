import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'localization_constant.dart';

/// Translations for the active [locale], loaded from the bundled JSON.
class LanguageLocalization {
  final Locale locale;

  LanguageLocalization(this.locale);

  static LanguageLocalization? of(BuildContext context) {
    return Localizations.of<LanguageLocalization>(
        context, LanguageLocalization);
  }

  /// Initialized empty rather than `late`: a widget that reads a translation
  /// before [load] assigns the field would otherwise throw
  /// [LateInitializationError], which aborts the build of that whole subtree.
  Map<String, String> _localizationValue = const {};

  Future load() async {
    try {
      final jsonStringValue = await rootBundle.loadString(
          'lib/core/localization/language/${locale.languageCode}.json');
      final decoded = json.decode(jsonStringValue);

      if (decoded is! Map) {
        // A list or scalar here means the asset is not a translation map.
        _localizationValue = const {};
        return;
      }

      // Coerce values to String so one non-string entry cannot fail the load
      // and blank every screen that translates through this locale.
      _localizationValue = decoded.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    } catch (e) {
      // Fall back to an empty map if the asset is missing or malformed, so the
      // app still renders (keys pass through as their own translations).
      _localizationValue = const {};
    }
  }

  String? getTranslateValue(String key) {
    return _localizationValue[key] ?? key;
  }

  static const LocalizationsDelegate<LanguageLocalization> delegate =
      _LanguageLocalizationDelegate();
}

class _LanguageLocalizationDelegate
    extends LocalizationsDelegate<LanguageLocalization> {
  const _LanguageLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return [ENGLISH, TAMIL, HINDI, MALAYALAM, TELUGU, KANNADA]
        .contains(locale.languageCode);
  }

  @override
  Future<LanguageLocalization> load(Locale locale) async {
    LanguageLocalization localization = LanguageLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_LanguageLocalizationDelegate old) => false;
}
