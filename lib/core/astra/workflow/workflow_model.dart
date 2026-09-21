import 'package:flutter/material.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';

/// Prescription Workflow Model
///
/// Represents the automated prescription workflow triggered after doctor approval.
/// Backend handles: PDF generation, storage upload, reminders, notifications, WhatsApp, Shopify.
class PrescriptionWorkflow {
  /// Unique workflow identifier
  final String id;

  /// Prescription ID
  final String prescriptionId;

  /// Patient ID
  final String patientId;

  /// Doctor ID
  final String doctorId;

  /// Current workflow status
  final WorkflowStatus status;

  /// Individual task statuses
  final List<WorkflowTask> tasks;

  /// Progress percentage (0-100)
  final int progress;

  /// Creation timestamp
  final DateTime createdAt;

  /// Completion timestamp
  final DateTime? completedAt;

  /// Error message if failed
  final String? error;

  /// URLs and references generated during workflow
  final WorkflowResult? result;

  PrescriptionWorkflow({
    required this.id,
    required this.prescriptionId,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.tasks,
    required this.progress,
    required this.createdAt,
    this.completedAt,
    this.error,
    this.result,
  });

  /// Create from JSON response
  factory PrescriptionWorkflow.fromJson(Map<String, dynamic> json) {
    return PrescriptionWorkflow(
      id: json['id']?.toString() ?? '',
      prescriptionId: json['prescription_id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      status: WorkflowStatus.fromString(json['status']),
      tasks: (json['tasks'] as List?)
              ?.map((t) => WorkflowTask.fromJson(t))
              .toList() ??
          [],
      progress: json['progress'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      error: json['error'],
      result: json['result'] != null
          ? WorkflowResult.fromJson(json['result'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'status': status.name,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (error != null) 'error': error,
      if (result != null) 'result': result!.toJson(),
    };
  }

  /// Check if workflow is complete
  bool get isComplete => status == WorkflowStatus.completed;

  /// Check if workflow failed
  bool get isFailed => status == WorkflowStatus.failed;

  /// Check if workflow is in progress
  bool get isInProgress =>
      status == WorkflowStatus.pending || status == WorkflowStatus.inProgress;

  /// Get next pending task
  WorkflowTask? get nextPendingTask =>
      tasks.where((t) => t.status == WorkflowTaskStatus.pending).firstOrNull;

  /// Get failed task if any
  WorkflowTask? get failedTask =>
      tasks.where((t) => t.status == WorkflowTaskStatus.failed).firstOrNull;
}

/// Workflow status
enum WorkflowStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled;

  String get label {
    switch (this) {
      case WorkflowStatus.pending:
        return 'Pending';
      case WorkflowStatus.inProgress:
        return 'Processing';
      case WorkflowStatus.completed:
        return 'Completed';
      case WorkflowStatus.failed:
        return 'Failed';
      case WorkflowStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case WorkflowStatus.pending:
        return Colors.grey;
      case WorkflowStatus.inProgress:
        return Colors.blue;
      case WorkflowStatus.completed:
        return Colors.green;
      case WorkflowStatus.failed:
        return Colors.red;
      case WorkflowStatus.cancelled:
        return Colors.orange;
    }
  }

  List<List<dynamic>> get icon {
    switch (this) {
      case WorkflowStatus.pending:
        return HugeIcons.strokeRoundedHourglass;
      case WorkflowStatus.inProgress:
        return HugeIcons.strokeRoundedRefresh01;
      case WorkflowStatus.completed:
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case WorkflowStatus.failed:
        return AppIcons.error;
      case WorkflowStatus.cancelled:
        return HugeIcons.strokeRoundedCancel01;
    }
  }

  static WorkflowStatus fromString(String? value) {
    if (value == null) return WorkflowStatus.pending;
    return WorkflowStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => WorkflowStatus.pending,
    );
  }
}

/// Workflow task (individual step)
class WorkflowTask {
  /// Task identifier
  final String id;

  /// Task type
  final TaskType type;

  /// Display name
  final String name;

  /// Task status
  final WorkflowTaskStatus status;

  /// Progress message
  final String? message;

  /// Error if failed
  final String? error;

  /// Task data/result
  final Map<String, dynamic>? data;

  WorkflowTask({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    this.message,
    this.error,
    this.data,
  });

  factory WorkflowTask.fromJson(Map<String, dynamic> json) {
    return WorkflowTask(
      id: json['id']?.toString() ?? '',
      type: TaskType.fromString(json['type']),
      name: json['name'] ?? '',
      status: WorkflowTaskStatus.fromString(json['status']),
      message: json['message'],
      error: json['error'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'status': status.name,
      if (message != null) 'message': message,
      if (error != null) 'error': error,
      if (data != null) 'data': data,
    };
  }

  List<List<dynamic>> get icon => type.icon;
  Color get color => status.color;
}

/// Task types (backend handles all of these)
enum TaskType {
  generatePdf,
  uploadStorage,
  createReminder,
  sendNotification,
  sendWhatsapp,
  createShopifyCart,
  notifyPatient,
  sendEmail,
  updateAppointment;

  String get label {
    switch (this) {
      case TaskType.generatePdf:
        return 'Generate PDF';
      case TaskType.uploadStorage:
        return 'Upload to Storage';
      case TaskType.createReminder:
        return 'Create Reminder';
      case TaskType.sendNotification:
        return 'Send Notification';
      case TaskType.sendWhatsapp:
        return 'Send WhatsApp';
      case TaskType.createShopifyCart:
        return 'Create Shopify Cart';
      case TaskType.notifyPatient:
        return 'Notify Patient';
      case TaskType.sendEmail:
        return 'Send Email';
      case TaskType.updateAppointment:
        return 'Update Appointment';
    }
  }

  List<List<dynamic>> get icon {
    switch (this) {
      case TaskType.generatePdf:
        return HugeIcons.strokeRoundedPdf01;
      case TaskType.uploadStorage:
        return HugeIcons.strokeRoundedCloudUpload;
      case TaskType.createReminder:
        return HugeIcons.strokeRoundedAlarmClockPlus;
      case TaskType.sendNotification:
        return HugeIcons.strokeRoundedNotification03;
      case TaskType.sendWhatsapp:
        return HugeIcons.strokeRoundedMessage01;
      case TaskType.createShopifyCart:
        return HugeIcons.strokeRoundedShoppingCart01;
      case TaskType.notifyPatient:
        return HugeIcons.strokeRoundedUser;
      case TaskType.sendEmail:
        return AppIcons.email;
      case TaskType.updateAppointment:
        return HugeIcons.strokeRoundedCalendar03;
    }
  }

  static TaskType fromString(String? value) {
    if (value == null) return TaskType.generatePdf;
    return TaskType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskType.generatePdf,
    );
  }
}

/// Workflow task status
enum WorkflowTaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  skipped;

  Color get color {
    switch (this) {
      case WorkflowTaskStatus.pending:
        return Colors.grey;
      case WorkflowTaskStatus.inProgress:
        return Colors.blue;
      case WorkflowTaskStatus.completed:
        return Colors.green;
      case WorkflowTaskStatus.failed:
        return Colors.red;
      case WorkflowTaskStatus.skipped:
        return Colors.orange;
    }
  }

  static WorkflowTaskStatus fromString(String? value) {
    if (value == null) return WorkflowTaskStatus.pending;
    return WorkflowTaskStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => WorkflowTaskStatus.pending,
    );
  }
}

