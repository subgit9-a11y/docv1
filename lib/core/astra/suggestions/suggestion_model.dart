import 'package:flutter/material.dart';

/// AI Suggestion Model
///
/// Represents a contextual suggestion from Astra AI.
/// These appear on existing screens to assist the doctor.
class AISuggestion {
  /// Unique identifier
  final String id;
  
  /// Suggestion type
  final SuggestionType type;
  
  /// Suggestion title
  final String title;
  
  /// Detailed description
  final String? description;
  
  /// Priority level
  final SuggestionPriority priority;
  
  /// Associated action (optional)
  final SuggestionAction? action;
  
  /// Category for grouping
  final String? category;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;
  
  /// Timestamp when suggestion was generated
  final DateTime? generatedAt;
  
  /// Whether the suggestion has been dismissed
  bool isDismissed;

  AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.priority = SuggestionPriority.medium,
    this.action,
    this.category,
    this.metadata,
    this.generatedAt,
    this.isDismissed = false,
  });

  /// Create from JSON
  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: SuggestionType.fromString(json['type']),
      title: json['title'] ?? 'Suggestion',
      description: json['description'],
      priority: SuggestionPriority.fromString(json['priority']),
      action: json['action'] != null 
          ? SuggestionAction.fromJson(json['action']) 
          : null,
      category: json['category'],
      metadata: json['metadata'],
      generatedAt: json['generated_at'] != null 
          ? DateTime.tryParse(json['generated_at']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      if (description != null) 'description': description,
      'priority': priority.name,
      if (action != null) 'action': action!.toJson(),
      if (category != null) 'category': category,
      if (metadata != null) 'metadata': metadata,
      if (generatedAt != null) 'generated_at': generatedAt!.toIso8601String(),
    };
  }

  /// Copy with modifications
  AISuggestion copyWith({
    String? id,
    SuggestionType? type,
    String? title,
    String? description,
    SuggestionPriority? priority,
    SuggestionAction? action,
    String? category,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
    bool? isDismissed,
  }) {
    return AISuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      action: action ?? this.action,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  /// Get icon for this suggestion type
  IconData get icon => type.icon;

  /// Get color for this suggestion type
  Color get color => type.color;

  /// Get priority color
  Color get priorityColor => priority.color;

  @override
  String toString() => 'AISuggestion($title, $type, $priority)';
}

/// Suggestion types
enum SuggestionType {
  followUp,
  reminder,
  payment,
  medication,
  healthTip,
  labTest,
  referral,
  vitalAlert,
  drugInteraction,
  duplicateMedicine,
  alternative,
  appointmentReminder,
  general;

  String get label {
    switch (this) {
      case SuggestionType.followUp:
        return 'Follow-up';
      case SuggestionType.reminder:
        return 'Reminder';
      case SuggestionType.payment:
        return 'Payment';
      case SuggestionType.medication:
        return 'Medication';
      case SuggestionType.healthTip:
        return 'Health Tip';
      case SuggestionType.labTest:
        return 'Lab Test';
      case SuggestionType.referral:
        return 'Referral';
      case SuggestionType.vitalAlert:
        return 'Vital Alert';
      case SuggestionType.drugInteraction:
        return 'Drug Interaction';
      case SuggestionType.duplicateMedicine:
        return 'Duplicate Medicine';
      case SuggestionType.alternative:
        return 'Alternative';
      case SuggestionType.appointmentReminder:
        return 'Appointment';
      case SuggestionType.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case SuggestionType.followUp:
        return Icons.calendar_today;
      case SuggestionType.reminder:
        return Icons.alarm;
      case SuggestionType.payment:
        return Icons.payment;
      case SuggestionType.medication:
        return Icons.medication;
      case SuggestionType.healthTip:
        return Icons.lightbulb;
      case SuggestionType.labTest:
        return Icons.science;
      case SuggestionType.referral:
        return Icons.person_add;
      case SuggestionType.vitalAlert:
        return Icons.monitor_heart;
      case SuggestionType.drugInteraction:
        return Icons.warning;
      case SuggestionType.duplicateMedicine:
        return Icons.copy;
      case SuggestionType.alternative:
        return Icons.swap_horiz;
      case SuggestionType.appointmentReminder:
        return Icons.event;
      case SuggestionType.general:
        return Icons.tips_and_updates;
    }
  }

  Color get color {
    switch (this) {
      case SuggestionType.followUp:
        return Colors.blue;
      case SuggestionType.reminder:
        return Colors.orange;
      case SuggestionType.payment:
        return Colors.green;
      case SuggestionType.medication:
        return Colors.purple;
      case SuggestionType.healthTip:
        return Colors.teal;
      case SuggestionType.labTest:
        return Colors.indigo;
      case SuggestionType.referral:
        return Colors.pink;
      case SuggestionType.vitalAlert:
        return Colors.red;
      case SuggestionType.drugInteraction:
        return Colors.red.shade700;
      case SuggestionType.duplicateMedicine:
        return Colors.amber.shade700;
      case SuggestionType.alternative:
        return Colors.cyan;
      case SuggestionType.appointmentReminder:
        return Colors.blueGrey;
      case SuggestionType.general:
        return Colors.grey;
    }
  }

  static SuggestionType fromString(String? value) {
    if (value == null) return SuggestionType.general;
    return SuggestionType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SuggestionType.general,
    );
  }
}

/// Suggestion priority
enum SuggestionPriority {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case SuggestionPriority.low:
        return 'Low';
      case SuggestionPriority.medium:
        return 'Medium';
      case SuggestionPriority.high:
        return 'High';
      case SuggestionPriority.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case SuggestionPriority.low:
        return Colors.grey;
      case SuggestionPriority.medium:
        return Colors.blue;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.critical:
        return Colors.red;
    }
  }

  int get sortOrder {
    switch (this) {
      case SuggestionPriority.critical:
        return 0;
      case SuggestionPriority.high:
        return 1;
      case SuggestionPriority.medium:
        return 2;
      case SuggestionPriority.low:
        return 3;
    }
  }

  static SuggestionPriority fromString(String? value) {
    if (value == null) return SuggestionPriority.medium;
    return SuggestionPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SuggestionPriority.medium,
    );
  }
}

/// Suggestion action
class SuggestionAction {
  /// Action type
  final String type;
  
  /// Action parameters
  final Map<String, dynamic> params;

  SuggestionAction({
    required this.type,
    this.params = const {},
  });

  factory SuggestionAction.fromJson(Map<String, dynamic> json) {
    return SuggestionAction(
      type: json['type'] ?? 'unknown',
      params: json['params'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'params': params,
    };
  }
}

/// Container for multiple suggestions
class AISuggestionGroup {
  final String title;
  final List<AISuggestion> suggestions;
  final DateTime? lastUpdated;

  AISuggestionGroup({
    required this.title,
    required this.suggestions,
    this.lastUpdated,
  });

  /// Get non-dismissed suggestions
  List<AISuggestion> get activeSuggestions => 
      suggestions.where((s) => !s.isDismissed).toList();

  /// Check if has any active suggestions
  bool get hasActiveSuggestions => activeSuggestions.isNotEmpty;

  /// Get suggestions by priority
  List<AISuggestion> get sortedSuggestions {
    final active = activeSuggestions;
    active.sort((a, b) => a.priority.sortOrder.compareTo(b.priority.sortOrder));
    return active;
  }
}
