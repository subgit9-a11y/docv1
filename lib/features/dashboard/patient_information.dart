
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/core/constants/app_string.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/localization_constant.dart';

import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/astra_fill_display.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_loader.dart';
import 'package:doctro/widgets/osler_toast.dart';

import 'package:doctro/features/prescription/astra/prescription_screen.dart';
import 'package:doctro/features/consultation/chat/constants/firestore_constants.dart';
import 'package:doctro/features/consultation/chat/models/user_chat.dart';
import 'package:doctro/features/consultation/chat/pages/chat_page.dart';
import 'package:doctro/features/consultation/chat/providers/home_provider.dart';
import 'package:doctro/features/dashboard/view_models/patient_information_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class patientDetailsScreen extends StatelessWidget {
  final int? id;

  const patientDetailsScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientInformationViewModel(id, context),
      child: const _PatientDetailsScreenBody(),
    );
  }
}

class _PatientDetailsScreenBody extends StatefulWidget {
  const _PatientDetailsScreenBody();

  @override
  _PatientDetailsScreenBodyState createState() =>
      _PatientDetailsScreenBodyState();
}

List medicineData = [];
List<Map<String, dynamic>> listOfMedicine = [];
List<String> medicineReq = [];

class _PatientDetailsScreenBodyState extends State<_PatientDetailsScreenBody>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late HomeProvider homeProvider;
  Map<String, String> body = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    listOfMedicine.clear();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AyurezeTheme.canvas,
      appBar: AppBar(
        backgroundColor: AyurezeTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AyurezeTheme.forestDeep,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          getTranslated(context, AppString.patient_information).toString(),
          style: textTheme.titleLarge?.copyWith(
            color: AyurezeTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<PatientInformationViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: OslerLoader());
          }

          final name = vm.name;
          final age = vm.age;
          final amount = vm.amount;
          final date = vm.date;
          final phoneNo = vm.phoneNo;
          final patientAddress = vm.patientAddress;
          final illness = vm.illness;
          final note = vm.note;
          final appointmentId = vm.appointmentId;
          final drugEffect = vm.drugEffect;
          final time = vm.time;
          final fullImage = vm.fullImage;
          final appointment = vm.appointment;
          final appointmentType = vm.appointmentType;
          final appointmentStatus = vm.appointmentStatus;
          final userId = vm.userId;
          final reportImages = vm.reportImages;
          final isInsured = vm.isInsured;
          final policyInsurerName = vm.policyInsurerName;
          final policyNumber = vm.policyNumber;
          final hideButton = vm.hideButton;
          final astraFillData = vm.astraFillData;

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  Expanded(
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Column(
                                children: [
                                  // Profile Card
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: AyurezeTheme.panelDecoration(),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Call dialler button
                                            IconButton(
                                              onPressed: () => _showCallOptions(
                                                  context,
                                                  phoneNo,
                                                  appointmentType),
                                              icon: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AyurezeTheme.surfaceMuted,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AyurezeTheme.border,
                                                  ),
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/call_dialler.svg',
                                                  width: 20,
                                                  height: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    AyurezeTheme.forestDeep,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Patient Avatar
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AyurezeTheme
                                                      .healingGreen50,
                                                  width: 3,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: (fullImage != null &&
                                                        fullImage.isNotEmpty)
                                                    ? CachedNetworkImage(
                                                        imageUrl: fullImage,
                                                        fit: BoxFit.cover,
                                                        placeholder: (_, __) =>
                                                            Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: AyurezeTheme
                                                                .healingGreen50,
                                                          ),
                                                        ),
                                                        errorWidget:
                                                            (_, __, ___) =>
                                                                Image.asset(
                                                          "assets/images/no_image.jpg",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        "assets/images/no_image.jpg",
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),

                                            // Message dialler button
                                            IconButton(
                                              onPressed: () {
                                                if (body['peerId'] != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatPage(
                                                        peerId: body['peerId']
                                                            .toString(),
                                                        peerAvatar:
                                                            body['peerAvatar']
                                                                .toString(),
                                                        peerNickname:
                                                            body['nickName']
                                                                .toString(),
                                                        token: body['token']
                                                            .toString(),
                                                        isNavigate: 'chatHome',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  OslerToast.info(
                                                    context,
                                                    "Chat is loading...",
                                                  );
                                                }
                                              },
                                              icon: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AyurezeTheme.surfaceMuted,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AyurezeTheme.border,
                                                  ),
                                                ),
                                                child: SvgPicture.asset(
                                                  'assets/icons/message_dialler.svg',
                                                  width: 20,
                                                  height: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    AyurezeTheme.forestDeep,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Patient Name
                                        Text(
                                          name ?? '',
                                          style: textTheme.titleLarge?.copyWith(
                                            color: AyurezeTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),

                                        // Booking ID
                                        Text(
                                          "${getTranslated(context, AppString.information_booking_id)}: ${appointmentId ?? ''}",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: AyurezeTheme.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Appointment Overview Stats Panel
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    decoration:
                                        AyurezeTheme.mutedPanelDecoration(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildInfoColumn(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.information_amount,
                                          ).toString(),
                                          value:
                                              "${SharedPreferenceHelper.getString(Preferences.currency_symbol)}${amount ?? 0}",
                                        ),
                                        Container(
                                          width: 1,
                                          height: 36,
                                          color: AyurezeTheme.border,
                                        ),
                                        _buildInfoColumn(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.information_date,
                                          ).toString(),
                                          value: date,
                                        ),
                                        Container(
                                          width: 1,
                                          height: 36,
                                          color: AyurezeTheme.border,
                                        ),
                                        _buildInfoColumn(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.information_appointment,
                                          ).toString(),
                                          value:
                                              "${appointmentType ?? '-'} ${appointmentType != null ? 'appointment' : ''}\n${appointment ?? ''}",
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Firestore stream for Chat User details
                                  StreamBuilder<QuerySnapshot>(
                                    stream: homeProvider
                                        .getStreamFireStoreSpecificUser(
                                      FirestoreConstants.pathUserCollection,
                                      1,
                                      userId.toString(),
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          (snapshot.data?.docs.length ?? 0) >
                                              0) {
                                        UserChat userChat =
                                            UserChat.fromDocument(
                                          snapshot.data!.docs[0],
                                        );
                                        body = {
                                          "peerId": userChat.id,
                                          "nickName": userChat.nickname,
                                          "peerAvatar": userChat.photoUrl,
                                          "token": userChat.token
                                        };
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ];
                      },
                      body: Column(
                        children: [
                          // Tab Bar
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AyurezeTheme.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AyurezeTheme.border),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AyurezeTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AyurezeTheme.shadow,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: AyurezeTheme.textPrimary,
                              unselectedLabelColor: AyurezeTheme.textSecondary,
                              labelStyle: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              unselectedLabelStyle:
                                  textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                              tabs: [
                                Tab(
                                  text: getTranslated(
                                    context,
                                    AppString.patient_information,
                                  ).toString(),
                                ),
                                Tab(
                                  text: getTranslated(
                                    context,
                                    AppString.patient_illness,
                                  ).toString(),
                                ),
                                Tab(
                                  text: getTranslated(
                                    context,
                                    AppString.doctor_prescription,
                                  ).toString(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tab Content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Patient Information
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Status Buttons / Status Bar
                                      if (!hideButton)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration:
                                              AyurezeTheme.panelDecoration(),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                      context,
                                                      AppString
                                                          .information_appointment_status,
                                                    ).toString(),
                                                    style: textTheme.titleMedium
                                                        ?.copyWith(
                                                      color: AyurezeTheme
                                                          .textPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    appointmentStatus
                                                            ?.toUpperCase() ??
                                                        "",
                                                    style: textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: AyurezeTheme
                                                          .healingGreen50,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (appointmentStatus ==
                                                  'approve')
                                                OslerButton(
                                                  text: getTranslated(
                                                    context,
                                                    AppString
                                                        .information_complete_status,
                                                  ).toString(),
                                                  onPressed: () {
                                                    vm.statusChangeRequest(
                                                      "complete",
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: OslerButton(
                                                  text: getTranslated(
                                                    context,
                                                    AppString
                                                        .information_approve_status,
                                                  ).toString(),
                                                  onPressed: () {
                                                    vm.statusChangeRequest(
                                                      "approve",
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: OslerButton(
                                                  text: getTranslated(
                                                    context,
                                                    AppString
                                                        .information_cancel_status,
                                                  ).toString(),
                                                  customColor:
                                                      AyurezeTheme.remoteRed50,
                                                  onPressed: () {
                                                    vm.statusChangeRequest(
                                                      "cancel",
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // Details List Cards
                                      _buildDetailTile(
                                        context,
                                        label: getTranslated(
                                          context,
                                          AppString.information_patient_name,
                                        ).toString(),
                                        value: name ?? "-",
                                        icon: Icons.person_outline_rounded,
                                      ),
                                      _buildDetailTile(
                                        context,
                                        label: getTranslated(
                                          context,
                                          AppString.information_patient_age,
                                        ).toString(),
                                        value: age != null ? "$age yrs" : "-",
                                        icon: Icons.cake_outlined,
                                      ),
                                      _buildDetailTile(
                                        context,
                                        label: getTranslated(
                                          context,
                                          AppString
                                              .information_patient_phone_number,
                                        ).toString(),
                                        value: phoneNo ?? "-",
                                        icon: Icons.phone_outlined,
                                      ),
                                      _buildDetailTile(
                                        context,
                                        label: getTranslated(
                                          context,
                                          AppString.information_patient_time,
                                        ).toString(),
                                        value: time ?? "-",
                                        icon: Icons.access_time_rounded,
                                      ),
                                      _buildDetailTile(
                                        context,
                                        label: getTranslated(
                                          context,
                                          AppString.information_patient_address,
                                        ).toString(),
                                        value: patientAddress ?? "-",
                                        icon: Icons.location_on_outlined,
                                      ),

                                      // Insurance Details
                                      if (isInsured == 1) ...[
                                        _buildDetailTile(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.policy_provider,
                                          ).toString(),
                                          value: policyInsurerName,
                                          icon: Icons.verified_user_outlined,
                                        ),
                                        _buildDetailTile(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.policy_number,
                                          ).toString(),
                                          value: policyNumber,
                                          icon: Icons
                                              .confirmation_number_outlined,
                                        ),
                                      ] else ...[
                                        _buildDetailTile(
                                          context,
                                          label: getTranslated(
                                            context,
                                            AppString.patientInsured,
                                          ).toString(),
                                          value: getTranslated(
                                            context,
                                            AppString.patientIsNotInsured,
                                          ).toString(),
                                          icon: Icons.shield_outlined,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Tab 2: Illness Information & Astra Fill
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Astra Fill Display Widget
                                      if (userId != null)
                                        AstraFillDisplayWidget(
                                          patientId: userId.toString(),
                                          preloadedData: astraFillData,
                                        ),

                                      const SizedBox(height: 16),

                                      _buildInfoCard(
                                        context,
                                        title: getTranslated(
                                          context,
                                          AppString
                                              .information_patient_illness_information,
                                        ).toString(),
                                        content: illness ?? "None reported",
                                        icon: Icons.healing_rounded,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoCard(
                                        context,
                                        title: getTranslated(
                                          context,
                                          AppString
                                              .information_side_effect_drug,
                                        ).toString(),
                                        content: drugEffect ?? "None reported",
                                        icon: Icons.medication_rounded,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoCard(
                                        context,
                                        title: getTranslated(
                                          context,
                                          AppString.information_note,
                                        ).toString(),
                                        content: note ?? "No notes added",
                                        icon: Icons.notes_rounded,
                                      ),

                                      // Report Images
                                      if (reportImages.isNotEmpty) ...[
                                        const SizedBox(height: 20),
                                        Text(
                                          getTranslated(
                                            context,
                                            AppString
                                                .information_report_image_title,
                                          ).toString(),
                                          style:
                                              textTheme.titleMedium?.copyWith(
                                            color: AyurezeTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: reportImages.length,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemBuilder: (context, index) {
                                            return FullScreenWidget(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  reportImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Tab 3: Prescription
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration:
                                            AyurezeTheme.panelDecoration(),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 40,
                                              color: AyurezeTheme.forestDeep,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "Smart Prescribe (Astra AI)",
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                color: AyurezeTheme.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "AI-assisted prescription generator tailored for clinical practice.",
                                              textAlign: TextAlign.center,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color:
                                                    AyurezeTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                "Launch Smart Prescribe",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AyurezeTheme.forestDeep,
                                                minimumSize:
                                                    const Size.fromHeight(50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrescriptionScreen(
                                                      patientId:
                                                          userId.toString(),
                                                      patientName:
                                                          name ?? "Patient",
                                                      patientPhone: phoneNo,
                                                      astraFillData:
                                                          astraFillData,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
          );
        },
      ),
    );
  }

  void _showCallOptions(
    BuildContext context,
    String? phoneNo,
    String? appointmentType,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AyurezeTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(AppIcons.call, color: AyurezeTheme.forestDeep),
                  title: Text(
                    getTranslated(context, "call_text").toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AyurezeTheme.textPrimary,
                        ),
                  ),
                  onTap: () {
                    if (SharedPreferenceHelper.getBoolean(
                          Preferences.is_logged_in,
                        ) ==
                        true) {
                      Navigator.of(context).pop();
                      launchUrl(Uri.parse("tel:$phoneNo"));
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                if (appointmentType == 'video')
                  ListTile(
                    leading: Icon(
                      Icons.videocam_rounded,
                      color: AyurezeTheme.forestDeep,
                    ),
                    title: Text(
                      getTranslated(context, "video_call").toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AyurezeTheme.textPrimary,
                          ),
                    ),
                    onTap: () {
                      if (SharedPreferenceHelper.getBoolean(
                            Preferences.is_logged_in,
                          ) ==
                          true) {
                        Navigator.of(context).pop();
                        _addVideoOverlay(context);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AyurezeTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: AyurezeTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AyurezeTheme.panelDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AyurezeTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AyurezeTheme.forestDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AyurezeTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      color: AyurezeTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AyurezeTheme.panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AyurezeTheme.forestDeep),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: AyurezeTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: textTheme.bodyLarge?.copyWith(
              color: AyurezeTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _addVideoOverlay(BuildContext context) {
    final vm = Provider.of<PatientInformationViewModel>(context, listen: false);
    OslerToast.warning(context, "Video Call feature is currently unavailable.");
  }
}
