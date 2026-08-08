import 'package:flutter/foundation.dart';

/// Astra Logger
///
/// Centralized logging for all Astra AI operations.
/// Uses conditional compilation to only log in debug mode.
class AstraLogger {
  AstraLogger._();

  static const String _prefix = '[Astra]';
  static const String _tag = 'ASTRA';

  // ============================================================
  // LOG LEVELS
  // ============================================================

  /// Log level enumeration
  static const int levelVerbose = 0;
  static const int levelDebug = 1;
  static const int levelInfo = 2;
  static const int levelWarning = 3;
  static const int levelError = 4;

  /// Current log level (can be set at runtime)
  static int _currentLevel = kDebugMode ? levelDebug : levelWarning;

  /// Set the minimum log level
  static void setLevel(int level) {
    _currentLevel = level;
  }

  // ============================================================
  // VERBOSE LOGS
  // ============================================================

  /// Log verbose information (detailed debugging)
  static void v(String message, {String? tag, Object? data}) {
    if (_currentLevel <= levelVerbose) {
      _log('V', tag ?? _tag, message, data: data);
    }
  }

  // ============================================================
  // DEBUG LOGS
  // ============================================================

  /// Log debug information
  static void d(String message, {String? tag, Object? data}) {
    if (_currentLevel <= levelDebug) {
      _log('D', tag ?? _tag, message, data: data);
    }
  }

  // ============================================================
  // INFO LOGS
  // ============================================================

  /// Log general information
  static void i(String message, {String? tag, Object? data}) {
    if (_currentLevel <= levelInfo) {
      _log('I', tag ?? _tag, message, data: data);
    }
  }

  // ============================================================
  // WARNING LOGS
  // ============================================================

  /// Log warning messages
  static void w(String message, {String? tag, Object? data}) {
    if (_currentLevel <= levelWarning) {
      _log('W', tag ?? _tag, message, data: data);
    }
  }

  // ============================================================
  // ERROR LOGS
  // ============================================================

  /// Log error messages
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= levelError) {
      _log('E', tag ?? _tag, message, error: error, stackTrace: stackTrace);
    }
  }

  // ============================================================
  // SPECIALIZED LOGS
  // ============================================================

  /// Log API request
  static void logRequest(String method, String url, {Map<String, dynamic>? headers, Object? body}) {
    if (_currentLevel > levelDebug) return;
    
    final buffer = StringBuffer();
    buffer.writeln('📤 REQUEST: $method $url');
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('   Headers: ${_maskSensitiveData(headers)}');
    }
    
    if (body != null) {
      if (body is Map<String, dynamic>) {
        buffer.writeln('   Body: ${_maskSensitiveData(body)}');
      } else {
        buffer.writeln('   Body: $body');
      }
    }
    
    debugPrint(buffer.toString());
  }

  /// Log API response
  static void logResponse(String url, int statusCode, {Duration? duration, Object? data}) {
    if (_currentLevel > levelDebug) return;
    
    final buffer = StringBuffer();
    buffer.writeln('📥 RESPONSE: $statusCode from $url');
    
    if (duration != null) {
      buffer.writeln('   Duration: ${duration.inMilliseconds}ms');
    }
    
    if (data != null) {
      buffer.writeln('   Data: ${_truncateData(data)}');
    }
    
    debugPrint(buffer.toString());
  }

  /// Log API error
  static void logApiError(String url, Object error, {int? statusCode}) {
    final buffer = StringBuffer();
    buffer.writeln('❌ API ERROR: $url');
    
    if (statusCode != null) {
      buffer.writeln('   Status: $statusCode');
    }
    
    buffer.writeln('   Error: $error');
    
    if (kDebugMode && error is Error) {
      buffer.writeln('   StackTrace: ${error.stackTrace}');
    }
    
    debugPrint(buffer.toString());
  }

  /// Log navigation action
  static void logNavigation(String action, Map<String, dynamic>? params) {
    if (_currentLevel > levelInfo) return;
    
    final buffer = StringBuffer();
    buffer.writeln('🧭 NAVIGATION: $action');
    
    if (params != null && params.isNotEmpty) {
      buffer.writeln('   Params: $params');
    }
    
    debugPrint(buffer.toString());
  }

  /// Log brain action
  static void logBrainAction(String action, String? target, {Map<String, dynamic>? metadata}) {
    if (_currentLevel > levelInfo) return;
    
    final buffer = StringBuffer();
    buffer.writeln('🧠 BRAIN ACTION: $action');
    
    if (target != null) {
      buffer.writeln('   Target: $target');
    }
    
    if (metadata != null && metadata.isNotEmpty) {
      buffer.writeln('   Metadata: $metadata');
    }
    
    debugPrint(buffer.toString());
  }

  /// Log streaming event
  static void logStreamEvent(String event, {Object? data}) {
    if (_currentLevel > levelDebug) return;
    
    final buffer = StringBuffer();
    buffer.writeln('📡 STREAM: $event');
    
    if (data != null) {
      buffer.writeln('   Data: ${_truncateData(data)}');
    }
    
    debugPrint(buffer.toString());
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  static void _log(
    String level,
    String tag,
    String message, {
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final buffer = StringBuffer();
    
    buffer.write('$_prefix[$timestamp] [$level][$tag] $message');
    
    if (data != null) {
      buffer.write('\n   Data: $data');
    }
    
    if (error != null) {
      buffer.write('\n   Error: $error');
    }
    
    if (stackTrace != null && kDebugMode) {
      buffer.write('\n   Stack: ${stackTrace.toString().split('\n').take(3).join('\n   ')}');
    }
    
    debugPrint(buffer.toString());
  }

  static Map<String, dynamic> _maskSensitiveData(Map<String, dynamic> data) {
    const sensitiveKeys = ['password', 'token', 'secret', 'authorization', 'auth', 'key'];
    
    return Map.fromEntries(
      data.entries.map((e) {
        if (sensitiveKeys.any((key) => e.key.toLowerCase().contains(key))) {
          return MapEntry(e.key, '***MASKED***');
        }
        return e;
      }),
    );
  }

  static String _truncateData(Object data, {int maxLength = 500}) {
    String str = data.toString();
    if (str.length > maxLength) {
      return '${str.substring(0, maxLength)}... (truncated)';
    }
    return str;
  }
}
