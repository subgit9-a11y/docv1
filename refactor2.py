import os

file_path = 'c:/Users/SUBHASH/Desktop/ayureze-doctor-app-v1/lib/features/appointment/appointment_history.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
if "import 'package:provider/provider.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';\nimport 'package:doctro/features/appointment/view_models/appointment_history_view_model.dart';")

# 2. Lists and future
content = content.replace("Future? appointment;", "")
content = content.replace("List<PastAppointment> pastAppointmentReq = [];", "")
content = content.replace("List<UpcomingAppointment> upcomingAppointmentReq = [];", "")
content = content.replace("List<UpcomingAppointment> _userDetails = [];", "")
content = content.replace("List<PastAppointment> _pastData = [];", "")

# 3. initState
init_state_replacement = '''
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AppointmentHistoryViewModel>(context, listen: false).fetchAppointmentHistory(context);
      });
      dName = SharedPreferenceHelper.getString(Preferences.name);
'''
if "appointment = appointmentHistoryScreen();" in content:
    content = content.replace('''appointment = appointmentHistoryScreen();
      dName = SharedPreferenceHelper.getString(Preferences.name);''', init_state_replacement)

# 4. upcomingAppointmentReq -> viewModel.upcomingAppointments
content = content.replace('upcomingAppointmentReq', 'viewModel.upcomingAppointments')
# 5. pastAppointmentReq -> viewModel.pastAppointments
content = content.replace('pastAppointmentReq', 'viewModel.pastAppointments')

# 6. onRefresh
content = content.replace('onRefresh: appointmentHistoryScreen,', 'onRefresh: () async { await Provider.of<AppointmentHistoryViewModel>(context, listen: false).fetchAppointmentHistory(context); },')

# 7. FutureBuilder to Consumer
old_fb = '''child: FutureBuilder(
                      future: appointment,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {'''
new_fb = '''child: Consumer<AppointmentHistoryViewModel>(
                      builder: (context, viewModel, child) {
                        if (!viewModel.isLoading) {'''
content = content.replace(old_fb, new_fb)

# 8. onSearchTextChanged
old_search = '''onSearchTextChanged(String text) async {
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
  }'''
new_search = '''onSearchTextChanged(String text) async {
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
  }'''
content = content.replace(old_search, new_search)

# 9. appointmentHistoryScreen()
# We can just split on Future<BaseModel<AppointmentHistory>> appointmentHistoryScreen() async {
# and remove the body until the first method after it or just find its end.
parts = content.split('Future<BaseModel<AppointmentHistory>> appointmentHistoryScreen() async {')
if len(parts) == 2:
    after = parts[1]
    # find the end of this method, it returns a BaseModel
    end_str = 'return BaseModel()..data = response;\n  }'
    end_idx = after.find(end_str)
    if end_idx != -1:
        content = parts[0] + after[end_idx + len(end_str):]
    else:
        # alternate end
        end_str2 = 'return BaseModel()..data = response;\n  }\n'
        end_idx2 = after.find(end_str2)
        if end_idx2 != -1:
            content = parts[0] + after[end_idx2 + len(end_str2):]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("done")
