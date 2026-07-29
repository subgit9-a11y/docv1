
import 'package:doctro/core/constants/app_string.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:doctro/models/CancelAppointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doctro/widgets/modern_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:doctro/features/appointments/view_models/cancel_appointment_view_model.dart';

class CancelAppointmentScreen extends StatefulWidget {
  const CancelAppointmentScreen({super.key});

  @override
  _CancelAppointmentScreen createState() => _CancelAppointmentScreen();
}

class _CancelAppointmentScreen extends State<CancelAppointmentScreen> {
  //Set Height/Width Using MediaQuery
  late double width;
  late double height;

  //Set Open Drawer
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider<CancelAppointmentViewModel>(
      create: (_) => CancelAppointmentViewModel(context),
      child: Consumer<CancelAppointmentViewModel>(
          builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pushNamedAndRemoveUntil(
                context, 'loginHome', (route) => false);
          },
          child: RefreshIndicator(
            onRefresh: () => viewModel.cancelAppointmentRequest(context),
            child: Scaffold(
              backgroundColor: AyurezeTheme.canvas,
              key: _scaffoldKey,
              drawer: const ModernDrawer(),
              appBar: PreferredSize(
                  preferredSize: Size(20, 150),
                  child: SafeArea(
                      top: true,
                      child: Column(children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: width * 0.06,
                                  right: width * 0.06,
                                  top: height * 0.01),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          getTranslated(
                                                  context,
                                                  AppString
                                                      .cancel_appointment_heading)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.05,
                                              color: AyurezeTheme.textPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(),
                                    child: IconButton(
                                      onPressed: () {
                                        _scaffoldKey.currentState!.openDrawer();
                                      },
                                      icon: SvgPicture.asset(
                                        "assets/icons/dMenuBar.svg",
                                        height: 16.0,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01),
                          padding: EdgeInsets.all(10),
                          child: Card(
                            color: AyurezeTheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                                alignment: AlignmentDirectional.center,
                                margin: EdgeInsets.only(
                                    left: width * 0.05, right: width * 0.05),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      // height: height * 0.06,
                                      width: width * 0.7,
                                      child: TextField(
                                        controller: viewModel.searchController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: getTranslated(
                                                  context,
                                                  AppString
                                                      .search_cancel_appointment)
                                              .toString(),
                                          hintStyle: TextStyle(
                                            fontSize: width * 0.045,
                                            color: AyurezeTheme.textSecondary
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Container(
                                      child: SvgPicture.asset(
                                        'assets/icons/dSearch.svg',
                                        height: 20,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ]))),
              body: viewModel.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Column(
                            children: [
                              viewModel.cancelAppointmentReq.isEmpty
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: height * 0.2),
                                      child: Container(
                                        child: Image.asset(
                                            "assets/images/no-data.png"),
                                      ),
                                    )
                                  : Container(
                                      color: AyurezeTheme.surfaceMuted,
                                      width: width * 1.0,
                                      padding: EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: width * 0.04),
                                            child: Text(
                                              getTranslated(
                                                      context,
                                                      AppString
                                                          .cancel_appointment_heading)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      AyurezeTheme.textPrimary),
                                            ),
                                          ),
                                          Text(
                                            "${getTranslated(
                                                        context,
                                                        AppString
                                                            .cancel_appointment_length)} ${viewModel.cancelAppointmentReq.length} ",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: AyurezeTheme.forestDeep),
                                          ),
                                        ],
                                      ),
                                    ),
                              viewModel.searchController.text.isNotEmpty
                                  ? viewModel.searchResult.isNotEmpty
                                      ? ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              viewModel.searchResult.length,
                                          itemBuilder: (context, i) {
                                            return _buildAppointmentCard(
                                                viewModel.searchResult[i]);
                                          },
                                        )
                                      : SizedBox(
                                          height: height / 1.5,
                                          child: Center(
                                              child: Container(
                                            margin: EdgeInsets.only(
                                                top: height * 0.02),
                                            child: Text(getTranslated(context,
                                                    AppString.result_not_found)
                                                .toString()),
                                          )))
                                  : ListView.builder(
                                      itemCount:
                                          viewModel.cancelAppointmentReq.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      reverse: true,
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return _buildAppointmentCard(viewModel
                                            .cancelAppointmentReq[index]);
                                      }),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAppointmentCard(AppointmentCancel appointment) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                Container(
                  margin:
                      EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                  child: Text(
                    DateUtil().formattedDate(DateTime.parse(appointment.date!)),
                    style:
                        TextStyle(fontSize: 14, color: AyurezeTheme.forestDeep),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: width * 0.06, right: width * 0.02),
                  child: Text(
                    appointment.time!,
                    style:
                        TextStyle(fontSize: 14, color: AyurezeTheme.forestDeep),
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                  margin:
                      EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                  height: 100,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(children: <Widget>[
                        Container(
                          child: ListTile(
                            isThreeLine: true,
                            leading: SizedBox(
                              height: 70,
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: NetworkImage(appointment
                                                .user!.fullImage!)))),
                              ),
                            ),
                            title: Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.only(
                                top: height * 0.01,
                              ),
                              child: Text(
                                appointment.patientName!,
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            trailing: Container(
                                child: Text(
                              SharedPreferenceHelper.getString(
                                      Preferences.currency_symbol) +
                                  appointment.amount.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AyurezeTheme.textSecondary),
                            )),
                            subtitle: Column(
                              children: <Widget>[
                                Container(
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      "${getTranslated(context,
                                                  AppString.home_age_data)}:${appointment.age}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AyurezeTheme.textSecondary),
                                    )),
                                Container(
                                  width: width * 0.6,
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    appointment.patientAddress!,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AyurezeTheme.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ]))),
            ),
          ],
        ),
      ],
    );
  }
}

class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}
