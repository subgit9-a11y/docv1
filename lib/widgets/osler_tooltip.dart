import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';

class OslerTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode? triggerMode;

  const OslerTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: triggerMode ?? TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: AyurezeTheme.healingGreen100,
        borderRadius: BorderRadius.circular(AyurezeTheme.radiusSm),
      ),
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
      child: child,
    );
  }
}
