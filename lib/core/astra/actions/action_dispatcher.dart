import 'package:doctro/core/astra/actions/action_models.dart';
import 'package:doctro/core/astra/navigation/app_router.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Action Dispatcher
///
/// Interprets Astra AI actions and executes corresponding navigation or operations.
class ActionDispatcher {
  ActionDispatcher._();
  static final ActionDispatcher instance = ActionDispatcher._();

  final AppRouter _router = AppRouter.instance;

  // ============================================================
  // MAIN DISPATCH METHOD
  // ============================================================

  /// Dispatch an action based on its type
  Future<ActionResult> dispatch(AstraNavigationAction action) async {
    AstraLogger.logBrainAction(
      'Dispatching action',
      action.type.name,
      metadata: action.toJson(),
    );

    // Check if confirmation is required
    if (action.requiresConfirmation) {
      AstraLogger.w('Action requires confirmation', tag: 'ActionDispatcher');
      // In a real implementation, this would return a pending result
      // and wait for user confirmation
    }

    // Dispatch based on action type
    switch (action.type) {
      case AstraActionType.openPatient:
        return _handleOpenPatient(action);
      case AstraActionType.openPrescription:
        return _handleOpenPrescription(action);
      case AstraActionType.openCart:
        return _handleOpenCart(action);
      case AstraActionType.openProduct:
        return _handleOpenProduct(action);
      case AstraActionType.openReport:
        return _handleOpenReport(action);
      case AstraActionType.openStorage:
        return _handleOpenStorage(action);
      case AstraActionType.openReminders:
        return _handleOpenReminders(action);
      case AstraActionType.openNotifications:
        return _handleOpenNotifications(action);
      case AstraActionType.openDoctorBooking:
        return _handleOpenDoctorBooking(action);
      case AstraActionType.openChat:
        return _handleOpenChat(action);
      case AstraActionType.openPayment:
        return _handleOpenPayment(action);
      case AstraActionType.openVideoCall:
        return _handleOpenVideoCall(action);
      case AstraActionType.openAppointment:
        return _handleOpenAppointment(action);
      case AstraActionType.openProfile:
        return _handleOpenProfile(action);
      case AstraActionType.goBack:
        return _handleGoBack(action);
      case AstraActionType.unknown:
        return _handleUnknownAction(action);
    }
  }

  /// Dispatch from JSON (for API responses)
  Future<ActionResult> dispatchFromJson(Map<String, dynamic> json) async {
    try {
      final action = AstraNavigationAction.fromJson(json);
      return dispatch(action);
    } catch (e, st) {
      AstraLogger.e('Failed to parse action from JSON', error: e, stackTrace: st);
      return ActionResult.failure('Invalid action format: $e');
    }
  }

  /// Dispatch from string (for simple action types)
  Future<ActionResult> dispatchFromString(String actionString) async {
    try {
      final action = AstraNavigationAction.fromString(actionString);
      return dispatch(action);
    } catch (e, st) {
      AstraLogger.e('Failed to parse action from string', error: e, stackTrace: st);
      return ActionResult.failure('Invalid action string: $actionString');
    }
  }

  // ============================================================
  // ACTION HANDLERS
  // ============================================================

  Future<ActionResult> _handleOpenPatient(AstraNavigationAction action) async {
    final patientId = action.patientId ?? action.targetId;
    
    if (patientId == null || patientId.isEmpty) {
      AstraLogger.w('Missing patient ID for openPatient action');
      return ActionResult.failure('Patient ID is required');
    }

    return _router.openPatient(
      patientId: patientId,
      patientName: action.params?['patient_name']?.toString(),
      phone: action.params?['phone']?.toString(),
    );
  }

  Future<ActionResult> _handleOpenPrescription(AstraNavigationAction action) async {
    return _router.openPrescription(
      prescriptionId: action.prescriptionId ?? action.targetId,
      patientId: action.patientId,
      patientName: action.params?['patient_name']?.toString(),
      patientPhone: action.params?['phone']?.toString(),
      astraFillData: action.params?['astra_fill_data'] as Map<String, dynamic>?,
    );
  }

  Future<ActionResult> _handleOpenCart(AstraNavigationAction action) async {
    return _router.openCart();
  }

  Future<ActionResult> _handleOpenProduct(AstraNavigationAction action) async {
    final productId = action.targetId ?? action.params?['product_id']?.toString();
    
    if (productId == null || productId.isEmpty) {
      return ActionResult.failure('Product ID is required');
    }

    return _router.openProduct(
      productId: productId,
      productName: action.params?['product_name']?.toString(),
    );
  }

