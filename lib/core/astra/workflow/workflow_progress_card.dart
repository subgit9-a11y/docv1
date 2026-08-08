import 'package:flutter/material.dart';
import 'package:doctro/core/astra/workflow/workflow_model.dart';
import 'package:doctro/core/astra/workflow/workflow_service.dart';
import 'package:doctro/theme/ayureze_theme.dart';

/// Prescription Workflow Progress Widget
///
/// Displays the progress of automated prescription workflow.
/// Shows individual task status and overall completion.
class PrescriptionWorkflowProgress extends StatefulWidget {
  /// Initial workflow data
  final PrescriptionWorkflow workflow;
  
  /// Callback when workflow completes
  final void Function(PrescriptionWorkflow)? onComplete;
  
  /// Callback when workflow fails
  final void Function(String error)? onError;
  
  /// Whether to auto-poll status updates
  final bool autoPoll;
  
  /// Poll interval for status updates
  final Duration pollInterval;
  
  /// Callback to open PDF (if generated)
  final VoidCallback? onOpenPdf;
  
  /// Callback to open Shopify cart (if created)
  final VoidCallback? onOpenCart;

  const PrescriptionWorkflowProgress({
    super.key,
    required this.workflow,
    this.onComplete,
    this.onError,
    this.autoPoll = true,
    this.pollInterval = const Duration(seconds: 2),
    this.onOpenPdf,
    this.onOpenCart,
  });

  @override
  State<PrescriptionWorkflowProgress> createState() => 
      _PrescriptionWorkflowProgressState();
}

class _PrescriptionWorkflowProgressState 
    extends State<PrescriptionWorkflowProgress> {
  final WorkflowService _service = WorkflowService();
  
  late PrescriptionWorkflow _workflow;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _workflow = widget.workflow;
    
    if (widget.autoPoll && _workflow.isInProgress) {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollStatus();
  }

  void _stopPolling() {
    _isPolling = false;
  }

  Future<void> _pollStatus() async {
    if (!_isPolling || !mounted) return;
    if (_workflow.isComplete || _workflow.isFailed) {
      _isPolling = false;
      return;
    }

    try {
      final updated = await _service.getWorkflowStatus(_workflow.id);
      
      if (mounted) {
        setState(() => _workflow = updated);
        
        if (updated.isComplete) {
          _isPolling = false;
          widget.onComplete?.call(updated);
        } else if (updated.isFailed) {
          _isPolling = false;
          widget.onError?.call(updated.error ?? 'Workflow failed');
        } else {
          // Continue polling
          await Future.delayed(widget.pollInterval);
          _pollStatus();
        }
      }
    } catch (e) {
      // Stop polling on error
      _isPolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Prescription workflow, ${_workflow.status.label}',
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildProgressBar(),
            _buildTasksList(),
            if (_workflow.result != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _workflow.status.color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription Workflow',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AyurezeTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _workflow.status.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _workflow.status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_workflow.isInProgress) _buildPollingIndicator(),
          if (_workflow.isFailed) _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (_workflow.isInProgress) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          value: _workflow.progress / 100,
          color: _workflow.status.color,
          strokeWidth: 3,
        ),
      );
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _workflow.status.color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _workflow.status.icon,
        color: _workflow.status.color,
        size: 24,
      ),
    );
  }

  Widget _buildPollingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Updating...',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return TextButton.icon(
      onPressed: _retryWorkflow,
      icon: const Icon(Icons.refresh, size: 16),
      label: const Text('Retry'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_workflow.progress}% complete',
                style: TextStyle(
                  fontSize: 12,
                  color: AyurezeTheme.textSecondary,
                ),
              ),
              Text(
                '${_workflow.tasks.where((t) => t.status == WorkflowTaskStatus.completed).length}/${_workflow.tasks.length} tasks',
                style: TextStyle(
                  fontSize: 12,
                  color: AyurezeTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _workflow.progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_workflow.status.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _workflow.tasks.map((task) => _buildTaskTile(task)).toList(),
      ),
    );
  }

  Widget _buildTaskTile(WorkflowTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildTaskIcon(task),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AyurezeTheme.textPrimary,
                  ),
                ),
                if (task.message != null)
                  Text(
                    task.message!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AyurezeTheme.textSecondary,
                    ),
                  ),
                if (task.error != null)
                  Text(
                    task.error!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          _buildTaskStatus(task),
        ],
      ),
    );
  }

  Widget _buildTaskIcon(WorkflowTask task) {
    if (task.status == WorkflowTaskStatus.inProgress) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(task.color),
        ),
      );
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: task.color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        task.status == WorkflowTaskStatus.completed
            ? Icons.check
            : (task.status == WorkflowTaskStatus.failed
                ? Icons.close
                : task.icon),
        size: 14,
        color: task.color,
      ),
    );
  }

  Widget _buildTaskStatus(WorkflowTask task) {
    final labels = {
      WorkflowTaskStatus.pending: 'Pending',
      WorkflowTaskStatus.inProgress: 'Running',
      WorkflowTaskStatus.completed: 'Done',
      WorkflowTaskStatus.failed: 'Failed',
      WorkflowTaskStatus.skipped: 'Skipped',
    };
    
    return Text(
      labels[task.status] ?? '',
      style: TextStyle(
        fontSize: 11,
        color: task.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildResults() {
    final result = _workflow.result!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Workflow Complete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 12),
          if (result.pdfUrl != null)
            _buildResultItem(
              icon: Icons.picture_as_pdf,
              label: 'PDF Generated',
              onTap: widget.onOpenPdf,
            ),
          if (result.shopifyCartUrl != null)
            _buildResultItem(
              icon: Icons.shopping_cart,
              label: 'Shopify Cart Created',
              onTap: widget.onOpenCart,
            ),
          if (result.notificationId != null)
            _buildResultItem(
              icon: Icons.notifications,
              label: 'Notification Sent',
              subtitle: 'Patient notified',
            ),
          if (result.whatsappMessageId != null)
            _buildResultItem(
              icon: Icons.message,
              label: 'WhatsApp Sent',
              subtitle: 'Message delivered',
            ),
          if (result.reminderId != null)
            _buildResultItem(
              icon: Icons.alarm,
              label: 'Reminder Set',
              subtitle: 'Medication reminder created',
            ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: AyurezeTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AyurezeTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AyurezeTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryWorkflow() async {
    final failedTask = _workflow.failedTask;
    if (failedTask == null) return;
    
    try {
      final updated = await _service.retryTask(_workflow.id, failedTask.id);
      if (mounted) {
        setState(() => _workflow = updated);
        _startPolling();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Retry failed: $e')),
        );
      }
    }
  }
}

/// Compact workflow status badge
class WorkflowStatusBadge extends StatelessWidget {
  final WorkflowStatus status;
  final bool showLabel;

  const WorkflowStatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Workflow status: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: 14,
              color: status.color,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: status.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
