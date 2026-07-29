import 'dart:io';

void main() {
  final file = File(
      'c:/Users/SUBHASH/Desktop/ayureze-doctor-app-v1/lib/features/appointment/appointment_history.dart');
  var content = file.readAsStringSync();

  if (!content.contains("import 'package:provider/provider.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\nimport 'package:doctro/features/appointment/view_models/appointment_history_view_model.dart';");
  }

  content = content.replaceAll("Future? appointment;", "");
  content =
      content.replaceAll("List<PastAppointment> pastAppointmentReq = [];", "");
  content = content.replaceAll(
      "List<UpcomingAppointment> upcomingAppointmentReq = [];", "");
  content =
      content.replaceAll("List<UpcomingAppointment> _userDetails = [];", "");
  content = content.replaceAll("List<PastAppointment> _pastData = [];", "");

  final initStateOld = '''appointment = appointmentHistoryScreen();
      dName = SharedPreferenceHelper.getString(Preferences.name);''';
  final initStateNew = '''WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AppointmentHistoryViewModel>(context, listen: false).fetchAppointmentHistory(context);
      });
      dName = SharedPreferenceHelper.getString(Preferences.name);''';

  if (content.contains('appointment = appointmentHistoryScreen();')) {
    content = content.replaceFirst(initStateOld, initStateNew);
  }

  content = content.replaceAll(
      'upcomingAppointmentReq', 'viewModel.upcomingAppointments');
  content =
      content.replaceAll('pastAppointmentReq', 'viewModel.pastAppointments');

  content = content.replaceAll('onRefresh: appointmentHistoryScreen,',
      'onRefresh: () async { await Provider.of<AppointmentHistoryViewModel>(context, listen: false).fetchAppointmentHistory(context); },');

  final oldFb = '''child: FutureBuilder(
                      future: appointment,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {''';
  final newFb = '''child: Consumer<AppointmentHistoryViewModel>(
                      builder: (context, viewModel, child) {
                        if (!viewModel.isLoading) {''';
  content = content.replaceFirst(oldFb, newFb);

  final oldSearch = '''onSearchTextChanged(String text) async {
    _searchResult.clear();
    _pastSearch.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    isShow == null
        ? _userDetails.forEach((upcomingAppointment) {
            if ((upcomingAppointment.patientName ?? "")
                .toLowerCase()
                .contains(text.toLowerCase()))
              _searchResult.add(upcomingAppointment);
          })
        : _pastData.forEach((pastAppointment) {
            if ((pastAppointment.patientName ?? "")
                .toLowerCase()
                .contains(text.toLowerCase())) _pastSearch.add(pastAppointment);
          });

    setState(() {});
  }''';
  final newSearch = '''onSearchTextChanged(String text) async {
    _searchResult.clear();
    _pastSearch.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    final viewModel = Provider.of<AppointmentHistoryViewModel>(context, listen: false);

    isShow == null
        ? viewModel.upcomingAppointments.forEach((upcomingAppointment) {
            if ((upcomingAppointment.patientName ?? "")
                .toLowerCase()
                .contains(text.toLowerCase()))
              _searchResult.add(upcomingAppointment);
          })
        : viewModel.pastAppointments.forEach((pastAppointment) {
            if ((pastAppointment.patientName ?? "")
                .toLowerCase()
                .contains(text.toLowerCase())) _pastSearch.add(pastAppointment);
          });

    setState(() {});
  }''';
  content = content.replaceFirst(oldSearch, newSearch);

  final parts = content.split(
      'Future<BaseModel<AppointmentHistory>> appointmentHistoryScreen() async {');
  if (parts.length == 2) {
    final after = parts[1];
    final endStr = 'return BaseModel()..data = response;\n  }';
    final endIdx = after.indexOf(endStr);
    if (endIdx != -1) {
      content = parts[0] + after.substring(endIdx + endStr.length);
    }
  }

  file.writeAsStringSync(content);
}
