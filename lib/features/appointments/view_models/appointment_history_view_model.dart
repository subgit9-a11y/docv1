import 'package:doctro/models/appointment_history.dart';
import 'package:doctro/services/astra_api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentHistoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<AppointmentHistoryItem> _pastAppointments = [];
  List<AppointmentHistoryItem> get pastAppointments => _pastAppointments;

  List<AppointmentHistoryItem> _upcomingAppointments = [];
  List<AppointmentHistoryItem> get upcomingAppointments =>
      _upcomingAppointments;

  List<AppointmentHistoryItem> get appointments =>
      [..._upcomingAppointments, ..._pastAppointments];

  Future<void> fetchAppointments(BuildContext context) =>
      fetchAppointmentHistory(context);

  // The legacy `appointment_history` REST endpoint is permanently dead
  // (404). The real source is AstraApiService.getMyAppointments() (the
  // same one the dashboard uses), split into past/upcoming by date here
  // since the real endpoint returns one flat, unsorted list.
  Future<void> fetchAppointmentHistory(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AstraApiService().getMyAppointments();
      final appointments = (result['appointments'] as List<dynamic>?) ?? [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final past = <(DateTime, AppointmentHistoryItem)>[];
      final upcoming = <(DateTime, AppointmentHistoryItem)>[];

      for (final raw in appointments) {
        final map = raw as Map<String, dynamic>;
        final rawDate = map['appointment_date'] as String?;
        if (rawDate == null) continue;
        DateTime parsed;
        try {
          parsed = DateTime.parse(rawDate).toLocal();
        } catch (_) {
          continue;
        }

        final item = AppointmentHistoryItem(
          consultationId: map['consultation_id']?.toString(),
          status: map['status']?.toString(),
          appointmentDate: DateFormat('dd MMM yyyy').format(parsed),
          slotTime: DateFormat('h:mm a').format(parsed),
          appointmentType: map['consultation_type']?.toString(),
        );

        final day = DateTime(parsed.year, parsed.month, parsed.day);
        if (day.isBefore(today)) {
          past.add((parsed, item));
        } else {
          upcoming.add((parsed, item));
        }
      }

      past.sort((a, b) => b.$1.compareTo(a.$1));
      upcoming.sort((a, b) => a.$1.compareTo(b.$1));

      _pastAppointments = past.map((e) => e.$2).toList();
      _upcomingAppointments = upcoming.map((e) => e.$2).toList();
    } catch (error) {
      if (_pastAppointments.isEmpty && _upcomingAppointments.isEmpty) {
        _errorMessage = "Failed to load appointment history. Please try again.";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
