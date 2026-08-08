import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doctro/core/astra/workflow/workflow_model.dart';
import 'package:doctro/core/astra/utils/astra_config.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Workflow Service
///
/// Handles prescription workflow automation.
/// Calls ONE backend endpoint - backend handles all downstream tasks:
/// - PDF generation
/// - Storage upload
/// - Reminder creation
/// - Notification sending
/// - WhatsApp message
/// - Shopify cart creation
class WorkflowService {
  static final WorkflowService _instance = WorkflowService._internal();
  
  factory WorkflowService() => _instance;
  WorkflowService._internal();

  String get _baseUrl => AstraConfig.baseUrl;
  String get _apiKey => AstraConfig.apiKey;

  // ============================================================
  // PRESCRIPTION WORKFLOW
  // ============================================================

  /// Start prescription workflow
  /// 
  /// This is the ONLY endpoint Flutter calls.
  /// Backend handles all downstream tasks:
  /// - Generate PDF prescription
  /// - Upload to storage
  /// - Create medication reminders
  /// - Send push notification
  /// - Send WhatsApp message
  /// - Create Shopify draft cart with medicines
  /// - Notify patient
  Future<PrescriptionWorkflow> startPrescriptionWorkflow({
    required String prescriptionId,
    required String patientId,
    required String doctorId,
    String? patientPhone,
    String? patientName,
    Map<String, dynamic>? prescriptionData,
  }) async {
    try {
      AstraLogger.i('Starting prescription workflow', tag: 'WorkflowService', data: {
        'prescriptionId': prescriptionId,
        'patientId': patientId,
      });

      final uri = Uri.parse('$_baseUrl/api/workflow/prescription');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'prescription_id': prescriptionId,
          'patient_id': patientId,
          'doctor_id': doctorId,
          if (patientPhone != null) 'patient_phone': patientPhone,
          if (patientName != null) 'patient_name': patientName,
          if (prescriptionData != null) 'prescription_data': prescriptionData,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw WorkflowException(
          'Workflow timeout',
          WorkflowErrorType.timeout,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final workflow = PrescriptionWorkflow.fromJson(data);
        
        AstraLogger.i('Workflow started: ${workflow.id}', tag: 'WorkflowService');
        return workflow;
      } else {
        throw WorkflowException(
          'Failed to start workflow: ${response.statusCode}',
          WorkflowErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is WorkflowException) rethrow;
      AstraLogger.e('Workflow start error', error: e, tag: 'WorkflowService');
      throw WorkflowException(
        'Failed to start workflow: $e',
        WorkflowErrorType.unknown,
      );
    }
  }

  /// Get workflow status
  Future<PrescriptionWorkflow> getWorkflowStatus(String workflowId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/workflow/$workflowId');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PrescriptionWorkflow.fromJson(data);
      } else {
        throw WorkflowException(
          'Failed to get workflow status: ${response.statusCode}',
          WorkflowErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is WorkflowException) rethrow;
      throw WorkflowException(
        'Failed to get workflow status: $e',
        WorkflowErrorType.unknown,
      );
    }
  }

  /// Poll workflow status until complete
  Stream<PrescriptionWorkflow> pollWorkflowStatus(
    String workflowId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async* {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      final workflow = await getWorkflowStatus(workflowId);
      yield workflow;
      
      if (workflow.isComplete || workflow.isFailed) {
        break;
      }
      
      await Future.delayed(interval);
    }
    
    stopwatch.stop();
  }

  /// Cancel workflow
  Future<void> cancelWorkflow(String workflowId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/workflow/$workflowId/cancel');
      
      await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );
    } catch (e) {
      AstraLogger.e('Workflow cancel error', error: e, tag: 'WorkflowService');
    }
  }

  // ============================================================
  // WORKFLOW ACTIONS
  // ============================================================

  /// Retry failed task
  Future<PrescriptionWorkflow> retryTask(
    String workflowId,
    String taskId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/workflow/$workflowId/tasks/$taskId/retry',
      );
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PrescriptionWorkflow.fromJson(data);
      } else {
        throw WorkflowException(
          'Failed to retry task: ${response.statusCode}',
          WorkflowErrorType.serverError,
        );
      }
    } catch (e) {
      if (e is WorkflowException) rethrow;
      throw WorkflowException(
        'Failed to retry task: $e',
        WorkflowErrorType.unknown,
      );
    }
  }

  /// Skip task (mark as skipped)
  Future<PrescriptionWorkflow> skipTask(
    String workflowId,
    String taskId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/workflow/$workflowId/tasks/$taskId/skip',
      );
      
      await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      return await getWorkflowStatus(workflowId);
    } catch (e) {
      if (e is WorkflowException) rethrow;
      throw WorkflowException(
        'Failed to skip task: $e',
        WorkflowErrorType.unknown,
      );
    }
  }
}

/// Workflow error types
enum WorkflowErrorType {
  unknown,
  timeout,
  networkError,
  serverError,
  notFound,
}

/// Workflow exception
class WorkflowException implements Exception {
  final String message;
  final WorkflowErrorType type;

  WorkflowException(this.message, this.type);

  @override
  String toString() => 'WorkflowException: $message';

  bool get isTimeout => type == WorkflowErrorType.timeout;
  bool get isNetworkError => type == WorkflowErrorType.networkError;
  bool get isServerError => type == WorkflowErrorType.serverError;
}
