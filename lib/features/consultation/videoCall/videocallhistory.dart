import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/core/constants/app_string.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/core/constants/date_util.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/videocallhistory_view_model.dart';

class VideoCallHistory extends StatefulWidget {
  const VideoCallHistory({super.key});

  @override
  _VideoCallHistoryState createState() => _VideoCallHistoryState();
}

class _VideoCallHistoryState extends State<VideoCallHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoCallHistoryViewModel>(context, listen: false)
          .fetchVideoCallHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            size: 20,
            color: AyurezeTheme.textSecondary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          getTranslated(context, AppString.drawer_callHistory).toString(),
          style: TextStyle(
              fontSize: 18,
              color: AyurezeTheme.textSecondary,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<VideoCallHistoryViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.fetchVideoCallHistory(context),
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.hasError
                    ? Center(child: Text(viewModel.errorMessage))
                    : viewModel.callHistory.isNotEmpty
                        ? ListView.builder(
                            itemCount: viewModel.callHistory.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              final callData = viewModel.callHistory[index];
                              final now = Duration(
                                  seconds: int.parse(callData.duration ?? '0'));
                              String printDuration(Duration duration) {
                                String twoDigits(int n) =>
                                    n.toString().padLeft(2, "0");
                                String twoDigitMinutes =
                                    twoDigits(duration.inMinutes.remainder(60));
                                String twoDigitSeconds =
                                    twoDigits(duration.inSeconds.remainder(60));
                                return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
                              }

                              String duration = "";
                              String str = printDuration(now);
                              List<String> parts = str.split(":");
                              String hourPart = parts[0].trim();
                              String minuteType = parts[1].trim();
                              String secondType = parts[2].trim();

                              if (hourPart != "00" && minuteType != "00") {
                                duration =
                                    "${hourPart}h ${minuteType}m ${secondType}s ";
                              } else if (hourPart == "00" &&
                                  minuteType != "00") {
                                duration = "${minuteType}m ${secondType}s ";
                              } else {
                                duration = "${secondType}s ";
                              }

                              return Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: width * 0.01,
                                        vertical: width * 0.02),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width * 0.15,
                                          alignment:
                                              AlignmentDirectional.center,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: width * 0.01,
                                              vertical: width * 0.02),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: width * 0.15,
                                                height: height * 0.065,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    alignment: Alignment.center,
                                                    imageUrl: callData
                                                            .user?.fullImage ??
                                                        "",
                                                    fit: BoxFit.fitHeight,
                                                    placeholder:
                                                        (context, url) =>
                                                            Transform.scale(
                                                      scale: 0.4,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: AyurezeTheme
                                                            .actionButtonPrimary,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.asset(
                                                          "assets/images/no_image.jpg"),
                                                    ),
                                                    width: width * 0.15,
                                                    height: height * 0.065,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.8,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 0,
                                                      vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        callData.user?.name ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize:
                                                                width * 0.04,
                                                            color: AyurezeTheme
                                                                .textSecondary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        (callData.startTime ??
                                                                "")
                                                            .toLowerCase(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.03,
                                                          color: AyurezeTheme
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topStart,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        duration,
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          color: AyurezeTheme
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                      Text(
                                                        DateUtil().formattedDate(
                                                            DateTime.parse(
                                                                callData.date ??
                                                                    "")),
                                                        style: TextStyle(
                                                          fontSize:
                                                              width * 0.035,
                                                          color: AyurezeTheme
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Divider(
                                            height: height * 0.005,
                                            thickness: width * 0.005,
                                            color: AyurezeTheme.border,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Center(
                            child: Image.asset("assets/images/no-data.png"),
                          ),
          );
        },
      ),
    );
  }
}
