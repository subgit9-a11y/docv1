import 'dart:async';

/// Astra Performance Cache
///
/// Provides caching, debouncing, and memory management for Astra AI integration.
class AstraCache {
  AstraCache._();
  static final AstraCache instance = AstraCache._();

  // LRU Cache for AI responses
  final _responseCache = _LRUCache<String, CachedResponse>(maxSize: 100);
  
  // Message debouncing
  Timer? _debounceTimer;
  final Map<String, Completer<void>> _pendingMessages = {};

  // Memory management
  int _maxCacheAgeMinutes = 30;
  DateTime? _lastCleanup;

  // ============================================================
  // CACHE METHODS
  // ============================================================

  /// Get cached response if available and not expired
  CachedResponse? get(String key) {
    final cached = _responseCache.get(key);
    if (cached == null) return null;
    
    if (DateTime.now().difference(cached.timestamp) > 
        Duration(minutes: _maxCacheAgeMinutes)) {
      _responseCache.remove(key);
      return null;
    }
    
    return cached;
  }

  /// Cache a response with optional TTL
  void set(String key, dynamic response, {int? ttlMinutes}) {
    _responseCache.set(key, CachedResponse(
      data: response,
      timestamp: DateTime.now(),
      ttlMinutes: ttlMinutes,
    ));
    
    // Cleanup if needed
    _maybeCleanup();
  }

  /// Invalidate specific cache entry
  void invalidate(String key) {
    _responseCache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _responseCache.clear();
  }

  /// Check if key exists in cache
  bool has(String key) => get(key) != null;

  // ============================================================
  // DEBOUNCING
  // ============================================================

  /// Debounce rapid message sends
  Future<void> debounceMessage(String messageId, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    if (_pendingMessages.containsKey(messageId)) {
      return _pendingMessages[messageId]!.future;
    }

    final completer = Completer<void>();
    _pendingMessages[messageId] = completer;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      _pendingMessages.remove(messageId);
      completer.complete();
    });

    return completer.future;
  }

  /// Cancel debounce for specific message
  void cancelDebounce(String messageId) {
    _pendingMessages.remove(messageId);
  }

  /// Cancel all pending debounces
  void cancelAllDebounces() {
    _debounceTimer?.cancel();
    for (final completer in _pendingMessages.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _pendingMessages.clear();
  }

  // ============================================================
  // MEMORY MANAGEMENT
  // ============================================================

  void _maybeCleanup() {
    final now = DateTime.now();
    if (_lastCleanup != null && 
        now.difference(_lastCleanup!) < const Duration(minutes: 5)) {
      return;
    }
    
    _cleanup();
    _lastCleanup = now;
  }

  void _cleanup() {
    final keysToRemove = <String>[];
    
    for (final entry in _responseCache.entries) {
      final cached = entry.value;
      final age = DateTime.now().difference(cached.timestamp);
      final maxAge = Duration(minutes: cached.ttlMinutes ?? _maxCacheAgeMinutes);
      
      if (age > maxAge) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _responseCache.remove(key);
    }
  }

  /// Set max cache age
  void setMaxCacheAge(int minutes) {
    _maxCacheAgeMinutes = minutes;
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'cacheSize': _responseCache.size,
      'maxCacheAge': _maxCacheAgeMinutes,
      'pendingDebounces': _pendingMessages.length,
      'lastCleanup': _lastCleanup?.toIso8601String(),
    };
  }

  /// Dispose and clean up resources
  void dispose() {
    cancelAllDebounces();
    clear();
  }
}

/// Cached response data
class CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  final int? ttlMinutes;

  CachedResponse({
    required this.data,
    required this.timestamp,
    this.ttlMinutes,
  });
}

/// Simple LRU Cache implementation
class _LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _order = [];

  _LRUCache({required this.maxSize});

  int get size => _cache.length;
  Iterable<MapEntry<K, V>> get entries => _cache.entries;

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    _order.remove(key);
    _order.add(key);
    return _cache[key];
  }

  void set(K key, V value) {
    if (_cache.containsKey(key)) {
      _order.remove(key);
    } else if (_order.length >= maxSize) {
      final oldest = _order.removeAt(0);
      _cache.remove(oldest);
    }
    
    _cache[key] = value;
    _order.add(key);
  }

  void remove(K key) {
    _cache.remove(key);
    _order.remove(key);
  }

  void clear() {
    _cache.clear();
    _order.clear();
  }
}

/// Debouncer utility for UI interactions
class AstraDebouncer {
  final Duration delay;
  Timer? _timer;

  AstraDebouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

typedef VoidCallback = void Function();
