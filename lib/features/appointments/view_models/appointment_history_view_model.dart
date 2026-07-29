import 'dart:convert';
import 'package:doctro/models/appointment_history.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/network_api.dart';
import 'package:doctro/network/server_error.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppointmentHistoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PastAppointment> _pastAppointments = [];
  List<PastAppointment> get pastAppointments => _pastAppointments;

  List<UpcomingAppointment> _upcomingAppointments = [];
  List<UpcomingAppointment> get upcomingAppointments => _upcomingAppointments;

  List<dynamic> get appointments =>
      [..._upcomingAppointments, ..._pastAppointments];

  Future<void> fetchAppointments(BuildContext context) =>
      fetchAppointmentHistory(context);

  Future<void> fetchAppointmentHistory(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final box = Hive.box('offlineCache');

      // Load from cache first for fast offline capability
      final cachedPast = box.get('pastAppointments');
      final cachedUpcoming = box.get('upcomingAppointments');

      if (cachedPast != null) {
        final parsed = jsonDecode(cachedPast) as List;
        _pastAppointments =
            parsed.map((e) => PastAppointment.fromJson(e)).toList();
      }

      if (cachedUpcoming != null) {
        final parsed = jsonDecode(cachedUpcoming) as List;
        _upcomingAppointments =
            parsed.map((e) => UpcomingAppointment.fromJson(e)).toList();
      }

      // If we have cached data, update the UI immediately
      if (_pastAppointments.isNotEmpty || _upcomingAppointments.isNotEmpty) {
        notifyListeners();
      }

      final dio = await RetroApi().dioData(context);
      final response = await RestClient(dio).appointmentHistoryScreenRequest();

      _pastAppointments = response.data?.pastAppointment ?? [];
      _upcomingAppointments = response.data?.upcomingAppointment ?? [];

      // Save to cache
      box.put('pastAppointments',
          jsonEncode(_pastAppointments.map((e) => e.toJson()).toList()));
      box.put('upcomingAppointments',
          jsonEncode(_upcomingAppointments.map((e) => e.toJson()).toList()));
    } catch (error) {
      // If we failed and have no cache, show error
      if (_pastAppointments.isEmpty && _upcomingAppointments.isEmpty) {
        _errorMessage = ServerError.withError(error: error).getErrorMessage();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
