import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The single source of truth for motion across the app: durations, curves,
/// and the two reusable wrappers (tap feedback, entrance) every screen
/// should use instead of inventing its own timing. Keeping these in one
/// place is what makes animations feel the same on every screen rather than
/// each screen picking its own duration/curve by feel.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;

  /// Per-item delay for a staggered list/column entrance.
  static const Duration stagger = Duration(milliseconds: 60);
}

/// Scales its child down slightly on press, like every tappable surface in
/// the app (cards, list rows, buttons that don't already do this). Wrap
/// anything tappable in this instead of hand-rolling an AnimatedScale.
class AnimatedTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const AnimatedTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
  });

  @override
  State<AnimatedTapScale> createState() => _AnimatedTapScaleState();
}

class _AnimatedTapScaleState extends State<AnimatedTapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}

/// Fades and slides a screen section into place. Give each section on a
/// screen an increasing [index] (0, 1, 2, ...) to get a staggered cascade
/// instead of everything arriving at once - this is the one entrance effect
/// every screen should share.
class ScreenEntrance extends StatelessWidget {
  final Widget child;
  final int index;

  /// Fraction of the child's own height to slide up from (flutter_animate's
  /// slideY is relative, not pixels). 0.08 reads as a small, subtle rise.
  final double slideFraction;

  const ScreenEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.slideFraction = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: AppMotion.stagger * index)
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.enter)
        .slideY(
          begin: slideFraction,
          end: 0,
          duration: AppMotion.slow,
          curve: AppMotion.enter,
        );
  }
}
