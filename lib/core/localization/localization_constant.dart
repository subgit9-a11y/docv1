import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:flutter/material.dart';
import 'language_localization.dart';

String? getTranslated(BuildContext context, String key) {
  return LanguageLocalization.of(context)!.getTranslateValue(key);
}

const String ENGLISH = "en";
const String TAMIL = "ta";
const String HINDI = "hi";
const String MALAYALAM = "ml";
const String TELUGU = "te";
const String KANNADA = "kn";

/// Locales the app declares to Flutter. Must stay in sync with
/// [LanguageLocalization.delegate]'s `isSupported` and the JSON files in
/// `lib/core/localization/language/`.
const List<Locale> supportedLocales = [
  Locale(ENGLISH, 'US'),
  Locale(TAMIL, 'IN'),
  Locale(HINDI, 'IN'),
  Locale(MALAYALAM, 'IN'),
  Locale(TELUGU, 'IN'),
  Locale(KANNADA, 'IN'),
];

Future<Locale> setLocale(String languageCode) async {
  SharedPreferenceHelper.setString(
      Preferences.current_language_code, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale temp;
  switch (languageCode) {
    case ENGLISH:
      temp = Locale(languageCode, 'US');
      break;
    case TAMIL:
      temp = Locale(languageCode, 'IN');
      break;
    case HINDI:
      temp = Locale(languageCode, 'IN');
      break;
    case MALAYALAM:
      temp = Locale(languageCode, 'IN');
      break;
    case TELUGU:
      temp = Locale(languageCode, 'IN');
      break;
    case KANNADA:
      temp = Locale(languageCode, 'IN');
      break;
    default:
      temp = Locale(ENGLISH, 'US');
  }
  return temp;
}

Future<Locale> getLocale() async {
  String languageCode =
      SharedPreferenceHelper.getString(Preferences.current_language_code);
  return _locale(languageCode);
}
