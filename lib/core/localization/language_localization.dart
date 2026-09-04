import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'localization_constant.dart';

class LanguageLocalization {
  final Locale locale;

  LanguageLocalization(this.locale);

  static LanguageLocalization? of(BuildContext context) {
    return Localizations.of<LanguageLocalization>(
        context, LanguageLocalization);
  }

  late Map<String, String> _localizationValue;

  Future load() async {
    try {
      String jsonStringValue = await rootBundle.loadString(
          'lib/core/localization/language/${locale.languageCode.toString()}.json');

      Map<String, dynamic> mappedJson = json.decode(jsonStringValue);

      _localizationValue = mappedJson.map((key, value) => MapEntry(key, value));
    } catch (e) {
      // Fall back to an empty translation map if the asset is missing or
      // malformed, so the app still renders (keys will pass through).
      _localizationValue = {};
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
