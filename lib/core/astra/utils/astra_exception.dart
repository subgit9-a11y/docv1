/// Astra Exception
///
/// Base exception class for all Astra-related errors.
class AstraException implements Exception {
  /// Error message
  final String message;
  
  /// Error code for programmatic handling
  final String? code;
  
  /// HTTP status code if applicable
  final int? statusCode;
  
  /// Original error/exception
  final dynamic originalError;
  
  /// Stack trace if available
  final StackTrace? stackTrace;

  AstraException(
    this.message, {
    this.code,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AstraException');
    
    if (code != null) {
      buffer.write('[$code]');
    }
    
    if (statusCode != null) {
      buffer.write('[HTTP $statusCode]');
    }
    
    buffer.write(': $message');
    
    return buffer.toString();
  }

  /// Create exception from another error
  factory AstraException.fromError(
    Object error, {
    String? message,
    String? code,
    int? statusCode,
  }) {
    if (error is AstraException) {
      return error;
    }
    
    return AstraException(
      message ?? error.toString(),
      code: code,
      statusCode: statusCode ?? (error is HttpException ? error.statusCode : null),
      originalError: error,
    );
  }
}

/// Network-related exceptions
class AstraNetworkException extends AstraException {
  /// Whether this is a connection-level error (no internet, timeout)
  final bool isConnectionError;

  AstraNetworkException(
    super.message, {
    super.code = 'NETWORK_ERROR',
    super.statusCode,
    this.isConnectionError = false,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'AstraNetworkException: $message (connection: $isConnectionError)';
  }
}

/// Timeout exception
class AstraTimeoutException extends AstraNetworkException {
  final Duration? timeoutDuration;

  AstraTimeoutException(
    super.message, {
    this.timeoutDuration,
    super.code = 'TIMEOUT',
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final durationStr = timeoutDuration != null 
        ? ' after ${timeoutDuration!.inSeconds}s' 
        : '';
    return 'AstraTimeoutException: $message$durationStr';
  }
}

/// HTTP-related exceptions
class AstraHttpException extends AstraException {
  final String? responseBody;

  AstraHttpException(
    super.message, {
    super.code = 'HTTP_ERROR',
    required super.statusCode,
    this.responseBody,
    super.originalError,
    super.stackTrace,
  });

  /// Create 401 Unauthorized exception
  factory AstraHttpException.unauthorized({String? message}) {
    return AstraHttpException(
      message ?? 'Unauthorized. Please login again.',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  /// Create 403 Forbidden exception
  factory AstraHttpException.forbidden({String? message}) {
    return AstraHttpException(
      message ?? 'Access forbidden.',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  /// Create 404 Not Found exception
  factory AstraHttpException.notFound({String? message}) {
    return AstraHttpException(
      message ?? 'Resource not found.',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  /// Create 500 Server Error exception
  factory AstraHttpException.serverError({String? message}) {
    return AstraHttpException(
      message ?? 'Server error. Please try again later.',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }

  @override
  String toString() {
    return 'AstraHttpException[HTTP $statusCode]: $message';
  }
}

/// Authentication exception
class AstraAuthException extends AstraException {
  final bool isSessionExpired;

  AstraAuthException(
    super.message, {
    super.code = 'AUTH_ERROR',
    this.isSessionExpired = false,
    super.originalError,
    super.stackTrace,
  });

  factory AstraAuthException.sessionExpired() {
    return AstraAuthException(
      'Session expired. Please login again.',
      code: 'SESSION_EXPIRED',
      isSessionExpired: true,
    );
  }

  @override
  String toString() {
    return 'AstraAuthException: $message (expired: $isSessionExpired)';
  }
}

/// API exception with structured response
class AstraApiException extends AstraException {
  final Map<String, dynamic>? responseData;
  final List<String>? errors;

  AstraApiException(
    super.message, {
    super.code = 'API_ERROR',
    super.statusCode,
    this.responseData,
    this.errors,
    super.originalError,
    super.stackTrace,
  });

  /// Extract detail from response data
  String? get detail => responseData?['detail']?.toString();

  /// Extract error list from response data
  List<String>? get errorList {
    if (errors != null) return errors;
    if (responseData?['errors'] is List) {
      return List<String>.from(responseData!['errors']);
    }
    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer('AstraApiException');
    
    if (code != null) buffer.write('[$code]');
    if (statusCode != null) buffer.write('[$statusCode]');
    
    buffer.write(': $message');
    
    if (errors != null && errors!.isNotEmpty) {
      buffer.write('\n  Errors: ${errors!.join(', ')}');
    }
    
    return buffer.toString();
  }
}

/// Validation exception
class AstraValidationException extends AstraException {
  final Map<String, List<String>>? fieldErrors;

  AstraValidationException(
    super.message, {
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  /// Get errors for a specific field
  List<String>? getFieldErrors(String field) {
    return fieldErrors?[field];
  }

  @override
  String toString() {
    final buffer = StringBuffer('AstraValidationException: $message');
    
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\n  Field Errors:');
      fieldErrors!.forEach((field, errors) {
        buffer.write('\n    $field: ${errors.join(', ')}');
      });
    }
    
    return buffer.toString();
  }
}

/// Stream exception
class AstraStreamException extends AstraException {
  final bool isReconnectable;
  final int? attemptCount;

  AstraStreamException(
    super.message, {
    super.code = 'STREAM_ERROR',
    this.isReconnectable = true,
    this.attemptCount,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AstraStreamException: $message');
    
    if (attemptCount != null) {
      buffer.write(' (attempt $attemptCount)');
    }
    
    buffer.write(' reconnectable: $isReconnectable');
    
    return buffer.toString();
  }
}

/// Cache exception
class AstraCacheException extends AstraException {
  final bool isOffline;

  AstraCacheException(
    super.message, {
    super.code = 'CACHE_ERROR',
    this.isOffline = false,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'AstraCacheException: $message (offline: $isOffline)';
  }
}

/// Action exception
class AstraActionException extends AstraException {
  final String? actionType;
  final Map<String, dynamic>? actionData;

  AstraActionException(
    super.message, {
    super.code = 'ACTION_ERROR',
    this.actionType,
    this.actionData,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AstraActionException: $message');
    
    if (actionType != null) {
      buffer.write(' (type: $actionType)');
    }
    
    return buffer.toString();
  }
}

/// HTTP Exception helper mixin for extracting status codes
mixin HttpException {
  int? get statusCode;
}
