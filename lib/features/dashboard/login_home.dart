import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/core/constants/app_string.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/localization/localization_constant.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/modern_drawer.dart';
import 'package:doctro/widgets/osler_skeleton.dart';
import 'package:doctro/features/dashboard/patient_information.dart';
import 'package:doctro/features/dashboard/view_models/login_home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class LoginHomeScreen extends StatelessWidget {
  final String? chat;

  const LoginHomeScreen({Key? key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginHomeViewModel()..initializeData(context),
      child: const _LoginHomeView(),
    );
  }
}

class _LoginHomeView extends StatefulWidget {
  const _LoginHomeView({Key? key}) : super(key: key);

  @override
  State<_LoginHomeView> createState() => _LoginHomeViewState();
}

class _LoginHomeViewState extends State<_LoginHomeView>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AyurezeTheme.canvas,
      drawer: const ModernDrawer(),
      body: Consumer<LoginHomeViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            color: AyurezeTheme.healingGreen50,
            backgroundColor: AyurezeTheme.surface,
            onRefresh: () => viewModel.fetchAppointments(context),
            child: SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar / Header
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AyurezeTheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AyurezeTheme.border,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AyurezeTheme.shadow,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: (viewModel.dFullImage != null &&
                                          viewModel.dFullImage!.isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: CachedNetworkImage(
                                            imageUrl: viewModel.dFullImage!,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Icon(
                                              Icons.person_rounded,
                                              color: AyurezeTheme.forestDeep,
                                            ),
                                            errorWidget: (_, __, ___) => Icon(
                                              Icons.person_rounded,
                                              color: AyurezeTheme.forestDeep,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.menu_rounded,
                                          color: AyurezeTheme.forestDeep,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getTranslated(context, "welcome")
                                          .toString(),
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AyurezeTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      "Dr. ${viewModel.dName ?? 'Doctor'}",
                                      style: textTheme.titleLarge?.copyWith(
                                        color: AyurezeTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'notifications');
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AyurezeTheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AyurezeTheme.border,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: AyurezeTheme.textPrimary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Hero Banner Card
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: AyurezeTheme.heroDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        "Clinical Dashboard",
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.health_and_safety_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  getTranslated(
                                    context,
                                    "today_appointment_schedule",
                                  ).toString(),
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Manage your consultations & patient health records seamlessly.",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Quick Stats Row (Responsive)
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 500;
                            final currencySymbol =
                                SharedPreferenceHelper.getString(
                              Preferences.currency_symbol,
                            );

                            return GridView.count(
                              crossAxisCount: isWide ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: isWide ? 1.8 : 1.5,
                              children: [
                                _buildStatCard(
                                  context,
                                  title: getTranslated(
                                    context,
                                    AppString.information_amount,
                                  ).toString(),
                                  value:
                                      "$currencySymbol${viewModel.totalEarnings.toStringAsFixed(0)}",
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AyurezeTheme.healingGreen50,
                                ),
                                _buildStatCard(
                                  context,
                                  title: "Patients",
                                  value: "${viewModel.patientCount}",
                                  icon: Icons.people_alt_rounded,
                                  color: AyurezeTheme.connectivityBlue50,
                                ),
                                _buildStatCard(
                                  context,
                                  title: "Today",
                                  value:
                                      "${viewModel.todayAppointments.length}",
                                  icon: Icons.calendar_today_rounded,
                                  color: AyurezeTheme.sunshineYellow50,
                                ),
                                _buildStatCard(
                                  context,
                                  title: "Reviews",
                                  value: "${viewModel.reviewCount}",
                                  icon: Icons.star_rounded,
                                  color: AyurezeTheme.caringViolet50,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (text) =>
                              viewModel.onSearchTextChanged(text),
                          style: textTheme.bodyLarge?.copyWith(
                            color: AyurezeTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search patient by name...",
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AyurezeTheme.forestDeep,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: AyurezeTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      viewModel.onSearchTextChanged('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AyurezeTheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AyurezeTheme.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: AyurezeTheme.healingGreen50,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Custom Segmented Tab Bar
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AyurezeTheme.surfaceMuted,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AyurezeTheme.border),
                          ),
                          child: Row(
                            children: [
                              _buildTabItem(
                                context,
                                index: 0,
                                label:
                                    "Today (${_getTabListCount(viewModel, 0)})",
                              ),
                              _buildTabItem(
                                context,
                                index: 1,
                                label:
                                    "Tomorrow (${_getTabListCount(viewModel, 1)})",
                              ),
                              _buildTabItem(
                                context,
                                index: 2,
                                label:
                                    "Upcoming (${_getTabListCount(viewModel, 2)})",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Appointments List Section
                  if (viewModel.isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const OslerCardSkeleton(),
                          childCount: 4,
                        ),
                      ),
                    )
                  else
                    _buildAppointmentSliverList(context, viewModel),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AyurezeTheme.panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: AyurezeTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AyurezeTheme.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required int index,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AyurezeTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AyurezeTheme.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? AyurezeTheme.textPrimary
                  : AyurezeTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  int _getTabListCount(LoginHomeViewModel vm, int tabIndex) {
    final isSearching = _searchController.text.isNotEmpty;
    if (tabIndex == 0) {
      return isSearching ? vm.searchResult.length : vm.todayAppointments.length;
    } else if (tabIndex == 1) {
      return isSearching
          ? vm.tomorrowSearchResult.length
          : vm.tomorrowAppointments.length;
    } else {
      return isSearching
          ? vm.upcomingSearchResult.length
          : vm.upcomingAppointments.length;
    }
  }

  Widget _buildAppointmentSliverList(
    BuildContext context,
    LoginHomeViewModel vm,
  ) {
    final isSearching = _searchController.text.isNotEmpty;
    dynamic items;

    if (_selectedTabIndex == 0) {
      items = isSearching ? vm.searchResult : vm.todayAppointments;
    } else if (_selectedTabIndex == 1) {
      items = isSearching ? vm.tomorrowSearchResult : vm.tomorrowAppointments;
    } else {
      items = isSearching ? vm.upcomingSearchResult : vm.upcomingAppointments;
    }

    if (items == null || items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: AyurezeTheme.mutedPanelDecoration(),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 48,
                  color: AyurezeTheme.forestDeep.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "No Appointments Found",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AyurezeTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSearching
                      ? "No patient matching '${_searchController.text}'"
                      : "There are no appointments scheduled for this section.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AyurezeTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _buildAppointmentCard(context, item);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, dynamic item) {
    final textTheme = Theme.of(context).textTheme;
    final String? imageUrl = item.user?.fullImage;
    final String patientName = item.patientName ?? "Patient";
    final String appointmentTime = item.time ?? "--:--";
    final String appointmentDate = item.date ?? "";
    final String address = item.patientAddress ?? "In-Clinic Consultation";

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => patientDetailsScreen(id: item.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AyurezeTheme.panelDecoration(),
            child: Row(
              children: [
                // Patient Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AyurezeTheme.healingGreen50,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AyurezeTheme.healingGreen50,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Image.asset(
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
                const SizedBox(width: 14),
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: textTheme.titleMedium?.copyWith(
                          color: AyurezeTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AyurezeTheme.forestDeep,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointmentTime,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AyurezeTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (appointmentDate.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              "• $appointmentDate",
                              style: textTheme.bodyMedium?.copyWith(
                                color: AyurezeTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AyurezeTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Arrow
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AyurezeTheme.surfaceMuted,
                    shape: BoxShape.circle,
                    border: Border.all(color: AyurezeTheme.border),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AyurezeTheme.forestDeep,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