/// Workflow result (URLs and references)
class WorkflowResult {
  /// PDF URL
  final String? pdfUrl;

  /// Storage URL
  final String? storageUrl;

  /// Reminder ID
  final String? reminderId;

  /// Notification ID
  final String? notificationId;

  /// WhatsApp message ID
  final String? whatsappMessageId;

  /// Shopify cart URL
  final String? shopifyCartUrl;

  /// Shopify cart ID
  final String? shopifyCartId;

  /// Additional data
  final Map<String, dynamic>? additionalData;

  WorkflowResult({
    this.pdfUrl,
    this.storageUrl,
    this.reminderId,
    this.notificationId,
    this.whatsappMessageId,
    this.shopifyCartUrl,
    this.shopifyCartId,
    this.additionalData,
  });

  factory WorkflowResult.fromJson(Map<String, dynamic> json) {
    return WorkflowResult(
      pdfUrl: json['pdf_url'],
      storageUrl: json['storage_url'],
      reminderId: json['reminder_id']?.toString(),
      notificationId: json['notification_id']?.toString(),
      whatsappMessageId: json['whatsapp_message_id']?.toString(),
      shopifyCartUrl: json['shopify_cart_url'],
      shopifyCartId: json['shopify_cart_id']?.toString(),
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pdfUrl != null) 'pdf_url': pdfUrl,
      if (storageUrl != null) 'storage_url': storageUrl,
      if (reminderId != null) 'reminder_id': reminderId,
      if (notificationId != null) 'notification_id': notificationId,
      if (whatsappMessageId != null) 'whatsapp_message_id': whatsappMessageId,
      if (shopifyCartUrl != null) 'shopify_cart_url': shopifyCartUrl,
      if (shopifyCartId != null) 'shopify_cart_id': shopifyCartId,
      if (additionalData != null) 'additional_data': additionalData,
    };
  }
}
