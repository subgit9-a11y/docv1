import 'dart:async';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Retry Handler
///
/// Provides automatic retry logic with exponential backoff.
/// Used for API calls that may fail due to transient errors.
class RetryHandler {
  /// Maximum number of retry attempts
  final int maxRetries;
  
  /// Initial delay between retries
  final Duration initialDelay;
  
  /// Maximum delay between retries
  final Duration maxDelay;
  
  /// Multiplier for exponential backoff
  final double backoffMultiplier;
  
  /// Whether to jitter the delay
  final bool useJitter;

  RetryHandler({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
  });

  /// Execute a function with automatic retry
  Future<T> execute<T>(
    Future<T> Function() fn, {
    String? operationName,
    bool Function(Exception)? shouldRetry,
  }) async {
    Exception? lastException;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Check if we should retry
        if (attempt == maxRetries) break;
        
        // Check custom retry condition
        if (shouldRetry != null && !shouldRetry(lastException)) break;
        
        // Calculate delay
        final delay = _calculateDelay(attempt);
        
        AstraLogger.w(
          'Retry attempt ${attempt + 1}/$maxRetries after ${delay.inSeconds}s',
          tag: 'RetryHandler',
          data: {'operation': operationName, 'error': lastException.toString()},
        );
        
        await Future.delayed(delay);
      }
    }
    
    AstraLogger.e(
      'All retries exhausted',
      error: lastException,
      tag: 'RetryHandler',
    );
    
    throw lastException ?? Exception('Unknown error after retries');
  }

  Duration _calculateDelay(int attempt) {
    // Exponential backoff
    final exponentialDelay = Duration(
      milliseconds: (initialDelay.inMilliseconds * 
          (attempt > 0 ? (backoffMultiplier * (attempt - 1)) : 1)).round(),
    );
    
    // Cap at max delay
    var delay = exponentialDelay;
    if (delay > maxDelay) delay = maxDelay;
    
    // Add jitter to prevent thundering herd
    if (useJitter) {
      final jitterMs = (delay.inMilliseconds * 0.2).round();
      final jitter = jitterMs > 0 
          ? Duration(milliseconds: jitterMs)
          : Duration.zero;
      delay += Duration(
        milliseconds: DateTime.now().millisecondsSinceEpoch % (jitter.inMilliseconds * 2) 
            - jitter.inMilliseconds,
      );
    }
    
    return delay;
  }
}

/// Default retry handler instance
final defaultRetryHandler = RetryHandler();

/// Decorator for retry logic
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  String? operationName,
  int maxRetries = 3,
  bool Function(Exception)? shouldRetry,
}) async {
  return defaultRetryHandler.execute(
    fn,
    operationName: operationName,
    shouldRetry: shouldRetry,
  );
}

/// Check if an exception is retryable
bool isRetryableException(Exception e) {
  final message = e.toString().toLowerCase();
  
  // Network errors
  if (message.contains('timeout') || 
      message.contains('network') ||
      message.contains('connection') ||
      message.contains('socket')) {
    return true;
  }
  
  // Server errors (5xx)
  if (message.contains('500') || 
      message.contains('502') || 
      message.contains('503') ||
      message.contains('504')) {
    return true;
  }
  
  // Rate limiting
  if (message.contains('429') || message.contains('rate limit')) {
    return true;
  }
  
  return false;
}

/// Retry configuration
class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final bool useJitter;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.useJitter = true,
  });

  RetryHandler toHandler() => RetryHandler(
    maxRetries: maxRetries,
    initialDelay: initialDelay,
    maxDelay: maxDelay,
    useJitter: useJitter,
  );

  static const network = RetryConfig(
    maxRetries: 3,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 30),
  );

  static const aggressive = RetryConfig(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 15),
  );

  static const conservative = RetryConfig(
    maxRetries: 2,
    initialDelay: Duration(seconds: 3),
    maxDelay: Duration(seconds: 10),
  );
}
