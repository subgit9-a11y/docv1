import 'package:flutter/material.dart';
import 'package:doctro/models/CancelAppointment.dart';
import 'package:doctro/services/astra_api_service.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/widgets/osler_toast.dart';

class CancelAppointmentViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? dName;
  String? dFullImage;
  String? phone;
  int? subscription;

  final List<AppointmentCancel> _cancelAppointmentReq = [];
  List<AppointmentCancel> get cancelAppointmentReq => _cancelAppointmentReq;

  final List<AppointmentCancel> _searchResult = [];
  List<AppointmentCancel> get searchResult => _searchResult;

  final List<AppointmentCancel> _userCancel = [];

  TextEditingController searchController = TextEditingController();

  CancelAppointmentViewModel(BuildContext context) {
    _init(context);
    searchController.addListener(_onSearchTextChanged);
  }

  void _init(BuildContext context) async {
    dName = SharedPreferenceHelper.getString(Preferences.name);
    dFullImage = SharedPreferenceHelper.getString(Preferences.image);
    phone = SharedPreferenceHelper.getString(Preferences.phone_no);
    subscription =
        SharedPreferenceHelper.getInt(Preferences.subscription_status);
    await cancelAppointmentRequest(context);
  }

  // The legacy `cancel_appointment` REST endpoint is permanently dead (404).
  // The real source is AstraApiService.getMyAppointments() (the same one
  // the dashboard uses), filtered to appointments that are still
  // cancellable: not already cancelled, and today or in the future.
  Future<void> cancelAppointmentRequest(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cancelAppointmentReq.clear();
      _userCancel.clear();

      final result = await AstraApiService().getMyAppointments();
      final appointments = (result['appointments'] as List<dynamic>?) ?? [];
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      for (final raw in appointments) {
        final map = raw as Map<String, dynamic>;
        if (map['status'] == 'cancelled') continue;
        final rawDate = map['appointment_date'] as String?;
        if (rawDate == null) continue;
        DateTime parsed;
        try {
          parsed = DateTime.parse(rawDate).toLocal();
        } catch (_) {
          continue;
        }
        final day = DateTime(parsed.year, parsed.month, parsed.day);
        if (day.isBefore(todayStart)) continue;

        final type = map['consultation_type'] as String?;
        _cancelAppointmentReq.add(AppointmentCancel(
          consultationId: map['consultation_id']?.toString(),
          date: parsed.toIso8601String(),
          time: _formatTime(parsed),
          patientAddress: (type == null || type.isEmpty)
              ? null
              : '${type[0].toUpperCase()}${type.substring(1)} Consultation',
        ));
      }
      _userCancel.addAll(_cancelAppointmentReq);
    } catch (error) {
      // Handle error if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<bool> cancelAppointment(
      BuildContext context, String consultationId) async {
    try {
      await AstraApiService().cancelAppointment(consultationId);
      _cancelAppointmentReq
          .removeWhere((a) => a.consultationId == consultationId);
      _userCancel.removeWhere((a) => a.consultationId == consultationId);
      notifyListeners();
      if (context.mounted) {
        OslerToast.success(context, "Appointment cancelled");
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        OslerToast.error(context, "Failed to cancel appointment: $error");
      }
      return false;
    }
  }

  void _onSearchTextChanged() {
    String text = searchController.text;
    _searchResult.clear();
    if (text.isEmpty) {
      notifyListeners();
      return;
    }
    for (var cancelAppointmentData in _cancelAppointmentReq) {
      if ((cancelAppointmentData.patientName ?? "")
          .toLowerCase()
          .contains(text.toLowerCase())) {
        _searchResult.add(cancelAppointmentData);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
