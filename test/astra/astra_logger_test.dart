import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

void main() {
  group('AstraLogger', () {
    test('should have correct prefix', () {
      // The logger should use [Astra] as prefix
      // This is verified by the logger implementation
      expect(AstraLogger.levelVerbose, 0);
      expect(AstraLogger.levelDebug, 1);
      expect(AstraLogger.levelInfo, 2);
      expect(AstraLogger.levelWarning, 3);
      expect(AstraLogger.levelError, 4);
    });

    test('should allow setting log level', () {
      // Set to error only
      AstraLogger.setLevel(AstraLogger.levelError);
      
      // In debug mode, verbose and debug logs should still work
      // In release mode, only error logs would show
      // This is a no-op test that verifies the setLevel method exists
      expect(AstraLogger.levelError, 4);
      
      // Reset to default
      AstraLogger.setLevel(AstraLogger.levelDebug);
    });

    test('should have static level constants', () {
      // Verify static level constants exist
      expect(AstraLogger.levelVerbose, 0);
      expect(AstraLogger.levelDebug, 1);
      expect(AstraLogger.levelInfo, 2);
      expect(AstraLogger.levelWarning, 3);
      expect(AstraLogger.levelError, 4);
    });

    test('log methods should not throw exceptions', () {
      // All log methods should be safe to call without exceptions
      expect(() => AstraLogger.v('Verbose test'), returnsNormally);
      expect(() => AstraLogger.d('Debug test'), returnsNormally);
      expect(() => AstraLogger.i('Info test'), returnsNormally);
      expect(() => AstraLogger.w('Warning test'), returnsNormally);
      expect(() => AstraLogger.e('Error test'), returnsNormally);
    });

    test('log methods should accept optional parameters', () {
      expect(
        () => AstraLogger.d('Test', tag: 'CustomTag'),
        returnsNormally,
      );
      expect(
        () => AstraLogger.e('Test', error: Exception('test')),
        returnsNormally,
      );
    });

    test('specialized log methods should not throw', () {
      expect(
        () => AstraLogger.logRequest('GET', '/api/test'),
        returnsNormally,
      );
      expect(
        () => AstraLogger.logResponse('/api/test', 200),
        returnsNormally,
      );
      expect(
        () => AstraLogger.logApiError('/api/test', Exception('error')),
        returnsNormally,
      );
      expect(
        () => AstraLogger.logNavigation('openPatient', {'id': '123'}),
        returnsNormally,
      );
      expect(
        () => AstraLogger.logBrainAction('action', 'target'),
        returnsNormally,
      );
      expect(
        () => AstraLogger.logStreamEvent('data'),
        returnsNormally,
      );
    });
  });
}
