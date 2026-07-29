import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';

class OslerCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showBorder;

  const OslerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.showBorder = true,
  });

  @override
  State<OslerCard> createState() => _OslerCardState();
}

class _OslerCardState extends State<OslerCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: widget.margin,
        child: Material(
          color: widget.backgroundColor ?? AyurezeTheme.surface,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: widget.showBorder
                    ? Border.all(color: AyurezeTheme.border)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? const Color(0x05000000)
                        : const Color(0x0F000000),
                    blurRadius: _isPressed ? 8 : 18,
                    offset:
                        _isPressed ? const Offset(0, 4) : const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
