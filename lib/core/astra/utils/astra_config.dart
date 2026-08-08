import 'package:flutter/foundation.dart';

/// Astra AI Configuration
///
/// Centralized configuration for all Astra AI operations.
/// This class provides constants, endpoints, and configuration options
/// that can be adjusted based on environment.
class AstraConfig {
  AstraConfig._();

  // ============================================================
  // BASE CONFIGURATION
  // ============================================================

  /// Astra Brain Backend Base URL
  static const String baseUrl = 'https://astra.ayureze.in/';

  /// API Version prefix
  static const String apiVersion = 'api/v1';

  /// Full API Base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion/';

  // ============================================================
  // ENDPOINTS
  // ============================================================

  /// Authentication endpoints
  static const String authLogin = 'auth/login';
  static const String authSession = 'auth/session';
  static const String authUserInfo = 'auth/user';
  static const String authLogout = 'auth/logout';

  /// Brain/AI endpoints
  static const String brainChat = 'brain/chat';
  static const String brainHealth = 'brain/health';
  static const String brainDoctorSummary = 'brain/doctor-summary';
  static const String brainAnalyzeSafety = 'brain/analyze-safety';
  static const String brainExtractSchedule = 'brain/extract-schedule';
  static const String brainProfileAnalysis = 'brain/profile-analysis';
  static const String brainGenerateWellness = 'brain/generate-wellness';

  /// Prescription endpoints
  static const String prescriptionCreate = 'api/prescriptions/create';
  static const String prescriptionGet = 'api/prescriptions/{id}';
  static const String prescriptionPatient = 'api/prescriptions/patient/{patient_id}';
  static const String prescriptionWorkflow = 'prescription-workflow/execute';

  /// Astra Fill (Voice/Text Processing)
  static const String astraFillProcessVoice = 'astra-fill/process-voice';
  static const String astraFillProcessText = 'astra-fill/process-text';
  static const String astraFillConfirm = 'astra-fill/confirm';

  /// Shopify/Auto-Cart
  static const String shopifyAiAssist = 'shopify/ai-shop-assist';
  static const String shopifyDraftOrder = 'shopify/draft-order';
  static const String shopifyProductsSearch = 'shopify/products/search/{query}';

  /// Patient endpoints
  static const String patientSearch = 'patients/search/{term}';
  static const String patientProfile = 'patients/profile/{id}';
  static const String patientRegister = 'patients/register';

  /// Documents
  static const String documentUpload = 'documents/upload';
  static const String documentPatient = 'documents/patient/{patient_id}';

  /// Orders
  static const String orderPrescriptionSave = 'orders/prescription/save';
  static const String orderPatient = 'orders/patient/{patient_id}';

  /// Reminders
  static const String reminderCreate = 'medicine-reminders/create-from-prescription';

  /// Notifications
  static const String notificationStoreFcm = 'notifications/store-fcm-token';

  /// Health checks
  static const String health = 'health';
  static const String healthReady = 'health/ready';

  // ============================================================
  // TIMEOUT CONFIGURATION
  // ============================================================

  /// Connection timeout in seconds
  static const int connectTimeoutSeconds = 45;

  /// Receive timeout in seconds
  static const int receiveTimeoutSeconds = 90;

  /// Stream timeout in seconds
  static const int streamTimeoutSeconds = 120;

  /// Retry count for failed requests
  static const int maxRetries = 3;

  /// Retry delay in milliseconds
  static const int retryDelayMs = 1000;

  // ============================================================
  // TRUSTED HOSTS (for SSL bypass in development)
  // ============================================================

  /// List of trusted hosts where SSL certificate validation is bypassed
  /// WARNING: Only for development/testing. Never use in production.
  static const List<String> trustedHosts = [
    'astra.ayureze.in',
    '82.25.105.156',
  ];

  /// Check if a host is trusted for SSL bypass
  static bool isTrustedHost(String host) {
    return trustedHosts.any((trusted) => host.contains(trusted));
  }

  // ============================================================
  // ROLE & AUTHENTICATION
  // ============================================================

  /// Doctor role identifier
  static const String roleDoctor = 'doctor';

  /// Patient role identifier
  static const String rolePatient = 'patient';

  /// Header name for role specification
  static const String roleHeader = 'X-Role';

  /// Header name for authorization
  static const String authHeader = 'Authorization';

  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer ';

  // ============================================================
  // DEEP LINK SCHEME
  // ============================================================

  /// Deep link scheme
  static const String deepLinkScheme = 'ayureze';

  /// Deep link host
  static const String deepLinkHost = 'ayureze.in';

  /// Full deep link URI scheme
  static String get deepLinkUri => '$deepLinkScheme://';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  /// Hive box name for offline cache
  static const String offlineBoxName = 'astra_offline_cache';

  /// Hive box name for conversation history
  static const String conversationBoxName = 'astra_conversations';

  /// SharedPreferences key for session ID
  static const String sessionIdKey = 'astra_session_id';

  /// SharedPreferences key for last health check
  static const String lastHealthCheckKey = 'astra_last_health_check';

  // ============================================================
  // FEATURE FLAGS
  // ============================================================

  /// Enable streaming for chat responses
  static const bool enableStreaming = true;

  /// Enable offline queue
  static const bool enableOfflineQueue = true;

  /// Enable caching
  static const bool enableCaching = true;

  /// Enable logging
  static const bool enableLogging = kDebugMode;

  /// Enable DNS fallback for connection issues
  static const bool enableDnsFallback = true;

  /// Enable IPv4 fallback for connection issues
  static const bool enableIpv4Fallback = true;

  // ============================================================
  // MESSAGE LIMITS
  // ============================================================

  /// Maximum message length
  static const int maxMessageLength = 4000;

  /// Maximum conversation history to store locally
  static const int maxLocalHistoryMessages = 100;

  /// Maximum offline queue size
  static const int maxOfflineQueueSize = 50;

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Build full URL for an endpoint
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    if (endpoint.startsWith('/')) {
      return '$baseUrl${endpoint.substring(1)}';
    }
    return '$apiBaseUrl$endpoint';
  }

  /// Build URL with path parameters
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    String url = endpoint;
    params.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return buildUrl(url);
  }

  /// Get debug label for environment
  static String get environmentLabel {
    if (kDebugMode) return 'DEBUG';
    if (kProfileMode) return 'PROFILE';
    return 'RELEASE';
  }
}
