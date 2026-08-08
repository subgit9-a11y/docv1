import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/astra/utils/astra_config.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';
import 'package:doctro/core/astra/utils/astra_exception.dart';
import 'package:doctro/network/apis.dart';

/// Astra Service
///
/// Enhanced service for communicating with Astra AI Backend.
/// Provides streaming support, retry logic, and comprehensive error handling.
class AstraService {
  static final AstraService _instance = AstraService._internal();
  late Dio _dio;
  
  /// Base URL for Astra API
  final String baseUrl = Apis.astraBaseUrl;

  factory AstraService() => _instance;

  AstraService._internal() {
    _initDio();
  }

  void _initDio() {
    // Ensure baseUrl always ends with a slash
    String sanitizedBaseUrl = baseUrl;
    if (!sanitizedBaseUrl.endsWith('/')) {
      sanitizedBaseUrl += '/';
    }

    _dio = Dio(BaseOptions(
      baseUrl: sanitizedBaseUrl,
      connectTimeout: Duration(seconds: AstraConfig.connectTimeoutSeconds),
      receiveTimeout: Duration(seconds: AstraConfig.receiveTimeoutSeconds),
    ));

    // Configure for mobile network resilience
    _configureForMobileNetworks();

    // Add interceptors for auth and logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }

  void _configureForMobileNetworks() {
    // Configure HTTP client adapter for better mobile connectivity
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      final adapter = _dio.httpClientAdapter as IOHttpClientAdapter;
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.connectionTimeout = Duration(seconds: AstraConfig.connectTimeoutSeconds);
        client.badCertificateCallback = (cert, host, port) {
          return AstraConfig.isTrustedHost(host);
        };
        return client;
      };
    }
  }

  // ============================================================
  // REQUEST INTERCEPTOR
  // ============================================================

  Future<void> _onRequest(
    Options options,
    RequestInterceptorHandler handler,
  ) async {
    final startTime = DateTime.now();

    // Add Firebase Auth token if available
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await user.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Fallback to app auth token
    if (options.headers['Authorization'] == null) {
      final String appToken =
          SharedPreferenceHelper.getString(Preferences.auth_token);
      if (appToken.isNotEmpty && appToken != 'N_A') {
        options.headers['Authorization'] = 'Bearer $appToken';
      }
    }

    // Set default content type
    if (options.headers['Content-Type'] == null) {
      options.headers['Content-Type'] = 'application/json';
    }

    // Add role header
    options.headers['X-Role'] = AstraConfig.roleDoctor;

    // Log request
    AstraLogger.logRequest(
      options.method,
      '${options.baseUrl}${options.path}',
      headers: options.headers,
    );

    // Store start time for duration calculation
    options.extra['_startTime'] = startTime;

    return handler.next(options);
  }

  // ============================================================
  // RESPONSE INTERCEPTOR
  // ============================================================

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['_startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    AstraLogger.logResponse(
      '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      response.statusCode ?? 0,
      duration: duration,
    );

    return handler.next(response);
  }

  // ============================================================
  // ERROR INTERCEPTOR
  // ============================================================

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final startTime = error.requestOptions.extra['_startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime)
        : null;

    AstraLogger.logApiError(
      '${error.requestOptions.baseUrl}${error.requestOptions.path}',
      error,
      statusCode: error.response?.statusCode,
    );

    // Try DNS/IPv4 fallback for connection errors
    if (_isConnectionLevelError(error) && AstraConfig.enableDnsFallback) {
      try {
        final fallbackResponse = await _tryFallback(error.requestOptions);
        if (fallbackResponse != null) {
          return handler.resolve(fallbackResponse);
        }
      } catch (e) {
        // Fallback failed, continue with original error
      }
    }

    return handler.next(error);
  }

  bool _isConnectionLevelError(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    final String text = (error.message ?? '').toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('timed out');
  }

  Future<Response<dynamic>?> _tryFallback(RequestOptions options) async {
    if (!AstraConfig.enableIpv4Fallback) return null;

    try {
      final Uri uri = Uri.parse('${options.baseUrl}${options.path}');
      final String host = uri.host;
      
      final addresses = await InternetAddress.lookup(
        host,
        type: InternetAddressType.IPv4,
      );
      
      if (addresses.isEmpty) return null;

      final String ipBaseUrl = '${uri.scheme}://${addresses.first.address}';
      
      final fallbackDio = Dio(BaseOptions(
        baseUrl: ipBaseUrl,
        connectTimeout: Duration(seconds: AstraConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AstraConfig.receiveTimeoutSeconds),
        headers: {'Host': host},
      ));

      // Copy over the auth headers
      if (options.headers['Authorization'] != null) {
        fallbackDio.options.headers['Authorization'] = options.headers['Authorization'];
      }
      fallbackDio.options.headers['X-Role'] = AstraConfig.roleDoctor;
      fallbackDio.options.headers['Content-Type'] = 'application/json';

      // Configure for SSL bypass
      if (fallbackDio.httpClientAdapter is IOHttpClientAdapter) {
        final adapter = fallbackDio.httpClientAdapter as IOHttpClientAdapter;
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.connectionTimeout = Duration(seconds: AstraConfig.connectTimeoutSeconds);
          client.badCertificateCallback = (_, __, ___) => true;
          return client;
        };
      }

      final response = await fallbackDio.request(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: Options(
          method: options.method,
          headers: options.headers,
        ),
      );

      return response;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CHAT METHODS
  // ============================================================

  /// Chat with Astra Brain
  Future<Map<String, dynamic>> chat(Map<String, dynamic> data) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.brainChat,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Stream chat with Astra Brain
  Stream<ChatStreamEvent> streamChat(Map<String, dynamic> data) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        AstraConfig.brainChat,
        data: data,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      final stream = response.data!.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        
        // Process complete events
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          // Try to parse as JSON
          try {
            final json = jsonDecode(line);
            yield ChatStreamEvent.data(json as Map<String, dynamic>);
          } catch (e) {
            // Not JSON, might be progress text
            if (line.startsWith('data:')) {
              final data = line.substring(5).trim();
              if (data.isNotEmpty) {
                yield ChatStreamEvent.data({'text': data});
              }
            }
          }
        }
      }
      
      yield ChatStreamEvent.done();
    } on DioException catch (e) {
      yield ChatStreamEvent.error(_formatError(e));
    } catch (e, st) {
      yield ChatStreamEvent.error(e.toString());
      AstraLogger.e('Stream chat error', error: e, stackTrace: st);
    }
  }

  // ============================================================
  // PRESCRIPTION METHODS
  // ============================================================

  /// Create a prescription
  Future<Map<String, dynamic>> createPrescription(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.prescriptionCreate,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get prescription by ID
  Future<Map<String, dynamic>> getPrescription(String prescriptionId) async {
    try {
      final url = AstraConfig.prescriptionGet.replaceAll('{id}', prescriptionId);
      final response = await _getWithRetry(url);
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get prescriptions for a patient
  Future<List<dynamic>> getPatientPrescriptions(String patientId) async {
    try {
      final url = AstraConfig.prescriptionPatient.replaceAll(
        '{patient_id}',
        patientId,
      );
      final response = await _getWithRetry(url);
      final data = _parseResponse(response);
      return data is List ? data : [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Execute prescription workflow
  Future<Map<String, dynamic>> executeWorkflow(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.prescriptionWorkflow,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // PATIENT METHODS
  // ============================================================

  /// Search patients
  Future<List<dynamic>> searchPatients(String searchTerm) async {
    try {
      final url = AstraConfig.patientSearch.replaceAll('{term}', searchTerm);
      final response = await _getWithRetry(url);
      final data = _parseResponse(response);
      return data is List ? data : [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient profile
  Future<Map<String, dynamic>> getPatientProfile(String patientId) async {
    try {
      final url = AstraConfig.patientProfile.replaceAll('{id}', patientId);
      final response = await _getWithRetry(url);
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // ASTRA FILL METHODS
  // ============================================================

  /// Process voice input
  Future<Map<String, dynamic>> processVoice(
    File audioFile,
    String userId, {
    String languageCode = 'en-IN',
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'user_id': userId,
        'language_code': languageCode,
      });

      final response = await _dio.post(
        AstraConfig.astraFillProcessVoice,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: Duration(seconds: AstraConfig.streamTimeoutSeconds),
          receiveTimeout: Duration(seconds: AstraConfig.streamTimeoutSeconds),
        ),
      );

      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Process text input
  Future<Map<String, dynamic>> processText(Map<String, dynamic> data) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.astraFillProcessText,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get latest Astra Fill for patient
  Future<Map<String, dynamic>> getLatestAstraFill(String patientId) async {
    try {
      final response = await _getWithRetry(
        'astra-fill/patient/$patientId/latest',
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // MEDICINE/HEALTH METHODS
  // ============================================================

  /// Analyze medication safety
  Future<Map<String, dynamic>> analyzeSafety(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.brainAnalyzeSafety,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Extract medication schedule from text
  Future<Map<String, dynamic>> extractSchedule(String text) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.brainExtractSchedule,
        data: {'text': text},
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate doctor summary
  Future<Map<String, dynamic>> generateDoctorSummary(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _postWithRetry(
        AstraConfig.brainDoctorSummary,
        data: data,
      );
      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================================
  // HEALTH CHECK METHODS
  // ============================================================

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(AstraConfig.health);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check if API is ready
  Future<bool> checkReady() async {
    try {
      final response = await _dio.get(AstraConfig.healthReady);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check Brain health
  Future<Map<String, dynamic>> checkBrainHealth() async {
    try {
      final response = await _getWithRetry(AstraConfig.brainHealth);
      return _parseResponse(response);
    } catch (e) {
      return {'status': 'offline', 'error': e.toString()};
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  Future<Response<dynamic>> _postWithRetry(
    String path, {
    dynamic data,
    int retryCount = 0,
  }) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      if (retryCount < AstraConfig.maxRetries && _isRetryableError(e)) {
        await Future.delayed(
          Duration(milliseconds: AstraConfig.retryDelayMs * (retryCount + 1)),
        );
        return _postWithRetry(path, data: data, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> _getWithRetry(
    String path, {
    int retryCount = 0,
  }) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      if (retryCount < AstraConfig.maxRetries && _isRetryableError(e)) {
        await Future.delayed(
          Duration(milliseconds: AstraConfig.retryDelayMs * (retryCount + 1)),
        );
        return _getWithRetry(path, retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  bool _isRetryableError(DioException error) {
    // Retry on connection errors and 5xx server errors
    if (_isConnectionLevelError(error)) return true;
    if (error.response?.statusCode != null &&
        error.response!.statusCode! >= 500) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> _parseResponse(dynamic response) {
    if (response == null) return {};
    if (response is Map<String, dynamic>) return response;
    if (response is Response && response.data is Map<String, dynamic>) {
      return response.data;
    }
    return {};
  }

  AstraException _handleError(dynamic error) {
    if (error is DioException) {
      String message = 'Network error occurred';

      if (error.response != null) {
        final data = error.response?.data;
        
        // Try to extract error message from response
        if (data is Map && data.containsKey('detail')) {
          message = data['detail'].toString();
        } else if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        } else if (error.response?.statusCode == 401) {
          message = 'Unauthorized. Please login again.';
          return AstraAuthException.sessionExpired();
        } else if (error.response?.statusCode == 403) {
          message = 'Access forbidden.';
        } else if (error.response?.statusCode == 404) {
          message = 'Resource not found.';
        } else if (error.response?.statusCode == 422) {
          message = 'Validation error. Please check input.';
        } else if (error.response?.statusCode == 500) {
          message = 'Server error. Please try again later.';
        }
      } else if (error.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Please check your internet.';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        message = 'Request timeout. Please try again.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'Unable to reach Astra server. Check internet/VPN.';
      }

      return AstraApiException(
        message,
        statusCode: error.response?.statusCode,
        originalError: error,
      );
    }

    if (error is AstraException) {
      return error;
    }

    return AstraException(
      error.toString(),
      originalError: error,
    );
  }

  String _formatError(DioException error) {
    if (error.response?.data is Map) {
      final detail = error.response?.data['detail'];
      if (detail != null) return detail.toString();
    }
    return error.message ?? 'Unknown error';
  }
}

// ============================================================
// STREAM EVENT CLASS
// ============================================================

/// Event types for chat streaming
class ChatStreamEvent {
  final ChatStreamEventType type;
  final dynamic data;
  final String? error;

  ChatStreamEvent._({
    required this.type,
    this.data,
    this.error,
  });

  factory ChatStreamEvent.data(Map<String, dynamic> json) {
    return ChatStreamEvent._(type: ChatStreamEventType.data, data: json);
  }

  factory ChatStreamEvent.done() {
    return ChatStreamEvent._(type: ChatStreamEventType.done);
  }

  factory ChatStreamEvent.error(String message) {
    return ChatStreamEvent._(type: ChatStreamEventType.error, error: message);
  }

  factory ChatStreamEvent.progress(double progress) {
    return ChatStreamEvent._(
      type: ChatStreamEventType.progress,
      data: progress,
    );
  }
}

enum ChatStreamEventType {
  data,
  progress,
  done,
  error,
}
