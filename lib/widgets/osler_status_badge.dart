import 'package:flutter/material.dart';
import 'package:doctro/widgets/osler_tag.dart';
import 'package:hugeicons/hugeicons.dart';

enum AppointmentStatus { pending, approved, complete, cancel, waiting }

class OslerStatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final String? customLabel;

  const OslerStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    return OslerTag(
      label: customLabel ?? _getLabel(),
      style: _getStyle(),
      icon: _getIcon(),
    );
  }

  String _getLabel() {
    switch (status) {
      case AppointmentStatus.pending:
        return "Pending";
      case AppointmentStatus.approved:
        return "Approved";
      case AppointmentStatus.complete:
        return "Completed";
      case AppointmentStatus.cancel:
        return "Cancelled";
      case AppointmentStatus.waiting:
        return "Waiting";
    }
  }

  OslerTagStyle _getStyle() {
    switch (status) {
      case AppointmentStatus.pending:
        return OslerTagStyle.warning;
      case AppointmentStatus.approved:
        return OslerTagStyle.info;
      case AppointmentStatus.complete:
        return OslerTagStyle.success;
      case AppointmentStatus.cancel:
        return OslerTagStyle.danger;
      case AppointmentStatus.waiting:
        return OslerTagStyle.info;
    }
  }

  List<List<dynamic>> _getIcon() {
    switch (status) {
      case AppointmentStatus.pending:
        return HugeIcons.strokeRoundedClock01;
      case AppointmentStatus.approved:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case AppointmentStatus.complete:
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case AppointmentStatus.cancel:
        return HugeIcons.strokeRoundedCancelCircle;
      case AppointmentStatus.waiting:
        return HugeIcons.strokeRoundedHourglass;
    }
  }

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'approved':
      case 'approve':
        return AppointmentStatus.approved;
      case 'complete':
      case 'completed':
        return AppointmentStatus.complete;
      case 'cancel':
      case 'cancelled':
        return AppointmentStatus.cancel;
      case 'waiting':
        return AppointmentStatus.waiting;
      default:
        return AppointmentStatus.pending;
    }
  }
}
