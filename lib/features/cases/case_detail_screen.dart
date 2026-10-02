import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/features/consultation/videoCall/video_Call.dart';
import 'package:doctro/features/prescription/astra/prescription_screen.dart';
import 'package:doctro/services/astra_api_service.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_loader.dart';
import 'package:doctro/widgets/osler_state_view.dart';
import 'package:doctro/widgets/osler_toast.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

/// Case detail view: the AI companion's journey/progress for a single case,
/// with a video-call entry point straight to the patient - the follow-up
/// the remaining-work guide scoped alongside the case list screen itself.
/// Backed by GET /api/companion/case/{case_id} for a live refresh; the data
/// handed in from the list is shown immediately so this never starts blank.
class CaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> initialCaseData;

  const CaseDetailScreen({super.key, required this.initialCaseData});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  late Map<String, dynamic> _caseData = widget.initialCaseData;
  bool _refreshing = false;

  String get _caseId => _caseData['id']?.toString() ?? '';

  Future<void> _refresh() async {
    final caseId = _caseId;
    if (caseId.isEmpty) return;
    setState(() => _refreshing = true);
    try {
      final fresh = await AstraApiService().getCase(caseId);
      if (fresh.isNotEmpty && mounted) {
        setState(() => _caseData = fresh);
      }
    } catch (_) {
      // Keep showing what we already have; this is a best-effort refresh.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _startVideoCall() {
    final userIdRaw = _caseData['user_id']?.toString();
    final userId = userIdRaw == null ? null : int.tryParse(userIdRaw);
    if (userId == null) {
      OslerToast.error(context, "Can't start the call: patient id missing.");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VideoCall(id: userId, callEnd: false, flag: "OutGoing"),
      ),
    );
  }

  void _writePrescription() {
    final patientId = _caseData['user_id']?.toString();
    if (patientId == null || patientId.isEmpty) {
      OslerToast.error(context, "Can't open prescription: patient id missing.");
      return;
    }
    final doctorId = SharedPreferenceHelper.getString(Preferences.doctorId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionScreen(
          patientId: patientId,
          // The case has no patient name on it - only a Laravel user_id.
          // Matches the same "Patient" fallback used elsewhere
          // (patient_information.dart) when a name isn't available.
          patientName: "Patient",
          doctorId: doctorId.isNotEmpty ? doctorId : null,
          caseId: _caseId,
        ),
      ),
    );
  }

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
    final diagnosis = (_caseData['diagnosis'] as String?)?.trim();
    final status = (_caseData['status'] as String?) ?? 'in_treatment';
    final (statusColor, statusBg, statusLabel) = _statusStyle(status);
    final progress = ((_caseData['progress_percentage'] as num?) ?? 0) / 100.0;
    final adherence = (_caseData['adherence_score'] as num?)?.toDouble();
    final followUps =
        (_caseData['follow_up_schedule'] as List?)?.cast<dynamic>() ?? [];

    String createdLabel = '';
    final createdAtRaw = _caseData['created_at'] as String?;
    if (createdAtRaw != null) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        createdLabel = DateFormat('dd MMM yyyy').format(parsed.toLocal());
      }
    }

    return Scaffold(
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
        title: Text('Case Details', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 18, height: 18, child: OslerLoader(size: 18))
                : HugeIcon(
                    icon: HugeIcons.strokeRoundedRefresh,
                    color: AyurezeTheme.forestDeep,
                    size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AyurezeTheme.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AyurezeTheme.space2xl),
              decoration: AyurezeTheme.heroDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          diagnosis?.isNotEmpty == true
                              ? diagnosis!
                              : 'Untitled case',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AyurezeTheme.spaceSm, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius:
                              BorderRadius.circular(AyurezeTheme.radiusPill),
                        ),
                        child: Text(
                          statusLabel,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  if (createdLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Opened $createdLabel',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  OslerButton(
                    text: 'Start Video Call',
                    onPressed: _startVideoCall,
                    icon: Icons.videocam,
                  ),
                  const SizedBox(height: 10),
                  OslerButton(
                    text: 'Write Prescription',
                    onPressed: _writePrescription,
                    icon: Icons.description_outlined,
                    style: OslerButtonStyle.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AyurezeTheme.spaceXl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AyurezeTheme.spaceLg),
              decoration: AyurezeTheme.panelDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Treatment Progress',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AyurezeTheme.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AyurezeTheme.surfaceMuted,
                      valueColor:
                          AlwaysStoppedAnimation(AyurezeTheme.healingGreen50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_caseData['treatment_duration_days'] ?? 30}-day treatment plan'
                    '${adherence != null ? ' • ${adherence.toStringAsFixed(0)}% adherence' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (followUps.isNotEmpty) ...[
              const SizedBox(height: AyurezeTheme.spaceLg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AyurezeTheme.spaceLg),
                decoration: AyurezeTheme.panelDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Follow-up Schedule',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    for (final item in followUps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            HugeIcon(
                                icon: HugeIcons.strokeRoundedCalendar01,
                                size: 14,
                                color: AyurezeTheme.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(item.toString(),
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (_caseId.isEmpty) ...[
              const SizedBox(height: AyurezeTheme.spaceLg),
              OslerStateView(
                icon: HugeIcons.strokeRoundedAlert02,
                title: 'Missing case id',
                message: 'This case record has no id to refresh from.',
                tone: OslerStateTone.muted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
