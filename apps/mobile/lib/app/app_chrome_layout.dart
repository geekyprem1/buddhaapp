import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_app_chrome.dart';

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

class _AppChromeLayoutState extends State<AppChromeLayout> {
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _attachAfterFrame();
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
