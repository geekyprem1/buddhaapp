import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_app_chrome.dart';
import '../platform/alarm_service.dart';

/// Route-aware root layout for the persistent app chrome.
///
/// The router listener is attached after the first frame. Listening directly
/// from `MaterialApp.builder` can notify while the Router child is still being
/// built, which both triggers a framework assertion and leaves the chrome on
/// the previous route.
class AppChromeLayout extends StatefulWidget {
  const AppChromeLayout({
    required this.router,
    required this.body,
    required this.topBanner,
    required this.miniPlayer,
    required this.chromeEnabled,
    required this.bodhiAiEnabled,
    super.key,
  });

  final GoRouter router;
  final Widget body;
  final Widget topBanner;
  final Widget miniPlayer;
  final bool chromeEnabled;
  final bool bodhiAiEnabled;

  @override
  State<AppChromeLayout> createState() => _AppChromeLayoutState();
}

class _AppChromeLayoutState extends State<AppChromeLayout>
    with WidgetsBindingObserver {
  bool _listening = false;
  bool _isAlarmRinging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachAfterFrame();
    _checkAlarmRinging();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAlarmRinging();
    }
  }

  Future<void> _checkAlarmRinging() async {
    try {
      final ringing = await AlarmService().isRinging();
      if (mounted && ringing != _isAlarmRinging) {
        setState(() => _isAlarmRinging = ringing);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant AppChromeLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router == widget.router) return;
    if (_listening) {
      oldWidget.router.routerDelegate.removeListener(_routeChanged);
      _listening = false;
    }
    _attachAfterFrame();
  }

  void _attachAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _listening) return;
      widget.router.routerDelegate.addListener(_routeChanged);
      _listening = true;
      setState(() {});
    });
  }

  void _routeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_listening) {
      widget.router.routerDelegate.removeListener(_routeChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showChrome =
        widget.chromeEnabled && BottomAppChrome.isVisibleFor(widget.router);
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isAlarmRinging)
              Container(
                color: const Color(0xFF8B1A1A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      const Icon(Icons.alarm_on, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Prarthana is ringing',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF8B1A1A),
                        ),
                        onPressed: () async {
                          await AlarmService().stopRinging();
                          if (mounted) setState(() => _isAlarmRinging = false);
                        },
                        child: const Text('STOP'),
                      ),
                    ],
                  ),
                ),
              ),
            widget.topBanner,
            Expanded(child: widget.body),
            if (showChrome)
              BottomAppChrome(
                router: widget.router,
                bodhiAiEnabled: widget.bodhiAiEnabled,
              ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: showChrome
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom: BottomAppChrome.heightOf(context, widget.router),
                  ),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    child: widget.miniPlayer,
                  ),
                )
              : widget.miniPlayer,
        ),
      ],
    );
  }
}