  Future<ActionResult> _handleOpenReport(AstraNavigationAction action) async {
    final reportId = action.targetId ?? action.params?['report_id']?.toString();
    
    if (reportId == null || reportId.isEmpty) {
      return ActionResult.failure('Report ID is required');
    }

    return _router.openReport(
      reportId: reportId,
      reportType: action.params?['report_type']?.toString(),
    );
  }

  Future<ActionResult> _handleOpenStorage(AstraNavigationAction action) async {
    return _router.openStorage(
      patientId: action.patientId,
    );
  }

  Future<ActionResult> _handleOpenReminders(AstraNavigationAction action) async {
    return _router.openReminders(
      patientId: action.patientId,
    );
  }

  Future<ActionResult> _handleOpenNotifications(AstraNavigationAction action) async {
    return _router.openNotifications();
  }

  Future<ActionResult> _handleOpenDoctorBooking(AstraNavigationAction action) async {
    return _router.openDoctorBooking(
      patientId: action.patientId,
    );
  }

  Future<ActionResult> _handleOpenChat(AstraNavigationAction action) async {
    return _router.openChat(
      conversationId: action.params?['conversation_id']?.toString(),
    );
  }

  Future<ActionResult> _handleOpenPayment(AstraNavigationAction action) async {
    return _router.openPayment(
      orderId: action.orderId ?? action.params?['order_id']?.toString(),
      amount: (action.params?['amount'] as num?)?.toDouble(),
    );
  }

  Future<ActionResult> _handleOpenVideoCall(AstraNavigationAction action) async {
    return _router.openVideoCall(
      roomId: action.params?['room_id']?.toString() ?? action.params?['channel']?.toString(),
      patientId: action.patientId,
    );
  }

  Future<ActionResult> _handleOpenAppointment(AstraNavigationAction action) async {
    return _router.openAppointment(
      appointmentId: action.targetId ?? action.params?['appointment_id']?.toString(),
      showHistory: action.params?['show_history'] as bool? ?? false,
    );
  }

  Future<ActionResult> _handleOpenProfile(AstraNavigationAction action) async {
    return _router.openProfile(
      userId: action.params?['user_id']?.toString(),
    );
  }

  Future<ActionResult> _handleGoBack(AstraNavigationAction action) async {
    return _router.goBack();
  }

  Future<ActionResult> _handleUnknownAction(AstraNavigationAction action) async {
    AstraLogger.w('Unknown action type received', tag: 'ActionDispatcher');
    
    // Log the original action data for debugging
    AstraLogger.d('Unknown action details: ${action.toJson()}', tag: 'ActionDispatcher');
    
    return ActionResult.failure(
      'Unknown action type: ${action.type.name}. '
      'Original description: ${action.description ?? "none"}',
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Extract actions from AI response
  List<AstraNavigationAction> extractActions(Map<String, dynamic> response) {
    final List<AstraNavigationAction> actions = [];

    // Try different response formats
    // Format 1: actions array
    if (response['actions'] is List) {
      for (final actionJson in response['actions']) {
        if (actionJson is Map<String, dynamic>) {
          actions.add(AstraNavigationAction.fromJson(actionJson));
        }
      }
    }

    // Format 2: action object
    if (response['action'] is Map<String, dynamic>) {
      actions.add(AstraNavigationAction.fromJson(response['action']));
    }

    // Format 3: suggested_actions array
    if (response['suggested_actions'] is List) {
      for (final actionStr in response['suggested_actions']) {
        if (actionStr is String) {
          actions.add(AstraNavigationAction.fromString(actionStr));
        }
      }
    }

    // Format 4: navigation object
    if (response['navigation'] is Map<String, dynamic>) {
      actions.add(AstraNavigationAction.fromJson(response['navigation']));
    }

    return actions;
  }

  /// Get the highest priority action from a list
  AstraNavigationAction? getHighestPriorityAction(List<AstraNavigationAction> actions) {
    if (actions.isEmpty) return null;

    // Sort by priority
    actions.sort((a, b) {
      final priorityOrder = {
        ActionPriority.critical: 0,
        ActionPriority.high: 1,
        ActionPriority.normal: 2,
        ActionPriority.low: 3,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });

    return actions.first;
  }
}
