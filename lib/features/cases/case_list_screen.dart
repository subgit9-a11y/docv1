import 'package:doctro/features/cases/view_models/case_list_view_model.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/modern_drawer.dart';
import 'package:doctro/widgets/osler_skeleton.dart';
import 'package:doctro/widgets/osler_state_view.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Shows the companion cases (opened from a patient's Astra consultation)
/// assigned to the signed-in doctor. Backed by
/// GET /api/companion/case/by-doctor/{doctor_id} - the only way a doctor app
/// can discover a case, since case/create only ever hands the case_id back
/// to the patient app that created it.
class CaseListScreen extends StatelessWidget {
  const CaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseListViewModel()..fetchCases(),
      child: const _CaseListView(),
    );
  }
}

class _CaseListView extends StatefulWidget {
  const _CaseListView();

  @override
  State<_CaseListView> createState() => _CaseListViewState();
}

class _CaseListViewState extends State<_CaseListView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const ModernDrawer(),
      backgroundColor: AyurezeTheme.canvas,
      appBar: AppBar(
        backgroundColor: AyurezeTheme.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AyurezeTheme.textPrimary,
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Cases', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMenu01,
                color: AyurezeTheme.forestDeep,
                size: 22),
          ),
        ],
      ),
      body: Consumer<CaseListViewModel>(
        builder: (context, viewModel, _) {
          return RefreshIndicator(
            color: AyurezeTheme.forestDeep,
            onRefresh: viewModel.fetchCases,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (viewModel.isLoading)
                  SliverPadding(
                    padding: AyurezeTheme.screenPadding,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AyurezeTheme.spaceMd),
                          child: OslerSkeleton(
                              width: double.infinity,
                              height: 100,
                              borderRadius: 20),
                        ),
                        childCount: 4,
                      ),
                    ),
                  )
                else if (viewModel.errorMessage != null)
                  SliverFillRemaining(
                    child: OslerStateView.error(
                      message: viewModel.errorMessage,
                      onRetry: viewModel.fetchCases,
                    ),
                  )
                else if (viewModel.cases.isEmpty)
                  SliverFillRemaining(
                    child: OslerStateView(
                      icon: HugeIcons.strokeRoundedFolder01,
                      title: 'No Cases Yet',
                      message:
                          'Cases opened for you during a patient\'s Astra\nconsultation will appear here.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AyurezeTheme.spaceXl, 0,
                        AyurezeTheme.spaceXl, AyurezeTheme.space2xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _CaseCard(caseData: viewModel.cases[i]),
                        childCount: viewModel.cases.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Map<String, dynamic> caseData;

  const _CaseCard({required this.caseData});

  (Color, Color, String) _statusStyle(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return (
          AyurezeTheme.oslerGray100,
          AyurezeTheme.oslerGray10,
          status == 'resolved' ? 'Resolved' : 'Closed'
        );
      case 'follow_up':
        return (
          AyurezeTheme.sunshineYellow50,
          AyurezeTheme.sunshineYellow10,
          'Follow-up'
        );
      case 'open':
        return (AyurezeTheme.healingGreen50, AyurezeTheme.healingGreen10, 'Open');
      case 'in_treatment':
      default:
        return (
          AyurezeTheme.healingGreen50,
          AyurezeTheme.healingGreen10,
          'In Treatment'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = (caseData['diagnosis'] as String?)?.trim();
    final status = (caseData['status'] as String?) ?? 'in_treatment';
    final (statusColor, statusBg, statusLabel) = _statusStyle(status);
    final progress = ((caseData['progress_percentage'] as num?) ?? 0) / 100.0;

    String createdLabel = '';
    final createdAtRaw = caseData['created_at'] as String?;
    if (createdAtRaw != null) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        createdLabel = DateFormat('dd MMM yyyy').format(parsed.toLocal());
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AyurezeTheme.spaceMd),
      padding: const EdgeInsets.all(AyurezeTheme.spaceLg),
      decoration: AyurezeTheme.panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  diagnosis?.isNotEmpty == true ? diagnosis! : 'Untitled case',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AyurezeTheme.spaceSm, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AyurezeTheme.radiusPill),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                ),
              ),
            ],
          ),
          if (createdLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    size: 14,
                    color: AyurezeTheme.textSecondary),
                const SizedBox(width: 4),
                Text('Opened $createdLabel',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AyurezeTheme.radiusPill),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AyurezeTheme.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(AyurezeTheme.healingGreen50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${caseData['treatment_duration_days'] ?? 30}-day treatment plan',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
