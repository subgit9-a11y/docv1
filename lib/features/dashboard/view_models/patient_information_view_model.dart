import 'package:flutter/material.dart';
import 'package:doctro/models/DoctorStatusChange.dart';
import 'package:doctro/network/base_model.dart';
import 'package:doctro/services/astra_api_service.dart';
import 'package:doctro/services/astra_service.dart';
import 'package:doctro/widgets/osler_toast.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class PatientInformationViewModel extends ChangeNotifier {
  final String? consultationId;
  final BuildContext context;

  PatientInformationViewModel(this.consultationId, this.context) {
    init();
  }

  // Astra Fill Data (Health intake from patient's app)
  final AstraService _astraService = AstraService();
  Map<String, dynamic>? astraFillData;
  bool isLoadingAstraFill = false;

  //Pdf Pass Data
  String? valueDays;
  bool? alertValueFirst = false;
  bool? alertValueSecond = false;
  bool? alertValueThird = false;

  //Set List for Report Image
  List<String> reportImages = [];

  //set hide show approve and cancel button
  bool hideButton = true;

  //Show Signal Appointment Details
  int? userId;
  int? age;
  double? amount;
  String? phoneNo = "";
  String? name = "";
  String? appointmentId = "";
  String? patientAddress = "";
  String date = "";
  String? illness = "";
  String? note = "";
  String? drugEffect = "";
  String? time = "";
  String? fullImage = "";
  String? appointment = "";
  String? appointmentType = "";
  String? appointmentStatus = "";
  String? pdf = "";
  int isInsured = 0;
  String policyInsurerName = "";
  String policyNumber = "";
  String? astraCaseId;

  bool isLoading = true;

  void init() {
    appointmentDetails();
  }

  Future<void> loadAstraFillData(
      {String? patientId, String? searchPhone}) async {
    final targetId = patientId ?? userId?.toString();
    final targetPhone = searchPhone ?? phoneNo;

    if (targetId == null && targetPhone == null) return;

    isLoadingAstraFill = true;
    notifyListeners();

    try {
      Map<String, dynamic> data = {};

      // 1. Try loading by ID if available
      if (targetId != null) {
        data = await _astraService.getLatestAstraFill(targetId);
      }

      // 2. Fallback: If no data or loading by ID failed, try searching by phone in Astra
      if ((data.isEmpty) && targetPhone != null && targetPhone.isNotEmpty) {
        // Clean phone number (remove +, spaces, etc. for search)
        String cleanPhone = targetPhone.replaceAll(RegExp(r'\D'), '');
        final searchResults = await _astraService.searchPatients(cleanPhone);

        if (searchResults.isNotEmpty) {
          // Found matching patient in Astra! Use their Astra ID
          final astraPatient = searchResults[0];
          final astraId =
              astraPatient['id']?.toString() ?? astraPatient['uid']?.toString();
          if (astraId != null) {
            data = await _astraService.getLatestAstraFill(astraId);
          }
        }
      }

      astraFillData = data;
      isLoadingAstraFill = false;
      notifyListeners();
    } catch (e) {
      isLoadingAstraFill = false;
      notifyListeners();
    }
  }

  // The legacy `status_change` REST endpoint (Apis.status_change) is
  // permanently dead (404), and the real backend has no doctor-facing
  // approve/complete route yet. Cancel does have a real route
  // (appointments/{consultation_id}/cancel) and this view model now
  // carries the real consultation_id, so that one is wired for real;
  // approve/complete still just surface an honest error instead of
  // looking like a dead button.
  Future<BaseModel<DoctorStatusChange>> statusChangeRequest(
      String status) async {
    if (status == 'cancel' && consultationId != null) {
      try {
        await AstraApiService().cancelAppointment(consultationId!);
        appointmentStatus = 'cancel';
        hideButton = false;
        notifyListeners();
        if (context.mounted) {
          OslerToast.success(context, "Appointment cancelled");
        }
      } catch (error) {
        if (context.mounted) {
          OslerToast.error(context, "Failed to cancel appointment: $error");
        }
      }
      return BaseModel();
    }

    if (context.mounted) {
      OslerToast.error(
          context, "This action isn't available yet. Please try again later.");
    }
    // Nothing reads this BaseModel's exception (every caller is
    // fire-and-forget), so there is no need to populate one.
    return BaseModel();
  }

  // The legacy `appointment_details/{id}` REST endpoint (Apis.
  // appointment_details) is permanently dead (404), and the real backend
  // has no single-appointment-detail route at all - only the flat list at
  // GET /api/v1/appointments/my, which has no patient name/phone/
  // illness/notes/images/insurance/PDF. This finds the matching entry in
  // that list by consultation_id and populates only the fields it
  // actually has; the rest are left at their default empty values until
  // the backend adds a real detail endpoint.
  Future<void> appointmentDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      if (consultationId == null) return;

      final result = await AstraApiService().getMyAppointments();
      final appointments = (result['appointments'] as List<dynamic>?) ?? [];
      Map<String, dynamic>? match;
      for (final raw in appointments) {
        final map = raw as Map<String, dynamic>;
        if (map['consultation_id']?.toString() == consultationId) {
          match = map;
          break;
        }
      }
      if (match == null) return;

      appointmentId = consultationId;
      final rawDate = match['appointment_date'] as String?;
      if (rawDate != null) {
        try {
          final parsed = DateTime.parse(rawDate).toLocal();
          date = DateUtil().formattedDate(parsed);
          time = DateFormat('h:mm a').format(parsed);
        } catch (_) {
          // Leave date/time at their defaults if the server sends an
          // unparsable value.
        }
      }
      appointmentType = match['consultation_type'] as String?;
      appointmentStatus = match['status'] as String?;
      final patientId = match['patient_id']?.toString();
      userId = int.tryParse(patientId ?? '');

      appointmentStatus == 'Approve' ? hideButton = false : hideButton = true;
      appointmentStatus == 'pending' ? hideButton = true : hideButton = false;

      // After loading appointment details, refresh Astra Fill data with resolved IDs
      if (patientId != null) {
        loadAstraFillData(patientId: patientId, searchPhone: phoneNo);
      }
    } catch (_) {
      // Leave fields at their defaults if the fetch fails.
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
