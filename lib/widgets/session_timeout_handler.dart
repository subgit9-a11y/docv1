import 'package:doctro/theme/ayureze_theme.dart';
import 'package:flutter/material.dart';

class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;

  const SessionTimeoutHandler({
    Key? key,
    required this.child,
    this.timeout = const Duration(minutes: 30),
    required this.onTimeout,
  }) : super(key: key);

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> {
  late DateTime _lastActivity;

  @override
  void initState() {
    super.initState();
    _lastActivity = DateTime.now();
  }

  void _onUserActivity() {
    _lastActivity = DateTime.now();
  }

  bool get _isTimedOut =>
      DateTime.now().difference(_lastActivity) >= widget.timeout;

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
