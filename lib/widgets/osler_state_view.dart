import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/osler_button.dart';
import 'package:doctro/widgets/osler_loader.dart';

/// A centered spinner with an optional message, for whenever a screen or
/// section is waiting on data. Replaces the bare `CircularProgressIndicator()`
/// that different screens used to hand-roll with inconsistent colors/sizes.
class OslerLoadingView extends StatelessWidget {
  final String? message;

  const OslerLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OslerLoader(),
          if (message != null) ...[
            const SizedBox(height: AyurezeTheme.spaceLg),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AyurezeTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Whether an [OslerStateView] reads as a neutral "nothing here yet" state
/// or a "something went wrong" state - the two differ only in icon tint.
enum OslerStateTone { neutral, error, muted }

/// The icon-in-circle + title + message (+ optional action button) pattern
/// used for every empty and error state across the app - previously each
/// screen re-implemented this inline with its own spacing and icon choices.
/// [ErrorUtilityScreen] is the dedicated full-screen version of this same
/// idea (with a status badge and back button) for app-level states like 404;
/// this widget is for in-page/in-tab states.
class OslerStateView extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final String? message;
  final OslerStateTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OslerStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = OslerStateTone.neutral,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final (tint, foreground) = switch (tone) {
      OslerStateTone.error => (
          AyurezeTheme.remoteRed10,
          AyurezeTheme.remoteRed100
        ),
      OslerStateTone.muted => (
          AyurezeTheme.oslerGray10,
          AyurezeTheme.oslerGray100
        ),
      OslerStateTone.neutral => (
          AyurezeTheme.healingGreen10,
          AyurezeTheme.healingGreen100
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AyurezeTheme.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: HugeIcon(icon: icon, color: foreground, size: 40),
            ),
            const SizedBox(height: AyurezeTheme.spaceLg),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: AyurezeTheme.spaceSm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AyurezeTheme.textSecondary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AyurezeTheme.spaceLg),
              OslerButton(text: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }

  /// Convenience factory for the most common error case: something failed
  /// to load and the user can retry.
  factory OslerStateView.error({
    String title = "Couldn't Load Data",
    String? message,
    VoidCallback? onRetry,
  }) =>
      OslerStateView(
        icon: HugeIcons.strokeRoundedCloudOff,
        title: title,
        message: message,
        tone: OslerStateTone.error,
        actionLabel: onRetry == null ? null : 'Retry',
        onAction: onRetry,
      );
}
