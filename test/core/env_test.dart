import 'package:doctro/core/config/env.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// CI runs these tests with --dart-define so that the compile-time branch of
// Env._resolve is actually exercised. Each assertion below is written to hold
// both with and without those defines, rather than assuming one invocation.
const _defineSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _defineSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _defineFirebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');

void main() {
  // flutter_dotenv holds a process-wide store that cannot be cleared, so the
  // "nothing loaded" expectations have to come first. Keep this group ahead of
  // any testLoad call.
  group('Env with no .env store loaded', () {
    test('resolves dart-defines and reports everything else as empty', () {
      expect(Env.supabaseUrl, _defineSupabaseUrl);
      expect(Env.supabaseAnonKey, _defineSupabaseAnonKey);
      expect(Env.firebaseApiKey, _defineFirebaseApiKey);

      // These are never supplied to the test run, so they must be empty. This
      // is the misconfigured-build case the app has to survive.
      expect(Env.astraApiKey, isEmpty);
      expect(Env.sarvamApiKey, isEmpty);
      expect(Env.firebaseServerKey, isEmpty);
    });

    test('getters do not throw when dotenv was never loaded', () {
      // dotenv.load() is debug-only, so release paths reach these getters with
      // no store initialised and must not throw.
      for (final getter in [
        () => Env.supabaseUrl,
        () => Env.supabaseAnonKey,
        () => Env.firebaseApiKey,
        () => Env.astraApiKey,
        () => Env.sarvamApiKey,
        () => Env.firebaseServerKey,
      ]) {
        expect(getter, returnsNormally);
      }
    });

    test('missingKeys reflects exactly which required keys resolved empty', () {
      final missing = Env.missingKeys();
      expect(missing.contains('SUPABASE_URL'), Env.supabaseUrl.isEmpty);
      expect(
          missing.contains('SUPABASE_ANON_KEY'), Env.supabaseAnonKey.isEmpty);
      expect(missing.contains('FIREBASE_API_KEY'), Env.firebaseApiKey.isEmpty);
    });
  });

  group('Env key classification', () {
    test('missingKeys only ever reports required keys', () {
      for (final key in Env.missingKeys()) {
        expect(Env.requiredKeys, contains(key),
            reason: '$key was reported but is not a required key');
      }
    });

    test('server credentials are not required for startup', () {
      // Push and voice may be degraded without them, but the app must still
      // start and reach its backend. Keeping them out of requiredKeys is what
      // stops a server-credential gap being reported as a fatal misconfig.
      expect(Env.requiredKeys, isNot(contains('FIREBASE_SERVER_KEY')));
      expect(Env.requiredKeys, isNot(contains('ASTRA_API_KEY')));
      expect(Env.requiredKeys, isNot(contains('SARVAM_API_KEY')));
    });
  });

  // Must run after the store-free assertions above; see the note at the top.
  group('Env .env fallback', () {
    test('reads from dotenv when no dart-define is present', () {
      dotenv.testLoad(fileInput: """
SUPABASE_URL=https://from-dotenv.example
SUPABASE_ANON_KEY=anon-key-from-dotenv
FIREBASE_API_KEY=api-key-from-dotenv
""");

      // Each key resolves from the define if CI supplied one, and from the
      // store otherwise. Both paths are asserted, so neither can rot.
      expect(
        Env.supabaseUrl,
        _defineSupabaseUrl.isEmpty
            ? 'https://from-dotenv.example'
            : _defineSupabaseUrl,
        reason: 'a compile-time define must take precedence over .env',
      );
      expect(
        Env.supabaseAnonKey,
        _defineSupabaseAnonKey.isEmpty
            ? 'anon-key-from-dotenv'
            : _defineSupabaseAnonKey,
      );
      expect(
        Env.firebaseApiKey,
        _defineFirebaseApiKey.isEmpty
            ? 'api-key-from-dotenv'
            : _defineFirebaseApiKey,
      );
    });

    test('a key absent from both sources stays empty without disturbing others',
        () {
      // Partial configuration must not spill: a missing key reports empty
      // while the keys that did resolve are unaffected.
      expect(Env.supabaseUrl, isNotEmpty);
      expect(Env.sarvamApiKey, isEmpty);
      expect(Env.missingKeys(), isNot(contains('SUPABASE_URL')));
      expect(Env.missingKeys(), isNot(contains('SARVAM_API_KEY')),
          reason: 'SARVAM_API_KEY is not a required key');
    });
  });
}
