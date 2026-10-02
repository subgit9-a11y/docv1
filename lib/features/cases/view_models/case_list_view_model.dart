import 'package:doctro/services/astra_api_service.dart';
import 'package:flutter/material.dart';

/// Lists the companion cases (created via the patient's Astra consultation
/// flow) assigned to the signed-in doctor.
///
/// The doctor_id needed for GET /api/companion/case/by-doctor/{doctor_id}
/// is the Astra-format id (e.g. "DOC-25"), not the Laravel numeric id
/// cached in Preferences.doctorId - so this always resolves it fresh via
/// GET /api/v1/auth/user rather than trusting a locally stored value.
class CaseListViewModel extends ChangeNotifier {
  final AstraApiService _astraApiService = AstraApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> _cases = [];
  List<Map<String, dynamic>> get cases => _cases;

  Future<void> fetchCases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userInfo = await _astraApiService.getUserInfo();
      final doctorId = userInfo['doctor_id'] as String?;
      if (doctorId == null || doctorId.isEmpty) {
        throw Exception('No doctor_id on this account');
      }

      final result = await _astraApiService.getCasesByDoctor(doctorId);
      _cases = result.cast<Map<String, dynamic>>();
    } catch (error) {
      _errorMessage = 'Could not load cases. Pull down to try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
