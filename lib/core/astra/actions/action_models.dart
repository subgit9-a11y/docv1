/// Astra Action Models
///
/// Defines all actions that Astra Brain can return and how they should be handled.

/// Supported navigation actions
enum AstraActionType {
  /// Open patient details screen
  openPatient,
  
  /// Open prescription screen
  openPrescription,
  
  /// Open shopping cart
  openCart,
  
  /// Open product details
  openProduct,
  
  /// Open report/view documents
  openReport,
  
  /// Open storage/documents
  openStorage,
  
  /// Open reminders screen
  openReminders,
  
  /// Open notifications
  openNotifications,
  
  /// Open doctor booking
  openDoctorBooking,
  
  /// Open chat screen
  openChat,
  
  /// Open payment screen
  openPayment,
  
  /// Open video call
  openVideoCall,
  
  /// Open appointment details
  openAppointment,
  
  /// Open profile screen
  openProfile,
  
  /// Navigate back
  goBack,
  
  /// Unknown action (fallback)
  unknown,
}

/// Action priority
enum ActionPriority {
  low,
  normal,
  high,
  critical,
}

/// Astra Action definition
class AstraNavigationAction {
  /// Action type
  final AstraActionType type;
  
  /// Human-readable description
  final String? description;
  
  /// Action parameters
  final Map<String, dynamic>? params;
  
  /// Priority level
  final ActionPriority priority;
  
  /// Whether to show confirmation before executing
  final bool requiresConfirmation;
  
  /// Action confidence score (0.0 to 1.0)
  final double? confidence;

  const AstraNavigationAction({
    required this.type,
    this.description,
    this.params,
    this.priority = ActionPriority.normal,
    this.requiresConfirmation = false,
    this.confidence,
  });

  /// Get target ID from params (commonly used)
  String? get targetId => params?['id']?.toString() ?? params?['target_id']?.toString();
  
  /// Get patient ID from params
  String? get patientId => params?['patient_id']?.toString();
  
  /// Get prescription ID from params
  String? get prescriptionId => params?['prescription_id']?.toString();
  
