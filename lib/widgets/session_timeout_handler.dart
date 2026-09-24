import 'dart:async';

import 'package:flutter/material.dart';

class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;

  /// Source of the current time. Overridable so tests can drive the idle
  /// window deterministically instead of depending on wall-clock time.
  final DateTime Function() clock;

  const SessionTimeoutHandler({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 30),
    required this.onTimeout,
    this.clock = DateTime.now,
  });

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> {
  late DateTime _lastActivity;
  Timer? _ticker;
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _lastActivity = widget.clock();
    _ticker =
        Timer.periodic(const Duration(seconds: 30), (_) => _checkTimeout());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onUserActivity() {
    _lastActivity = widget.clock();
  }

  bool get _isTimedOut =>
      widget.clock().difference(_lastActivity) >= widget.timeout;

  void _checkTimeout() {
    if (_hasTimedOut || !_isTimedOut) return;
    // Fire once; without this guard the periodic ticker would re-trigger the
    // callback (and clear preferences) every 30 seconds until unmount.
    _hasTimedOut = true;
    widget.onTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onUserActivity,
      onPanDown: (_) => _onUserActivity(),
      child: widget.child,
    );
  }
}
