import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:doctro/core/constants/app_icons.dart';
import 'package:doctro/theme/ayureze_theme.dart';

class OslerCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isError;

  const OslerCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AyurezeTheme.healingGreenFill : Colors.transparent,
              borderRadius: BorderRadius.circular(AyurezeTheme.radiusXs),
              border: Border.all(
                color: isError
                    ? AyurezeTheme.remoteRed50
                    : (value
                        ? AyurezeTheme.healingGreenFill
                        : AyurezeTheme.border),
                width: 2,
              ),
            ),
            child: value
                ? HugeIcon(icon: AppIcons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isError
                        ? AyurezeTheme.remoteRed50
                        : AyurezeTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
