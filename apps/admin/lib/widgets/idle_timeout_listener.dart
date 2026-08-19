import 'dart:async';

import 'package:flutter/material.dart';

/// Signs the admin out after [timeout] with no pointer or key activity
/// (AR-1.4, default 12 hours).
class IdleTimeoutListener extends StatefulWidget {
  const IdleTimeoutListener({
    required this.timeout,
    required this.onTimeout,
    required this.child,
    super.key,
  });

  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  @override
  State<IdleTimeoutListener> createState() => _IdleTimeoutListenerState();
}

class _IdleTimeoutListenerState extends State<IdleTimeoutListener> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(IdleTimeoutListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeout != widget.timeout) {
      _arm();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _arm() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        _arm();
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (_) => _arm(),
        onPointerSignal: (_) => _arm(),
        child: widget.child,
      ),
    );
  }
}
