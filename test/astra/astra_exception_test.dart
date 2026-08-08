import 'package:flutter_test/flutter_test.dart';
import 'package:doctro/core/astra/utils/astra_exception.dart';

void main() {
  group('AstraException', () {
    test('should create with message only', () {
      final ex = AstraException('Test error');

      expect(ex.message, 'Test error');
      expect(ex.code, isNull);
      expect(ex.statusCode, isNull);
    });

    test('should create with all fields', () {
      final ex = AstraException(
        'Test error',
        code: 'TEST_ERROR',
        statusCode: 400,
      );

      expect(ex.message, 'Test error');
      expect(ex.code, 'TEST_ERROR');
      expect(ex.statusCode, 400);
    });

    test('should have readable toString', () {
      final ex = AstraException(
        'Test error',
        code: 'TEST',
        statusCode: 400,
      );

      expect(ex.toString(), contains('Test error'));
      expect(ex.toString(), contains('TEST'));
      expect(ex.toString(), contains('400'));
    });
  });

  group('AstraNetworkException', () {
    test('should create network exception', () {
      final ex = AstraNetworkException('Network error');

      expect(ex.message, 'Network error');
      expect(ex.code, 'NETWORK_ERROR');
      expect(ex.isConnectionError, false);
    });

    test('should mark as connection error', () {
      final ex = AstraNetworkException(
        'Connection failed',
        isConnectionError: true,
      );

      expect(ex.isConnectionError, true);
    });
  });

  group('AstraTimeoutException', () {
    test('should create timeout exception', () {
      final ex = AstraTimeoutException('Request timed out');

      expect(ex.message, 'Request timed out');
      expect(ex.code, 'TIMEOUT');
    });

    test('should include duration in message', () {
      final ex = AstraTimeoutException(
        'Request timed out',
        timeoutDuration: const Duration(seconds: 30),
      );

      expect(ex.timeoutDuration, const Duration(seconds: 30));
      expect(ex.toString(), contains('30s'));
    });
  });

  group('AstraHttpException', () {
    test('should create unauthorized exception', () {
      final ex = AstraHttpException.unauthorized();

      expect(ex.statusCode, 401);
      expect(ex.code, 'UNAUTHORIZED');
      expect(ex.message, contains('Unauthorized'));
    });

    test('should create forbidden exception', () {
      final ex = AstraHttpException.forbidden();

      expect(ex.statusCode, 403);
      expect(ex.code, 'FORBIDDEN');
    });

    test('should create not found exception', () {
      final ex = AstraHttpException.notFound();

      expect(ex.statusCode, 404);
      expect(ex.code, 'NOT_FOUND');
    });

    test('should create server error exception', () {
      final ex = AstraHttpException.serverError();

      expect(ex.statusCode, 500);
      expect(ex.code, 'SERVER_ERROR');
    });

    test('should include response body', () {
      final ex = AstraHttpException(
        'Error',
        statusCode: 400,
        responseBody: '{"error": "bad request"}',
      );

      expect(ex.responseBody, '{"error": "bad request"}');
    });
  });

  group('AstraAuthException', () {
    test('should create auth exception', () {
      final ex = AstraAuthException('Auth failed');

      expect(ex.message, 'Auth failed');
      expect(ex.code, 'AUTH_ERROR');
      expect(ex.isSessionExpired, false);
    });

    test('should create session expired exception', () {
      final ex = AstraAuthException.sessionExpired();

      expect(ex.code, 'SESSION_EXPIRED');
      expect(ex.isSessionExpired, true);
      expect(ex.message, contains('expired'));
    });
  });

  group('AstraApiException', () {
    test('should create API exception', () {
      final ex = AstraApiException('API error', statusCode: 500);

      expect(ex.message, 'API error');
      expect(ex.statusCode, 500);
      expect(ex.code, 'API_ERROR');
    });

    test('should extract detail from response', () {
      final ex = AstraApiException(
        'Error',
        responseData: {'detail': 'Something went wrong'},
      );

      expect(ex.detail, 'Something went wrong');
    });

    test('should extract error list from response', () {
      final ex = AstraApiException(
        'Error',
        responseData: {'errors': ['Error 1', 'Error 2']},
      );

      expect(ex.errorList, ['Error 1', 'Error 2']);
    });

    test('should extract errors from constructor', () {
      final ex = AstraApiException(
        'Error',
        errors: ['Custom error 1'],
      );

      expect(ex.errorList, ['Custom error 1']);
    });
  });

  group('AstraValidationException', () {
    test('should create validation exception', () {
      final ex = AstraValidationException('Validation failed');

      expect(ex.message, 'Validation failed');
      expect(ex.code, 'VALIDATION_ERROR');
    });

    test('should include field errors', () {
      final ex = AstraValidationException(
        'Validation failed',
        fieldErrors: {
          'email': ['Invalid email format'],
          'password': ['Too short', 'Missing number'],
        },
      );

      expect(ex.getFieldErrors('email'), ['Invalid email format']);
      expect(ex.getFieldErrors('password'), ['Too short', 'Missing number']);
      expect(ex.getFieldErrors('unknown'), isNull);
    });
  });

  group('AstraStreamException', () {
    test('should create stream exception', () {
      final ex = AstraStreamException('Stream interrupted');

      expect(ex.message, 'Stream interrupted');
      expect(ex.code, 'STREAM_ERROR');
      expect(ex.isReconnectable, true);
    });

    test('should include attempt count', () {
      final ex = AstraStreamException(
        'Stream failed',
        attemptCount: 3,
      );

      expect(ex.attemptCount, 3);
      expect(ex.toString(), contains('attempt 3'));
    });
  });

  group('AstraCacheException', () {
    test('should create cache exception', () {
      final ex = AstraCacheException('Cache error');

      expect(ex.message, 'Cache error');
      expect(ex.code, 'CACHE_ERROR');
      expect(ex.isOffline, false);
    });

    test('should mark as offline', () {
      final ex = AstraCacheException(
        'Offline mode',
        isOffline: true,
      );

      expect(ex.isOffline, true);
    });
  });

  group('AstraActionException', () {
    test('should create action exception', () {
      final ex = AstraActionException('Action failed');

      expect(ex.message, 'Action failed');
      expect(ex.code, 'ACTION_ERROR');
    });

    test('should include action type and data', () {
      final ex = AstraActionException(
        'Action failed',
        actionType: 'openPatient',
        actionData: {'id': '123'},
      );

      expect(ex.actionType, 'openPatient');
      expect(ex.actionData, {'id': '123'});
    });
  });
}
