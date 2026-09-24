import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/theme/ayureze_theme.dart';

enum OslerAlertType { success, error, warning, info }

class OslerAlert extends StatelessWidget {
  final String title;
  final String? message;
  final OslerAlertType type;
  final bool showIcon;
  final VoidCallback? onDismiss;

  const OslerAlert({
    super.key,
    required this.title,
    this.message,
    this.type = OslerAlertType.info,
    this.showIcon = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(AyurezeTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AyurezeTheme.spaceLg),
        child: Row(
          children: [
            if (showIcon) ...[
              Container(
                padding: const EdgeInsets.all(AyurezeTheme.spaceSm),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(AyurezeTheme.radiusMd),
                ),
                child: HugeIcon(
                    icon: _getIcon(), color: _getIconColor(), size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getForegroundColor(),
                        ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getForegroundColor(),
                            height: 1.3,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null) ...[
              GestureDetector(
                onTap: onDismiss,
                child: HugeIcon(
                    icon: AppIcons.close,
                    color: _getForegroundColor(),
                    size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case OslerAlertType.success:
        return AyurezeTheme.healingGreen10;
      case OslerAlertType.error:
        return AyurezeTheme.remoteRed10;
      case OslerAlertType.warning:
        return AyurezeTheme.sunshineYellow10;
      case OslerAlertType.info:
        return AyurezeTheme.connectivityBlue10;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case OslerAlertType.success:
        return AyurezeTheme.healingGreen100;
      case OslerAlertType.error:
        return AyurezeTheme.remoteRed100;
      case OslerAlertType.warning:
        return AyurezeTheme.sunshineYellow100;
      case OslerAlertType.info:
        return AyurezeTheme.connectivityBlue100;
    }
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case OslerAlertType.success:
        return AyurezeTheme.healingGreen50.withValues(alpha: 0.2);
      case OslerAlertType.error:
        return AyurezeTheme.remoteRed50.withValues(alpha: 0.2);
      case OslerAlertType.warning:
        return AyurezeTheme.sunshineYellow50.withValues(alpha: 0.2);
      case OslerAlertType.info:
        return AyurezeTheme.connectivityBlue50.withValues(alpha: 0.2);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case OslerAlertType.success:
        return AyurezeTheme.healingGreen100;
      case OslerAlertType.error:
        return AyurezeTheme.remoteRed100;
      case OslerAlertType.warning:
        return AyurezeTheme.sunshineYellow100;
      case OslerAlertType.info:
        return AyurezeTheme.connectivityBlue100;
    }
  }

  List<List<dynamic>> _getIcon() {
    switch (type) {
      case OslerAlertType.success:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case OslerAlertType.error:
        return HugeIcons.strokeRoundedAlertCircle;
      case OslerAlertType.warning:
        return HugeIcons.strokeRoundedAlert02;
      case OslerAlertType.info:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }
}
