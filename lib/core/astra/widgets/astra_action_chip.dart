import 'package:flutter/material.dart';
import 'package:doctro/core/astra/actions/action_models.dart';

/// Astra Action Chip Widget
///
/// Displays a clickable action chip from Astra AI response.
/// Fully accessible with screen reader support.
class AstraActionChip extends StatelessWidget {
  /// The action to display
  final AstraNavigationAction action;
  
  /// Callback when action is tapped
  final void Function(AstraNavigationAction action)? onTap;
  
  /// Whether the chip is selected
  final bool isSelected;
  
  /// Whether the chip is loading
  final bool isLoading;

  const AstraActionChip({
    super.key,
    required this.action,
    this.onTap,
    this.isSelected = false,
    this.isLoading = false,
  });

  String get _accessibilityLabel {
    final description = action.description ?? _getDefaultDescription();
    final priority = action.priority == ActionPriority.high 
        ? ', High priority' 
        : (action.priority == ActionPriority.critical 
            ? ', Critical priority' 
            : '');
    return '$description$priority${isSelected ? ', Selected' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: _accessibilityLabel,
      hint: isLoading ? 'Loading, please wait' : 'Double tap to activate',
      button: true,
      enabled: !isLoading,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () => onTap?.call(action),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _getBorderColor(),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _getAccentColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(
                  _getActionIcon(),
                  size: 18,
                  color: _getIconColor(),
                ),
                
                const SizedBox(width: 8),
                
                // Text
                Text(
                  action.description ?? _getDefaultDescription(),
                  style: TextStyle(
                    color: _getTextColor(),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                
                // Priority indicator
                if (action.priority == ActionPriority.high ||
                    action.priority == ActionPriority.critical) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    label: '${action.priority == ActionPriority.critical ? 'Critical' : 'High'} priority',
                    child: _buildPriorityIndicator(),
                  ),
                ],
                
                // Loading indicator
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_getAccentColor()),
                    ),
                  ),
                ],
              
              // Arrow indicator
              if (!isLoading) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: _getTextColor().withOpacity(0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    if (action.priority == ActionPriority.critical) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '⚡',
          style: TextStyle(fontSize: 10),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '!',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade700,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return _getAccentColor().withOpacity(0.1);
    }
    
    switch (action.priority) {
      case ActionPriority.critical:
        return Colors.red.shade50;
      case ActionPriority.high:
        return Colors.orange.shade50;
      default:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    if (isSelected) {
      return _getAccentColor();
    }
    
    switch (action.priority) {
      case ActionPriority.critical:
        return Colors.red.shade300;
      case ActionPriority.high:
        return Colors.orange.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getAccentColor() {
    switch (action.priority) {
      case ActionPriority.critical:
        return Colors.red;
      case ActionPriority.high:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _getTextColor() {
    if (isSelected) {
      return _getAccentColor();
    }
    
    switch (action.priority) {
      case ActionPriority.critical:
        return Colors.red.shade700;
      case ActionPriority.high:
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getIconColor() {
    if (isSelected) {
      return _getAccentColor();
    }
    
    switch (action.priority) {
      case ActionPriority.critical:
        return Colors.red;
      case ActionPriority.high:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon() {
    switch (action.type) {
      case AstraActionType.openPatient:
        return Icons.person;
      case AstraActionType.openPrescription:
        return Icons.description;
      case AstraActionType.openCart:
        return Icons.shopping_cart;
      case AstraActionType.openProduct:
        return Icons.medication;
      case AstraActionType.openReport:
        return Icons.assessment;
      case AstraActionType.openStorage:
        return Icons.folder;
      case AstraActionType.openReminders:
        return Icons.alarm;
      case AstraActionType.openNotifications:
        return Icons.notifications;
      case AstraActionType.openDoctorBooking:
        return Icons.calendar_month;
      case AstraActionType.openChat:
        return Icons.chat;
      case AstraActionType.openPayment:
        return Icons.payment;
      case AstraActionType.openVideoCall:
        return Icons.videocam;
      case AstraActionType.openAppointment:
        return Icons.event;
      case AstraActionType.openProfile:
        return Icons.account_circle;
      case AstraActionType.goBack:
        return Icons.arrow_back;
      case AstraActionType.unknown:
        return Icons.touch_app;
    }
  }

  String _getDefaultDescription() {
    switch (action.type) {
      case AstraActionType.openPatient:
        return 'View Patient';
      case AstraActionType.openPrescription:
        return 'Open Prescription';
      case AstraActionType.openCart:
        return 'View Cart';
      case AstraActionType.openProduct:
        return 'View Product';
      case AstraActionType.openReport:
        return 'View Report';
      case AstraActionType.openStorage:
        return 'View Documents';
      case AstraActionType.openReminders:
        return 'Manage Reminders';
      case AstraActionType.openNotifications:
        return 'View Notifications';
      case AstraActionType.openDoctorBooking:
        return 'Book Appointment';
      case AstraActionType.openChat:
        return 'Open Chat';
      case AstraActionType.openPayment:
        return 'Pay Now';
      case AstraActionType.openVideoCall:
        return 'Start Video Call';
      case AstraActionType.openAppointment:
        return 'View Appointment';
      case AstraActionType.openProfile:
        return 'View Profile';
      case AstraActionType.goBack:
        return 'Go Back';
      case AstraActionType.unknown:
        return 'Take Action';
    }
  }
}

/// Widget to display a list of action chips
class AstraActionChipList extends StatelessWidget {
  /// List of actions to display
  final List<AstraNavigationAction> actions;
  
  /// Callback when an action is tapped
  final void Function(AstraNavigationAction action)? onActionTap;
  
  /// Currently executing action
  final String? loadingActionType;

  const AstraActionChipList({
    super.key,
    required this.actions,
    this.onActionTap,
    this.loadingActionType,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return AstraActionChip(
          action: action,
          onTap: onActionTap,
          isLoading: loadingActionType == action.type.name,
        );
      }).toList(),
    );
  }
}
