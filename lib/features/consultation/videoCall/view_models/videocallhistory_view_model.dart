import 'package:flutter/material.dart';
import 'package:doctro/models/video_call_history_show_model.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/base_model.dart';
import 'package:doctro/network/network_api.dart';
import 'package:doctro/network/server_error.dart';

class VideoCallHistoryViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<Data> callHistory = [];
  bool hasError = false;
  String errorMessage = "";

  Future<void> fetchVideoCallHistory(BuildContext context) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      callHistory.clear();
      final response = await RestClient(await RetroApi().dioData(context))
          .videoCallHistoryShowRequest();
      if (response.success == true) {
        callHistory.addAll(response.data!.reversed);
      } else {
        hasError = true;
        errorMessage = "Failed to load call history.";
      }
    } catch (error) {
      hasError = true;
      errorMessage = ServerError.withError(error: error).getErrorMessage();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
