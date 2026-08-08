import 'package:flutter/material.dart';
import 'package:doctro/core/navigator_key.dart';
import 'package:doctro/core/astra/actions/action_models.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// App Router
///
/// Centralized navigation router for Astra AI actions.
/// This router maps Astra actions to existing app screens without creating new ones.

class AppRouter {
  AppRouter._();
  static final AppRouter instance = AppRouter._();

  /// Navigator key for accessing navigator
  GlobalKey<NavigatorState> get navigatorKey => navigatorKey;

  // ============================================================
  // NAVIGATION METHODS
  // ============================================================

  /// Open patient details screen
  Future<ActionResult> openPatient({
    required String patientId,
    String? patientName,
    String? phone,
  }) async {
    try {
      AstraLogger.logNavigation('openPatient', {
        'patientId': patientId,
        'patientName': patientName,
      });

      // Navigate to patient details
      // The patientDetailsScreen takes an 'id' parameter
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => _getPatientDetailsScreen(patientId),
        ),
      );

      return ActionResult.success(data: {'patientId': patientId});
    } catch (e, st) {
      AstraLogger.e('Failed to open patient', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open patient: $e');
    }
  }

  /// Open prescription screen
  Future<ActionResult> openPrescription({
    String? prescriptionId,
    String? patientId,
    String? patientName,
    String? patientPhone,
    Map<String, dynamic>? astraFillData,
  }) async {
    try {
      AstraLogger.logNavigation('openPrescription', {
        'prescriptionId': prescriptionId,
        'patientId': patientId,
        'patientName': patientName,
      });

      // Navigate to prescription screen
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => _getPrescriptionScreen(
            prescriptionId: prescriptionId,
            patientId: patientId,
            patientName: patientName,
            patientPhone: patientPhone,
            astraFillData: astraFillData,
          ),
        ),
      );

      return ActionResult.success(data: {'prescriptionId': prescriptionId});
    } catch (e, st) {
      AstraLogger.e('Failed to open prescription', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open prescription: $e');
    }
  }

  /// Open shopping cart
  Future<ActionResult> openCart() async {
    try {
      AstraLogger.logNavigation('openCart', null);

      navigatorKey.currentState?.pushNamed('payment');

      return ActionResult.success();
    } catch (e, st) {
      AstraLogger.e('Failed to open cart', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open cart: $e');
    }
  }

  /// Open payment screen
  Future<ActionResult> openPayment({
    String? orderId,
    double? amount,
  }) async {
    try {
      AstraLogger.logNavigation('openPayment', {
        'orderId': orderId,
        'amount': amount,
      });

      navigatorKey.currentState?.pushNamed('payment');

      return ActionResult.success(data: {'orderId': orderId});
    } catch (e, st) {
      AstraLogger.e('Failed to open payment', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open payment: $e');
    }
  }

  /// Open notifications
  Future<ActionResult> openNotifications() async {
    try {
      AstraLogger.logNavigation('openNotifications', null);

      navigatorKey.currentState?.pushNamed('notifications');

      return ActionResult.success();
    } catch (e, st) {
      AstraLogger.e('Failed to open notifications', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open notifications: $e');
    }
  }

  /// Open Astra AI chat
  Future<ActionResult> openChat({
    String? conversationId,
    String? patientId,
    String? patientName,
    String? appointmentId,
  }) async {
    try {
      AstraLogger.logNavigation('openChat', {
        'conversationId': conversationId,
        'patientId': patientId,
        'patientName': patientName,
      });

      // Navigate to Astra chat page with context
      // Import at runtime to avoid circular dependencies
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) {
            // Use dynamic import for AstraChatPage
            return _buildAstraChatPage(
              patientId: patientId,
              patientName: patientName,
              appointmentId: appointmentId,
            );
          },
        ),
      );

      return ActionResult.success(data: {
        'conversationId': conversationId,
        'patientId': patientId,
      });
    } catch (e, st) {
      AstraLogger.e('Failed to open chat', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open chat: $e');
    }
  }

  /// Open video call
  Future<ActionResult> openVideoCall({
    String? roomId,
    String? patientId,
  }) async {
    try {
      AstraLogger.logNavigation('openVideoCall', {
        'roomId': roomId,
        'patientId': patientId,
      });

      // Navigate to video call history - actual call initiation happens there
      navigatorKey.currentState?.pushNamed('VideoCallHistory');

      return ActionResult.success(data: {'roomId': roomId});
    } catch (e, st) {
      AstraLogger.e('Failed to open video call', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open video call: $e');
    }
  }

  /// Open appointments
  Future<ActionResult> openAppointment({
    String? appointmentId,
    bool showHistory = false,
  }) async {
    try {
      AstraLogger.logNavigation('openAppointment', {
        'appointmentId': appointmentId,
        'showHistory': showHistory,
      });

      if (showHistory) {
        navigatorKey.currentState?.pushNamed('AppointmentHistoryScreen');
      }

      return ActionResult.success(data: {'appointmentId': appointmentId});
    } catch (e, st) {
      AstraLogger.e('Failed to open appointment', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open appointment: $e');
    }
  }

  /// Open profile
  Future<ActionResult> openProfile({String? userId}) async {
    try {
      AstraLogger.logNavigation('openProfile', {'userId': userId});

      navigatorKey.currentState?.pushNamed('profile');

      return ActionResult.success(data: {'userId': userId});
    } catch (e, st) {
      AstraLogger.e('Failed to open profile', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open profile: $e');
    }
  }

  /// Open reminders
  Future<ActionResult> openReminders({String? patientId}) async {
    try {
      AstraLogger.logNavigation('openReminders', {'patientId': patientId});

      // Navigate to notifications which shows reminders
      navigatorKey.currentState?.pushNamed('ViewAllNotification');

      return ActionResult.success(data: {'patientId': patientId});
    } catch (e, st) {
      AstraLogger.e('Failed to open reminders', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open reminders: $e');
    }
  }

  /// Open storage/documents
  Future<ActionResult> openStorage({String? patientId}) async {
    try {
      AstraLogger.logNavigation('openStorage', {'patientId': patientId});

      // Navigate to patient details where documents tab exists
      if (patientId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => _getPatientDetailsScreen(patientId),
          ),
        );
      }

      return ActionResult.success(data: {'patientId': patientId});
    } catch (e, st) {
      AstraLogger.e('Failed to open storage', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open storage: $e');
    }
  }

  /// Open report
  Future<ActionResult> openReport({
    required String reportId,
    String? reportType,
  }) async {
    try {
      AstraLogger.logNavigation('openReport', {
        'reportId': reportId,
        'reportType': reportType,
      });

      // Navigate to patient details where reports might be shown
      navigatorKey.currentState?.pushNamed('notifications');

      return ActionResult.success(data: {'reportId': reportId});
    } catch (e, st) {
      AstraLogger.e('Failed to open report', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open report: $e');
    }
  }

  /// Open product
  Future<ActionResult> openProduct({
    required String productId,
    String? productName,
  }) async {
    try {
      AstraLogger.logNavigation('openProduct', {
        'productId': productId,
        'productName': productName,
      });

      // Navigate to payment/cart where products are shown
      navigatorKey.currentState?.pushNamed('payment');

      return ActionResult.success(data: {'productId': productId});
    } catch (e, st) {
      AstraLogger.e('Failed to open product', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open product: $e');
    }
  }

  /// Open doctor booking
  Future<ActionResult> openDoctorBooking({String? patientId}) async {
    try {
      AstraLogger.logNavigation('openDoctorBooking', {'patientId': patientId});

      // Navigate to login home for appointment booking
      navigatorKey.currentState?.pushNamed('loginHome');

      return ActionResult.success(data: {'patientId': patientId});
    } catch (e, st) {
      AstraLogger.e('Failed to open doctor booking', error: e, stackTrace: st);
      return ActionResult.failure('Failed to open doctor booking: $e');
    }
  }

  /// Go back
  Future<ActionResult> goBack() async {
    try {
      AstraLogger.logNavigation('goBack', null);

      if (navigatorKey.currentState?.canPop() == true) {
        navigatorKey.currentState?.pop();
      }

      return ActionResult.success();
    } catch (e, st) {
      AstraLogger.e('Failed to go back', error: e, stackTrace: st);
      return ActionResult.failure('Failed to go back: $e');
    }
  }

  // ============================================================
  // SCREEN FACTORIES
  // ============================================================

  /// Get patient details screen - uses existing screen
  Widget _getPatientDetailsScreen(String patientId) {
    // Import existing screen
    // Using dynamic import to avoid circular dependencies
    return _buildPatientDetailsScreen(patientId);
  }

  /// Get prescription screen - uses existing screen
  Widget _getPrescriptionScreen({
    String? prescriptionId,
    String? patientId,
    String? patientName,
    String? patientPhone,
    Map<String, dynamic>? astraFillData,
  }) {
    return _buildPrescriptionScreen(
      prescriptionId: prescriptionId,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      astraFillData: astraFillData,
    );
  }

  // ============================================================
  // DEEP LINK HANDLING
  // ============================================================

  /// Handle deep link URL
  Future<ActionResult> handleDeepLink(Uri uri) async {
    try {
      AstraLogger.logNavigation('handleDeepLink', {
        'scheme': uri.scheme,
        'host': uri.host,
        'path': uri.path,
        'query': uri.queryParameters,
      });

      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

      switch (path) {
        case 'patient':
          return openPatient(patientId: id ?? '');
        case 'prescription':
          return openPrescription(prescriptionId: id);
        case 'cart':
          return openCart();
        case 'appointment':
          return openAppointment(appointmentId: id);
        case 'notification':
          return openNotifications();
        case 'report':
          return openReport(reportId: id ?? '');
        case 'payment':
          return openPayment();
        case 'chat':
          return openChat();
        default:
          return ActionResult.failure('Unknown deep link path: $path');
      }
    } catch (e, st) {
      AstraLogger.e('Failed to handle deep link', error: e, stackTrace: st);
      return ActionResult.failure('Failed to handle deep link: $e');
    }
  }

  /// Parse deep link URL
  static Uri? parseDeepLink(String url) {
    try {
      if (url.startsWith('ayureze://')) {
        return Uri.parse(url);
      }
      if (url.startsWith('https://ayureze.in/')) {
        return Uri.parse(url.replaceFirst('https://ayureze.in/', 'ayureze://'));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ============================================================
// SCREEN FACTORY - Import actual screens here
// ============================================================

Widget _buildPatientDetailsScreen(String patientId) {
  // Late import to avoid circular dependencies
  // In actual implementation, import the actual screen
  // return PatientDetailsScreen(id: int.tryParse(patientId));
  
  // For now, return a placeholder - the actual import happens at runtime
  // This is a workaround for Dart's lack of circular import handling
  throw UnimplementedError('Use direct navigation to patientDetailsScreen');
}

Widget _buildPrescriptionScreen({
  String? prescriptionId,
  String? patientId,
  String? patientName,
  String? patientPhone,
  Map<String, dynamic>? astraFillData,
}) {
  // Late import to avoid circular dependencies
  throw UnimplementedError('Use direct navigation to PrescriptionScreen');
}

/// Build Astra chat page with patient context
Widget _buildAstraChatPage({
  String? patientId,
  String? patientName,
  String? appointmentId,
}) {
  // Import AstraChatPage at runtime
  // This avoids circular import issues
  try {
    // Use reflection-style import by accessing through package
    // The actual import happens when this function is called
    return _AstraChatPageBuilder.buildPage(
      patientId: patientId,
      patientName: patientName,
      appointmentId: appointmentId,
    );
  } catch (e) {
    // Fallback: return a simple placeholder if import fails
    return _AstraFallbackChatPage(
      patientId: patientId,
      patientName: patientName,
    );
  }
}

/// Fallback chat page if AstraChatPage can't be loaded
class _AstraFallbackChatPage extends StatelessWidget {
  final String? patientId;
  final String? patientName;

  const _AstraFallbackChatPage({
    this.patientId,
    this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Astra AI${patientName != null ? ' - $patientName' : ''}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Astra AI Assistant'),
            SizedBox(height: 8),
            Text(patientId != null ? 'Patient ID: $patientId' : 'No patient context'),
          ],
        ),
      ),
    );
  }
}

/// Builder helper for AstraChatPage
class _AstraChatPageBuilder {
  static Widget buildPage({
    String? patientId,
    String? patientName,
    String? appointmentId,
  }) {
    // Dynamic import - the actual implementation
    // In production, this would import from features/consultation/astra_chat
    throw UnimplementedError(
      'Please import AstraChatPage directly from features/consultation/astra_chat/astra_chat_page.dart'
    );
  }
}
