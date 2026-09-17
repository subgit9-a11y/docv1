import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central resolution of build-time configuration.
///
/// Two sources are supported, in order of precedence:
///
///  1. Compile-time `--dart-define` values. This is the supported path for CI
///     and release builds, and the only one that reaches a shipped APK.
///  2. A local `.env` file read through flutter_dotenv, for developer machines.
///
/// The `.env` fallback only works if `.env` is declared under `assets:` in
/// pubspec.yaml. It deliberately is not, because that would ship the file
/// inside every APK, where it can be extracted from the bundle. Local
/// development should use `--dart-define-from-file=.env.json` instead, which
/// keeps the values out of the asset table.
///
/// ## What is actually secret
///
/// `--dart-define` embeds values in the compiled binary, and they are
/// recoverable from a release APK. That is acceptable for keys that are public
/// by design (Supabase URL and anon key, Firebase Web API key - all of which
/// already ship to browsers), but not for server credentials. The getters
/// below are grouped accordingly.
class Env {
  Env._();

  // ---------------------------------------------------------------------
  // Public by design - safe to embed in a shipped client.
  // ---------------------------------------------------------------------

  static const String _supabaseUrlDefine =
      String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKeyDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _firebaseApiKeyDefine =
      String.fromEnvironment('FIREBASE_API_KEY');

  /// Supabase project URL. Public.
  static String get supabaseUrl => _resolve('SUPABASE_URL', _supabaseUrlDefine);

  /// Supabase anonymous key. Public by design: it grants only what the
  /// row-level security policies allow.
  static String get supabaseAnonKey =>
      _resolve('SUPABASE_ANON_KEY', _supabaseAnonKeyDefine);

  /// Firebase Web API key. Public by design: it identifies the project rather
  /// than authorising anything on its own.
  static String get firebaseApiKey =>
      _resolve('FIREBASE_API_KEY', _firebaseApiKeyDefine);

  // ---------------------------------------------------------------------
  // Server credentials - should move behind the backend.
  // ---------------------------------------------------------------------

  static const String _astraApiKeyDefine =
      String.fromEnvironment('ASTRA_API_KEY');
  static const String _sarvamApiKeyDefine =
      String.fromEnvironment('SARVAM_API_KEY');
  static const String _firebaseServerKeyDefine =
      String.fromEnvironment('FIREBASE_SERVER_KEY');

  /// Key for server-to-server Astra calls.
  static String get astraApiKey =>
      _resolve('ASTRA_API_KEY', _astraApiKeyDefine);

  /// Sarvam speech API key.
  static String get sarvamApiKey =>
      _resolve('SARVAM_API_KEY', _sarvamApiKeyDefine);

  /// Legacy FCM server key.
  ///
  /// This authorises pushing to *any* device in the Firebase project, so it
  /// must not be trusted to a client: anyone who extracts it from an APK can
  /// push to every user. Resolved here only so existing installs keep working
  /// during migration; sending belongs on the backend.
  static String get firebaseServerKey =>
      _resolve('FIREBASE_SERVER_KEY', _firebaseServerKeyDefine);

  // ---------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------

  /// Keys required for the app to reach its backend. Missing ones are reported
  /// at startup instead of failing silently later.
  static const List<String> requiredKeys = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'FIREBASE_API_KEY',
  ];

  static String _resolve(String key, String defineValue) {
    if (defineValue.isNotEmpty) return defineValue;
    try {
      return dotenv.maybeGet(key) ?? '';
    } catch (_) {
      // dotenv throws when it was never loaded; not an error here.
      return '';
    }
  }

  /// The subset of [requiredKeys] that resolved to an empty value.
  static List<String> missingKeys() {
    final resolved = {
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'FIREBASE_API_KEY': firebaseApiKey,
    };
    return requiredKeys.where((k) => (resolved[k] ?? '').isEmpty).toList();
  }
}
