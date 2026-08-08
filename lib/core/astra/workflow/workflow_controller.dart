import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:doctro/core/astra/workflow/workflow_model.dart';
import 'package:doctro/core/astra/workflow/workflow_service.dart';
import 'package:doctro/core/astra/utils/astra_logger.dart';

/// Workflow Controller
///
/// Manages prescription workflow state and polling.
class WorkflowController extends ChangeNotifier {
  static final WorkflowController _instance = WorkflowController._internal();
  
  factory WorkflowController() => _instance;
  WorkflowController._internal();

  final WorkflowService _service = WorkflowService();

  PrescriptionWorkflow? _currentWorkflow;
  PrescriptionWorkflow? get currentWorkflow => _currentWorkflow;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool get isInProgress => _currentWorkflow?.isInProgress ?? false;
  bool get isComplete => _currentWorkflow?.isComplete ?? false;
  bool get isFailed => _currentWorkflow?.isFailed ?? false;

  StreamSubscription<PrescriptionWorkflow>? _pollSubscription;

  // ============================================================
  // START WORKFLOW
  // ============================================================

  /// Start prescription workflow
  Future<PrescriptionWorkflow?> startPrescriptionWorkflow({
    required String prescriptionId,
    required String patientId,
    required String doctorId,
    String? patientPhone,
    String? patientName,
    Map<String, dynamic>? prescriptionData,
    bool autoPoll = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AstraLogger.i('Starting prescription workflow', tag: 'WorkflowController');

      final workflow = await _service.startPrescriptionWorkflow(
        prescriptionId: prescriptionId,
        patientId: patientId,
        doctorId: doctorId,
        patientPhone: patientPhone,
        patientName: patientName,
        prescriptionData: prescriptionData,
      );

      _currentWorkflow = workflow;
      _isLoading = false;
      notifyListeners();

      if (autoPoll && workflow.isInProgress) {
        _startPolling();
      }

      return workflow;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      AstraLogger.e('Failed to start workflow', error: e, tag: 'WorkflowController');
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // POLLING
  // ============================================================

  void _startPolling() {
    if (_currentWorkflow == null) return;
    
    _pollSubscription?.cancel();
    _pollSubscription = _service
        .pollWorkflowStatus(_currentWorkflow!.id)
        .listen(
          (workflow) {
            _currentWorkflow = workflow;
            notifyListeners();
            
            if (workflow.isComplete || workflow.isFailed) {
              _pollSubscription?.cancel();
              AstraLogger.i(
                'Workflow ${workflow.isComplete ? 'completed' : 'failed'}',
                tag: 'WorkflowController',
              );
            }
          },
          onError: (e) {
            _error = e.toString();
            _pollSubscription?.cancel();
            notifyListeners();
          },
        );
  }

  void stopPolling() {
    _pollSubscription?.cancel();
    _pollSubscription = null;
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  /// Retry failed workflow
  Future<void> retryWorkflow() async {
    if (_currentWorkflow == null) return;
    
    final failedTask = _currentWorkflow!.failedTask;
    if (failedTask == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final workflow = await _service.retryTask(
        _currentWorkflow!.id,
        failedTask.id,
      );

      _currentWorkflow = workflow;
      _isLoading = false;
      notifyListeners();

      if (workflow.isInProgress) {
        _startPolling();
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Cancel running workflow
  Future<void> cancelWorkflow() async {
    if (_currentWorkflow == null) return;

    try {
      await _service.cancelWorkflow(_currentWorkflow!.id);
      stopPolling();
      _currentWorkflow = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refresh workflow status
  Future<void> refreshStatus() async {
    if (_currentWorkflow == null) return;

    try {
      final workflow = await _service.getWorkflowStatus(_currentWorkflow!.id);
      _currentWorkflow = workflow;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  void clear() {
    stopPolling();
    _currentWorkflow = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
