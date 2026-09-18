import 'package:doctro/core/utils/safe_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('safeInt', () {
    test('parses numeric strings', () {
      expect(safeInt('42'), 42);
      expect(safeInt('0'), 0);
      expect(safeInt('-7'), -7);
      expect(safeInt('  12  '), 12);
    });

    test('passes ints and nums through', () {
      expect(safeInt(42), 42);
      expect(safeInt(3.9), 3);
    });

    test('falls back for null and empty', () {
      expect(safeInt(null), 0);
      expect(safeInt(''), 0);
    });

    test('falls back for non-numeric input instead of throwing', () {
      // The video-call history screen parses a server-supplied duration in a
      // builder. A clock-style value used to throw during build and take the
      // whole screen down.
      expect(safeInt('1:30'), 0);
      expect(safeInt('abc'), 0);
      expect(safeInt('12s'), 0);
    });

    test('honours a custom fallback', () {
      expect(safeInt(null, fallback: 99), 99);
      expect(safeInt('nope', fallback: -1), -1);
    });
  });

  group('safeIntOrNull', () {
    test('returns the value when parseable', () {
      expect(safeIntOrNull('1700000000000'), 1700000000000);
      expect(safeIntOrNull(123), 123);
    });

    test('returns null rather than a zero default', () {
      // Chat timestamps must distinguish "no timestamp" from epoch 0, or the
      // UI renders 01 Jan 1970 for an unparseable message.
      expect(safeIntOrNull(null), isNull);
      expect(safeIntOrNull('not-a-timestamp'), isNull);
      expect(safeIntOrNull(''), isNull);
    });

    test('accepts a Firestore-style numeric Timestamp payload', () {
      // A message written by another client can send a num rather than the
      // millisecond string this app writes.
      expect(safeIntOrNull(1700000000000.0), 1700000000000);
    });
  });
}