  /// Get order ID from params
  String? get orderId => params?['order_id']?.toString();

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (description != null) 'description': description,
      if (params != null) 'params': params,
      'priority': priority.name,
      'requires_confirmation': requiresConfirmation,
      if (confidence != null) 'confidence': confidence,
    };
  }

  /// Create from JSON response
  factory AstraNavigationAction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase() ?? '';
    final type = _parseActionType(typeStr);
    
    return AstraNavigationAction(
      type: type,
      description: json['description'] as String?,
      params: json['params'] as Map<String, dynamic>? ?? json['parameters'] as Map<String, dynamic>?,
      priority: _parsePriority(json['priority']),
      requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }

  /// Create from action string
  factory AstraNavigationAction.fromString(String actionString) {
    final type = _parseActionType(actionString.toLowerCase());
    return AstraNavigationAction(type: type);
  }

  /// Parse action type from string
  static AstraActionType _parseActionType(String typeStr) {
    // Handle various formats
    final normalized = typeStr
        .replaceAll('_', '')
        .replaceAll('-', '')
        .toLowerCase();
    
    for (final type in AstraActionType.values) {
      if (type.name.replaceAll('_', '').toLowerCase() == normalized) {
        return type;
      }
    }
    
    // Check for common aliases
    final aliases = {
      'openpatient': AstraActionType.openPatient,
      'patient': AstraActionType.openPatient,
      'viewpatient': AstraActionType.openPatient,
      'openprescription': AstraActionType.openPrescription,
      'prescription': AstraActionType.openPrescription,
      'viewprescription': AstraActionType.openPrescription,
      'opencart': AstraActionType.openCart,
      'cart': AstraActionType.openCart,
      'shoppingcart': AstraActionType.openCart,
      'openproduct': AstraActionType.openProduct,
      'product': AstraActionType.openProduct,
      'viewproduct': AstraActionType.openProduct,
      'openreport': AstraActionType.openReport,
      'report': AstraActionType.openReport,
      'viewreport': AstraActionType.openReport,
      'openstorage': AstraActionType.openStorage,
      'storage': AstraActionType.openStorage,
      'documents': AstraActionType.openStorage,
      'openreminders': AstraActionType.openReminders,
      'reminders': AstraActionType.openReminders,
      'medicinereminder': AstraActionType.openReminders,
      'opennotifications': AstraActionType.openNotifications,
      'notifications': AstraActionType.openNotifications,
      'openchat': AstraActionType.openChat,
      'chat': AstraActionType.openChat,
      'openpayment': AstraActionType.openPayment,
      'payment': AstraActionType.openPayment,
      'openvideocall': AstraActionType.openVideoCall,
      'videocall': AstraActionType.openVideoCall,
      'video': AstraActionType.openVideoCall,
      'openappointment': AstraActionType.openAppointment,
      'appointment': AstraActionType.openAppointment,
      'viewappointment': AstraActionType.openAppointment,
      'openprofile': AstraActionType.openProfile,
      'profile': AstraActionType.openProfile,
      'goback': AstraActionType.goBack,
      'back': AstraActionType.goBack,
      'navigateback': AstraActionType.goBack,
      'doctorbooking': AstraActionType.openDoctorBooking,
      'booking': AstraActionType.openDoctorBooking,
      'schedule': AstraActionType.openDoctorBooking,
    };
    
    return aliases[normalized] ?? AstraActionType.unknown;
  }

  /// Parse priority from string
  static ActionPriority _parsePriority(dynamic priority) {
    if (priority == null) return ActionPriority.normal;
    
    final str = priority.toString().toLowerCase();
    
    if (str == 'high' || str == 'urgent' || str == 'critical') {
      return ActionPriority.high;
    }
    if (str == 'low' || str == 'minor') {
      return ActionPriority.low;
    }
    if (str == 'critical' || str == 'emergency') {
      return ActionPriority.critical;
    }
    
    return ActionPriority.normal;
  }

  /// Get display name
  String get displayName {
    switch (type) {
      case AstraActionType.openPatient:
        return 'Open Patient';
      case AstraActionType.openPrescription:
        return 'Open Prescription';
      case AstraActionType.openCart:
        return 'Open Cart';
      case AstraActionType.openProduct:
        return 'Open Product';
      case AstraActionType.openReport:
        return 'View Report';
      case AstraActionType.openStorage:
        return 'Open Documents';
      case AstraActionType.openReminders:
        return 'Manage Reminders';
      case AstraActionType.openNotifications:
        return 'View Notifications';
      case AstraActionType.openDoctorBooking:
        return 'Book Appointment';
      case AstraActionType.openChat:
        return 'Open Chat';
      case AstraActionType.openPayment:
        return 'Open Payment';
      case AstraActionType.openVideoCall:
        return 'Start Video Call';
      case AstraActionType.openAppointment:
        return 'View Appointment';
      case AstraActionType.openProfile:
        return 'View Profile';
      case AstraActionType.goBack:
        return 'Go Back';
      case AstraActionType.unknown:
        return 'Unknown Action';
    }
  }

  @override
  String toString() {
    return 'AstraNavigationAction(type: ${type.name}, priority: ${priority.name}, '
        'params: $params)';
  }
}

/// Action result
class ActionResult {
  /// Whether the action was successful
  final bool success;
  
  /// Error message if failed
  final String? errorMessage;
  
  /// Result data
  final dynamic data;

  const ActionResult({
    required this.success,
    this.errorMessage,
    this.data,
  });

  factory ActionResult.success({dynamic data}) {
    return ActionResult(success: true, data: data);
  }

  factory ActionResult.failure(String message) {
    return ActionResult(success: false, errorMessage: message);
  }
}
